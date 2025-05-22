import SwiftUI

struct ProfessorsListView: View {
    let school: String
    let researchFilters: [String]
    
    @StateObject private var vm = ProfessorsViewModel()
    @State private var searchText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Filter professors
    private var filteredProfessors: [Professor] {
        vm.professors
            .filter { $0.university.caseInsensitiveCompare(school) == .orderedSame }
            .filter { prof in
                guard !researchFilters.isEmpty else { return true }
                return !Set(prof.researchAreas)
                    .intersection(Set(researchFilters))
                    .isEmpty
            }
            .filter { prof in
                guard !searchText.isEmpty else { return true }
                let term = searchText.lowercased()
                return prof.name.lowercased().contains(term)
                    || prof.department.lowercased().contains(term)
                    || prof.researchAreas.contains { $0.lowercased().contains(term) }
            }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CommonNavigationHeader(title: "\(school) Faculty")
                    .environmentObject(authViewModel)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search faculty by name or department")
                                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                        }
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .font(AppTheme.Typography.body)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                }
                .padding(AppTheme.Spacing.xSmall)
                .background(AppTheme.Colors.buttonSecondary)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.top, AppTheme.Spacing.xSmall)
                
                // Filter chips
                if !researchFilters.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.xxSmall) {
                            ForEach(researchFilters, id: \.self) { filter in
                                Text(filter)
                                    .font(AppTheme.Typography.caption)
                                    .padding(.horizontal, AppTheme.Spacing.xSmall)
                                    .padding(.vertical, AppTheme.Spacing.xxxSmall)
                                    .background(AppTheme.Colors.accent.opacity(0.2))
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.vertical, AppTheme.Spacing.xxSmall)
                    }
                }
                
                if vm.isLoading {
                    Spacer()
                    VStack(spacing: AppTheme.Spacing.small) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                            .scaleEffect(1.2)
                        Text("Loading professors...")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    Spacer()
                } else if let error = vm.errorMessage {
                    Spacer()
                    VStack(spacing: AppTheme.Spacing.small) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.Colors.error)
                            .padding()
                        
                        Text("Error")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.bottom, AppTheme.Spacing.xxxSmall)
                        
                        Text(error)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    // Results count
                    HStack {
                        Text("Showing \(filteredProfessors.count) of \(vm.totalCount) professors")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.top, AppTheme.Spacing.xxxSmall)
                    
                    // Professor list
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.small) {
                            ForEach(filteredProfessors) { prof in
                                NavigationLink(destination: DetailView(prof: prof).environmentObject(authViewModel)) {
                                    ModernProfessorRow(professor: prof)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.xxSmall)
                        .padding(.bottom, AppTheme.Spacing.large)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear { vm.load() }
    }
}
