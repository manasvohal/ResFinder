import SwiftUI

struct ProfessorsListView: View {
    let school: String
    let researchFilters: [String]
    
    @StateObject private var vm = ProfessorsViewModel()
    @State private var searchText = ""
    
    // Filter professors
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
            // 3) then apply search-text filter
            .filter { prof in
                guard !searchText.isEmpty else { return true }
                let term = searchText.lowercased()
                return prof.name.lowercased().contains(term)
                    || prof.department.lowercased().contains(term)
                    || prof.researchAreas.contains { $0.lowercased().contains(term) }
            }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Red header bar
            Rectangle()
                .fill(Color.red)
                .frame(height: 1)
                .padding(.top, 1)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red)
                
                TextField("Search faculty by name or department", text: $searchText)
                    .font(.body)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Filter chips
            if !researchFilters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(researchFilters, id: \.self) { filter in
                            Text(filter)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            
            if vm.isLoading {
                Spacer()
                ProgressView("Loading professors...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .padding()
                Spacer()
            } else if let error = vm.errorMessage {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
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
                    Text("Showing \(filteredProfessors.count) of \(vm.totalCount) professors")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 4)
                
                // Professor list
                List {
                    ForEach(filteredProfessors) { prof in
                        NavigationLink(destination: DetailView(prof: prof)) {
                            ProfessorRowView(professor: prof)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("\(school) Faculty")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { vm.load() }
    }
}

// Professor row with improved design
struct ProfessorRowView: View {
    let professor: Professor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                // Professor name and department
                VStack(alignment: .leading, spacing: 4) {
                    Text(professor.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(professor.department)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // First initial of name as profile placeholder
                if let initial = professor.name.first {
                    Text(String(initial))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            
            // Research areas as tags
            if !professor.researchAreas.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(professor.researchAreas.prefix(3), id: \.self) { area in
                            Text(area)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                        
                        if professor.researchAreas.count > 3 {
                            Text("+\(professor.researchAreas.count - 3)")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
