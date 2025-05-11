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
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func saveOutreachRecord(for professor: Professor, emailSent: String) {
        isLoading = true
        errorMessage = nil
        
        // Print statement for debugging
        print("Saving outreach with professor URL: \(professor.profileUrl)")
        
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
                case .success:
                    // Reload the records to include the new one
                    self?.loadOutreachRecords()
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
                    // Reload the records to reflect the update
                    self?.loadOutreachRecords()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Helper function to fetch a professor's details by ID
    func fetchProfessorDetails(byId professorId: String, completion: @escaping (Professor?) -> Void) {
        // Make an API call to fetch professor details
        APIClient.fetchProfessors { result in
            switch result {
            case .success(let response):
                // Find the professor with the matching ID
                if let professor = response.professors.first(where: { $0.id == professorId }) {
                    completion(professor)
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
}
