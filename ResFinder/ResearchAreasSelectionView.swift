import SwiftUI

struct ResearchAreasSelectionView: View {
    let school: String
    @StateObject private var vm = ProfessorsViewModel()
    @State private var selectedAreas = Set<String>()
    @State private var searchText = ""
    @EnvironmentObject var authViewModel: AuthViewModel

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
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CommonNavigationHeader(title: "\(school) Research Areas")
                    .environmentObject(authViewModel)

                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search research areas")
                                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                        }
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .font(AppTheme.Typography.body)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
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

                if vm.isLoading {
                    Spacer()
                    VStack(spacing: AppTheme.Spacing.small) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                            .scaleEffect(1.2)
                        Text("Loading research areas...")
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
                        Text("\(filteredAreas.count) areas found")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Spacer()
                        if !selectedAreas.isEmpty {
                            Text("\(selectedAreas.count) selected")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.accent)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.top, AppTheme.Spacing.xxSmall)

                    // Areas list
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.xxSmall) {
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
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.xxSmall)
                        .padding(.bottom, 100) // Space for bottom button
                    }
                }

                // Bottom action button
                VStack(spacing: 0) {
                    Divider()
                        .background(AppTheme.Colors.divider)

                    VStack(spacing: AppTheme.Spacing.xxSmall) {
                        NavigationLink(
                            destination: ProfessorsListView(
                                school: school,
                                researchFilters: Array(selectedAreas)
                            )
                            .environmentObject(authViewModel)
                        ) {
                            Text(buttonText)
                                .primaryButton(isEnabled: !selectedAreas.isEmpty)
                        }
                        .disabled(selectedAreas.isEmpty)
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.small)

                        if selectedAreas.isEmpty {
                            Text("Select at least one research area")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.bottom, AppTheme.Spacing.xxSmall)
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.small)
                    .background(AppTheme.Colors.background)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear { vm.load() }
    }

    private var buttonText: String {
        if selectedAreas.isEmpty {
            return "View Professors"
        } else if selectedAreas.count == 1 {
            return "View Professors in Selected Area"
        } else {
            return "View Professors in \(selectedAreas.count) Areas"
        }
    }
}

// Improved selection row with tighter, unindented multi-line text
struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                Text(title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)

                Spacer()

                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.Colors.accent : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected
                                        ? AppTheme.Colors.accent
                                        : AppTheme.Colors.buttonSecondary,
                                    lineWidth: 2
                                )
                        )
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                }
            }
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .padding(.horizontal, AppTheme.Spacing.small)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .contentShape(Rectangle())
        }
    }
}
