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
        
        // Add profileUrl if available
        if let urlString = profileUrl?.absoluteString {
            outreachData["profileUrl"] = urlString
        }
        
        // Add to user's outreach collection
        // Fix: Use the correct closure type for addDocument and capture self explicitly
        self.db.collection("users").document(userId).collection("outreach").addDocument(data: outreachData) { [self] (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Since we don't have the reference directly in this closure type,
            // we need to query for the document we just created
            // This is a workaround for the closure type mismatch
            // Get the most recently created document
            self.db.collection("users").document(userId).collection("outreach")
                .whereField("professorId", isEqualTo: professorId)
                .whereField("dateEmailed", isEqualTo: dateEmailed)
                .order(by: FieldPath.documentID(), descending: true)
                .limit(to: 1)
                .getDocuments { (snapshot, err) in
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
                
                // Handle optional follow-up fields
                let followUpEmailSent = data["followUpEmailSent"] as? String ?? ""
                let followUpDate = (data["followUpDate"] as? Timestamp)?.dateValue()
                
                // Handle optional profileUrl
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
    let profileUrl: URL?  // This property is correct
    
    var daysSinceContact: Int {
        let calendar = Calendar.current
        let now = Date()
        return calendar.dateComponents([.day], from: dateEmailed, to: now).day ?? 0
    }
    
    var needsFollowUp: Bool {
        // Updated to make it 1 day for testing purposes
        return daysSinceContact >= 0 && !hasFollowedUp
    }
}
