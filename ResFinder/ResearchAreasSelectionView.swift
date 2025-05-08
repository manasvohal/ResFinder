import SwiftUI

struct ResearchAreasSelectionView: View {
    let school: String
    @StateObject private var vm = ProfessorsViewModel()
    @State private var selectedAreas = Set<String>()

    // All areas for this school, sorted
    private var availableAreas: [String] {
        let all = vm.professors
            .filter { $0.university.caseInsensitiveCompare(school) == .orderedSame }
            .flatMap { $0.researchAreas }
        return Array(Set(all)).sorted()
    }

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView("Loading areas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = vm.errorMessage {
                Text("Error: \(err)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(availableAreas, id: \.self) { area in
                    MultipleSelectionRow(title: area, isSelected: selectedAreas.contains(area)) {
                        if selectedAreas.contains(area) {
                            selectedAreas.remove(area)
                        } else {
                            selectedAreas.insert(area)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            // Next button
            NavigationLink("Show Professors ➔",
                           destination:
                             ProfessorsListView(
                               school: school,
                               researchFilters: Array(selectedAreas)
                             ))
            .disabled(selectedAreas.isEmpty)
            .padding()
        }
        .navigationTitle("\(school) Areas")
        .onAppear { vm.load() }
    }
}

// simple row with a checkmark
struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

