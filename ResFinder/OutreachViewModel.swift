import SwiftUI
import Combine

class OutreachViewModel: ObservableObject {
    @Published var outreachRecords: [OutreachRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadOutreachRecords() {
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.getOutreachRecords { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let records):
                    self?.outreachRecords = records
                    print("▶️ Loaded outreach IDs:", records.map { $0.id })
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func saveOutreachRecord(for professor: Professor, emailSent: String) {
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.saveOutreachRecord(
            professorId: professor.id,
            professorName: professor.name,
            emailSent: emailSent,
            dateEmailed: Date(),
            profileUrl: professor.profileUrl
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let docId):
                    // reload UI
                    self?.loadOutreachRecords()
                    // schedule a follow-up notification in 7 days
                    NotificationManager.shared.scheduleFollowUp(
                        for: docId,
                        professorName: professor.name,
                        days: 7
                    )
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func saveFollowUpEmail(for outreachRecord: OutreachRecord, followUpEmail: String) {
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.updateOutreachWithFollowUp(
            outreachId: outreachRecord.id,
            followUpEmail: followUpEmail
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.loadOutreachRecords()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Helper to fetch professor details by ID
    func fetchProfessorDetails(byId professorId: String, completion: @escaping (Professor?) -> Void) {
        APIClient.fetchProfessors { result in
            switch result {
            case .success(let resp):
                completion(resp.professors.first(where: { $0.id == professorId }))
            case .failure:
                completion(nil)
            }
        }
    }
}
