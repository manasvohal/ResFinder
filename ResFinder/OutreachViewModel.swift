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
        
        FirebaseService.shared.saveOutreachRecord(
            professorId: professor.id,
            professorName: professor.name,
            emailSent: emailSent,
            dateEmailed: Date()
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
}
