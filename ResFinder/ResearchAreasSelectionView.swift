import SwiftUI

struct ResearchAreasSelectionView: View {
    let school: String
    @StateObject private var vm = ProfessorsViewModel()
    @State private var selectedAreas = Set<String>()
    @State private var searchText = ""
    
    // Filtered research areas
    private var filteredAreas: [String] {
        if searchText.isEmpty {
            return availableAreas
        } else {
            return availableAreas.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // All areas for this school, sorted
    private var availableAreas: [String] {
        let all = vm.professors
            .filter { $0.university.caseInsensitiveCompare(school) == .orderedSame }
            .flatMap { $0.researchAreas }
        return Array(Set(all)).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search research areas", text: $searchText)
                    .font(.body)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 12)
            
            if vm.isLoading {
                Spacer()
                ProgressView("Loading research areas...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            } else if let error = vm.errorMessage {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Error")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else {
                // Results count
                HStack {
                    Text("\(filteredAreas.count) areas found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    if !selectedAreas.isEmpty {
                        Text("\(selectedAreas.count) selected")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
                
                // Areas list
                List {
                    ForEach(filteredAreas, id: \.self) { area in
                        MultipleSelectionRow(
                            title: area,
                            isSelected: selectedAreas.contains(area),
                            action: {
                                if selectedAreas.contains(area) {
                                    selectedAreas.remove(area)
                                } else {
                                    selectedAreas.insert(area)
                                }
                            }
                        )
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            
            // Next button as full-width button at bottom
            VStack {
                NavigationLink(
                    destination: ProfessorsListView(
                        school: school,
                        researchFilters: Array(selectedAreas)
                    )
                ) {
                    Text("Show \(selectedAreas.count) Professors")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAreas.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .disabled(selectedAreas.isEmpty)
                .padding(.vertical, 8)
                
                // Hint text at bottom
                if selectedAreas.isEmpty {
                    Text("Select at least one research area")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
            }
            .background(
                Rectangle()
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
            )
        }
        .navigationTitle("\(school) Research Areas")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { vm.load() }
    }
}

// Improved selection row with animation
struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .padding(.vertical, 4)
    }
}
