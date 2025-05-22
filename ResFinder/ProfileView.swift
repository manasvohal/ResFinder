import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()
    @State private var showingLoginSheet = false
    @State private var showSignUp = true
    @Environment(\.presentationMode) var presentationMode

    private let followUpThresholdDays = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.Colors.buttonSecondary)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Your Profile")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Spacer()
                        
                        // Invisible placeholder for balance
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.vertical, AppTheme.Spacing.small)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            if authViewModel.isAuthenticated {
                                // Account Section
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                    Text("Account")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(AppTheme.Colors.accent)
                                        .padding(.horizontal, AppTheme.Spacing.small)

                                    HStack(spacing: AppTheme.Spacing.small) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.Colors.accent)
                                                .frame(width: 60, height: 60)
                                            Text(getFirstLetter(of: authViewModel.user?.email ?? ""))
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                        }

                                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                                            Text(getDisplayName(from: authViewModel.user?.email ?? ""))
                                                .font(AppTheme.Typography.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                            Text("Signed in")
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                        }

                                        Spacer()

                                        Button(action: {
                                            authViewModel.signOut()
                                        }) {
                                            Text("Sign Out")
                                                .font(AppTheme.Typography.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                                .padding(.horizontal, AppTheme.Spacing.small)
                                                .padding(.vertical, AppTheme.Spacing.xxSmall)
                                                .background(AppTheme.Colors.accent)
                                                .cornerRadius(AppTheme.CornerRadius.pill)
                                        }
                                    }
                                    .padding(AppTheme.Spacing.small)
                                    .darkCard()
                                }

                                // Outreach Section
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                    HStack {
                                        Text("Professor Outreach")
                                            .font(AppTheme.Typography.headline)
                                            .foregroundColor(AppTheme.Colors.accent)
                                        Spacer()
                                        if !outreachViewModel.outreachRecords.isEmpty {
                                            Text("\(outreachViewModel.outreachRecords.count) contacts")
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                                .padding(.horizontal, AppTheme.Spacing.xxSmall)
                                                .padding(.vertical, AppTheme.Spacing.xxxSmall)
                                                .background(AppTheme.Colors.buttonSecondary)
                                                .cornerRadius(AppTheme.CornerRadius.small)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.small)
                                    .padding(.top, AppTheme.Spacing.small)

                                    if outreachViewModel.isLoading {
                                        HStack {
                                            Spacer()
                                            ProgressView("Loading your outreach history...")
                                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                                .padding()
                                            Spacer()
                                        }
                                    } else if let error = outreachViewModel.errorMessage {
                                        Text("Error: \(error)")
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(AppTheme.Colors.error)
                                            .padding()
                                    } else if outreachViewModel.outreachRecords.isEmpty {
                                        VStack(spacing: AppTheme.Spacing.small) {
                                            Spacer().frame(height: AppTheme.Spacing.medium)
                                            Image(systemName: "envelope.badge.shield.half.filled")
                                                .font(.system(size: 50))
                                                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                                                .padding()
                                            Text("No outreach yet")
                                                .font(AppTheme.Typography.headline)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                            Text("When you contact professors, your outreach history will appear here")
                                                .font(AppTheme.Typography.subheadline)
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, AppTheme.Spacing.xLarge)
                                                .padding(.bottom)
                                            Spacer().frame(height: AppTheme.Spacing.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.Spacing.xxLarge)
                                        .darkCard()
                                    } else {
                                        VStack(spacing: AppTheme.Spacing.small) {
                                            ForEach(outreachViewModel.outreachRecords) { record in
                                                EnhancedOutreachRecordRow(
                                                    record: record,
                                                    followUpThresholdDays: followUpThresholdDays
                                                )
                                            }
                                        }
                                        .padding(.bottom, AppTheme.Spacing.medium)
                                    }
                                }
                            } else {
                                // Not logged in
                                VStack(spacing: AppTheme.Spacing.large) {
                                    Spacer().frame(height: AppTheme.Spacing.xxLarge)
                                    Image(systemName: "person.badge.shield.checkmark")
                                        .font(.system(size: 70))
                                        .foregroundColor(AppTheme.Colors.accent.opacity(0.8))
                                        .padding(.bottom, AppTheme.Spacing.small)
                                    Text("Sign in to Track Your Outreach")
                                        .font(AppTheme.Typography.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                        .multilineTextAlignment(.center)
                                    Text("Create an account to keep track of professors you've contacted and when you need to follow up")
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppTheme.Spacing.xLarge)
                                        .padding(.bottom, AppTheme.Spacing.xxSmall)
                                    Button(action: {
                                        showingLoginSheet = true
                                    }) {
                                        Text("Sign In / Sign Up")
                                            .primaryButton()
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.xxLarge)
                                    .padding(.top, AppTheme.Spacing.xxSmall)
                                    Spacer()
                                }
                                .padding(.vertical, AppTheme.Spacing.xxLarge)
                                .darkCard()
                                .padding(.horizontal, AppTheme.Spacing.small)
                                .padding(.vertical, AppTheme.Spacing.medium)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.small)
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onAppear {
                if authViewModel.isAuthenticated {
                    outreachViewModel.loadOutreachRecords()
                }
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    outreachViewModel.loadOutreachRecords()
                }
            }
            .sheet(isPresented: $showingLoginSheet) {
                NavigationView {
                    LoginView(showSignUp: $showSignUp)
                        .environmentObject(authViewModel)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func getDisplayName(from email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.first ?? email
    }

    private func getFirstLetter(of email: String) -> String {
        return String(email.prefix(1)).uppercased()
    }
}
