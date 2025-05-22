import SwiftUI

struct RecommendationView: View {
    let school: String

    @StateObject private var vm = RecommendationViewModel()
    @AppStorage("resumeText") private var resumeText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToResearchAreas = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Updated header title
                CommonNavigationHeader(title: "Recommended Prof.")
                    .environmentObject(authViewModel)

                if vm.isLoading {
                    Spacer()
                    VStack(spacing: AppTheme.Spacing.small) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                            .scaleEffect(1.2)
                        Text("Finding best matches…")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.small) {
                            ForEach(vm.recommendations) { prof in
                                NavigationLink(
                                    destination: ComposeEmailView(prof: prof)
                                        .environmentObject(authViewModel)
                                ) {
                                    ModernProfessorRow(professor: prof)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.small)
                        .padding(.bottom, 100) // Space for bottom button
                    }
                }

                Spacer()

                // Stylized bottom button
                VStack(spacing: 0) {
                    Divider()
                        .background(AppTheme.Colors.divider)

                    Button(action: {
                        navigateToResearchAreas = true
                    }) {
                        Text("Can't see a good match? Select by Research Area")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .padding(.horizontal, AppTheme.Spacing.small)
                            .padding(.vertical, AppTheme.Spacing.xSmall)
                    }
                }
                .background(AppTheme.Colors.background)

                NavigationLink(
                    destination: ResearchAreasSelectionView(school: school)
                        .environmentObject(authViewModel),
                    isActive: $navigateToResearchAreas
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            vm.loadRecommendations(for: school, resumeText: resumeText)
        }
    }
}

// Modern Professor Row for dark theme
struct ModernProfessorRow: View {
    let professor: Professor

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack(alignment: .center, spacing: AppTheme.Spacing.small) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.2))
                        .frame(width: 50, height: 50)
                    if let initial = professor.name.first {
                        Text(String(initial))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }

                // Name and department
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                    Text(professor.name)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text(professor.department)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            // Research areas tags (up to 3 shown)
            if !professor.researchAreas.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.xxxSmall) {
                        ForEach(professor.researchAreas.prefix(3), id: \.self) { area in
                            Text(area)
                                .font(AppTheme.Typography.caption2)
                                .padding(.horizontal, AppTheme.Spacing.xxSmall)
                                .padding(.vertical, AppTheme.Spacing.xxxSmall)
                                .background(AppTheme.Colors.accent.opacity(0.2))
                                .foregroundColor(AppTheme.Colors.accent)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                        if professor.researchAreas.count > 3 {
                            Text("+\(professor.researchAreas.count - 3)")
                                .font(AppTheme.Typography.caption2)
                                .padding(.horizontal, AppTheme.Spacing.xxSmall)
                                .padding(.vertical, AppTheme.Spacing.xxxSmall)
                                .background(AppTheme.Colors.buttonSecondary)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.small)
        .darkCard()
    }
}
