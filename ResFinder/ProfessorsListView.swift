import SwiftUI

struct ProfessorsListView: View {
    let school: String
    let researchFilters: [String]    // new parameter

    @StateObject private var vm = ProfessorsViewModel()
    @State private var searchText = ""

    // filter by school, by researchFilters, then by search text
    private var filteredProfessors: [Professor] {
        vm.professors
            // 1) must match the selected school
            .filter { $0.university.caseInsensitiveCompare(school) == .orderedSame }
            // 2) must match at least one of the selected research areas (if any)
            .filter { prof in
                guard !researchFilters.isEmpty else { return true }
                return !Set(prof.researchAreas)
                    .intersection(Set(researchFilters))
                    .isEmpty
            }
            // 3) then apply search‑text filter
            .filter { prof in
                guard !searchText.isEmpty else { return true }
                let term = searchText.lowercased()
                return prof.name.lowercased().contains(term)
                    || prof.researchAreas.contains { $0.lowercased().contains(term) }
            }
    }

    var body: some View {
        List {
            // header
            Text("Showing \(filteredProfessors.count) of \(vm.totalCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ForEach(filteredProfessors) { prof in
                NavigationLink(destination: DetailView(prof: prof)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prof.name).font(.headline)
                        Text(prof.department)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search by name or research area")
        .listStyle(PlainListStyle())
        .navigationTitle("\(school) Faculty")
        .overlay {
            if vm.isLoading {
                ProgressView().scaleEffect(1.3)
            } else if let err = vm.errorMessage {
                Text("Error: \(err)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear { vm.load() }
    }
}

struct ProfessorsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfessorsListView(
                school: "UMD",
                researchFilters: ["Machine Learning", "Computer Vision"]
            )
        }
    }
}
