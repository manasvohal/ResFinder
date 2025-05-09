import SwiftUI
import Combine

class ProfessorsViewModel: ObservableObject {
    @Published var professors: [Professor] = []
    @Published var totalCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func load() {
        isLoading = true
        APIClient.fetchProfessors { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let resp):
                    self?.totalCount = resp.count
                    self?.professors = resp.professors
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
