import SwiftUI
import Foundation
import Combine

// MARK: – ViewModel (unchanged)
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

// MARK: – ContentView: Pick School
struct ContentView: View {
    // Tuple of (display name, image asset name)
    private let schools: [(name: String, imageName: String)] = [
        ("UMD", "umd_logo"),
        ("Rutgers", "rutgers_logo")
    ]

    var body: some View {
        NavigationView {
            List(schools, id: \.name) { school in
                NavigationLink(destination: ResearchAreasSelectionView(school: school.name)) {
                    HStack(spacing: 12) {
                        Image(school.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        Text(school.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Pick School")
            .navigationBarBackButtonHidden(true)
        }
    }
}


// MARK: – Array Unique Extension
fileprivate extension Array where Element: Hashable {
    func unique() -> [Element] {
        Array(Set(self))
    }
}

// MARK: – Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

