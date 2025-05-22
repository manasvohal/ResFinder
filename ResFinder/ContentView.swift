import SwiftUI

struct ContentView: View {
    private let schools: [(name: String, imageName: String, description: String)] = [
        ("UMD", "umd_logo", "University of Maryland"),
        ("Rutgers", "rutgers_logo", "Rutgers University")
    ]

    @State private var showResumeUpload = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    private var displayName: String {
        if !userName.isEmpty {
            return userName
        }
        if let email = authViewModel.user?.email {
            return String(email.split(separator: "@")[0])
        }
        return ""
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.Colors.buttonSecondary)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Select University")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    Spacer()
                    
                    ProfileButton()
                }
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, AppTheme.Spacing.small)
                
                // Resume info bar
                if hasUploadedResume {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(AppTheme.Colors.accent)
                        
                        Text("Resume uploaded for \(displayName)")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            showResumeUpload = true
                        }) {
                            Text("Edit")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(.horizontal, AppTheme.Spacing.xSmall)
                                .padding(.vertical, AppTheme.Spacing.xxxSmall)
                                .background(AppTheme.Colors.accent)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                        }
                    }
                    .padding(AppTheme.Spacing.small)
                    .background(AppTheme.Colors.cardBackground)
                }
                
                // School list
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.small) {
                        ForEach(schools, id: \.name) { school in
                            NavigationLink(
                                destination:
                                    RecommendationView(school: school.name)
                                        .environmentObject(authViewModel)
                            ) {
                                SchoolCardView(
                                    name: school.name,
                                    logoName: school.imageName,
                                    description: school.description
                                )
                            }
                        }
                    }
                    .padding(.top, AppTheme.Spacing.medium)
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.bottom, AppTheme.Spacing.large)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showResumeUpload) {
            ResumeUploadView(isSheet: true)
                .environmentObject(authViewModel)
        }
    }
}

// MARK: - SchoolCardView
struct SchoolCardView: View {
    let name: String
    let logoName: String
    let description: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            // Logo container
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.buttonSecondary)
                    .frame(width: 60, height: 60)
                
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding(.leading, AppTheme.Spacing.xxSmall)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                Text(name)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(description)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .padding(.trailing, AppTheme.Spacing.xxSmall)
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .padding(.horizontal, AppTheme.Spacing.small)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}
