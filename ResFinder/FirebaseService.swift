// ResFinder/FirebaseService.swift

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Create an initial user document in Firestore
            self.createUserDocument(userId: user.uid, email: email) { result in
                switch result {
                case .success:
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - Firestore
    
    private func createUserDocument(userId: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Delete the user’s Firestore data (user doc + outreach subcollection),
    /// then delete the Firebase Auth user.
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])))
            return
        }
        let userId = user.uid
        let userDocRef = db.collection("users").document(userId)
        let outreachCol = userDocRef.collection("outreach")
        
        // 1) Delete all outreach subdocs
        outreachCol.getDocuments { snapshot, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            let batch = self.db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            // 2) Delete user document
            batch.deleteDocument(userDocRef)
            batch.commit { batchErr in
                if let batchErr = batchErr {
                    completion(.failure(batchErr))
                    return
                }
                // 3) Delete Auth user
                user.delete { authErr in
                    if let authErr = authErr {
                        completion(.failure(authErr))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    // MARK: - Professor Outreach Tracking
    
    func saveOutreachRecord(professorId: String, professorName: String, emailSent: String, dateEmailed: Date, profileUrl: URL? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        var outreachData: [String: Any] = [
            "professorId": professorId,
            "professorName": professorName,
            "emailSent": emailSent,
            "dateEmailed": dateEmailed,
            "hasFollowedUp": false,
            "followUpEmailSent": "",
            "followUpDate": NSNull()
        ]
        
        if let urlString = profileUrl?.absoluteString {
            outreachData["profileUrl"] = urlString
        }
        
        db.collection("users").document(userId).collection("outreach").addDocument(data: outreachData) { [self] error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // query for the created document
            self.db.collection("users").document(userId).collection("outreach")
                .whereField("professorId", isEqualTo: professorId)
                .whereField("dateEmailed", isEqualTo: dateEmailed)
                .order(by: FieldPath.documentID(), descending: true)
                .limit(to: 1)
                .getDocuments { snapshot, err in
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    if let document = snapshot?.documents.first {
                        completion(.success(document.documentID))
                    } else {
                        completion(.failure(NSError(domain: "FirebaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve the created document"])))
                    }
                }
        }
    }
    
    func getOutreachRecords(completion: @escaping (Result<[OutreachRecord], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("users").document(userId).collection("outreach").order(by: "dateEmailed", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let outreachRecords = documents.compactMap { document -> OutreachRecord? in
                let data = document.data()
                
                guard
                    let professorId = data["professorId"] as? String,
                    let professorName = data["professorName"] as? String,
                    let emailSent = data["emailSent"] as? String,
                    let dateEmailed = (data["dateEmailed"] as? Timestamp)?.dateValue(),
                    let hasFollowedUp = data["hasFollowedUp"] as? Bool
                else {
                    return nil
                }
                
                let followUpEmailSent = data["followUpEmailSent"] as? String ?? ""
                let followUpDate = (data["followUpDate"] as? Timestamp)?.dateValue()
                
                var profileUrl: URL? = nil
                if let urlString = data["profileUrl"] as? String {
                    profileUrl = URL(string: urlString)
                }
                
                return OutreachRecord(
                    id: document.documentID,
                    professorId: professorId,
                    professorName: professorName,
                    emailSent: emailSent,
                    dateEmailed: dateEmailed,
                    hasFollowedUp: hasFollowedUp,
                    followUpEmailSent: followUpEmailSent,
                    followUpDate: followUpDate,
                    profileUrl: profileUrl
                )
            }
            
            completion(.success(outreachRecords))
        }
    }
    
    func updateOutreachWithFollowUp(outreachId: String, followUpEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let updateData: [String: Any] = [
            "hasFollowedUp": true,
            "followUpEmailSent": followUpEmail,
            "followUpDate": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).collection("outreach").document(outreachId).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Models

struct OutreachRecord: Identifiable {
    let id: String
    let professorId: String
    let professorName: String
    let emailSent: String
    let dateEmailed: Date
    let hasFollowedUp: Bool
    let followUpEmailSent: String
    let followUpDate: Date?
    let profileUrl: URL?
    
    var daysSinceContact: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: dateEmailed, to: Date()).day ?? 0
    }
    
    var needsFollowUp: Bool {
        return daysSinceContact >= 0 && !hasFollowedUp
    }
}
