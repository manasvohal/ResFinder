import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()
    @State private var showingLoginSheet = false
    @State private var showSignUp = true
    @Environment(\.presentationMode) var presentationMode
    
    // For testing - set follow-up threshold to 0 days for immediate testing
    private let followUpThresholdDays = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Title with red background
                    Text("Your Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                    
                    if authViewModel.isAuthenticated {
                        // User info section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Account")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.bottom, 4)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 16) {
                                // User avatar with first letter of email
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                    
                                    Text(getFirstLetter(of: authViewModel.user?.email ?? ""))
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(getDisplayName(from: authViewModel.user?.email ?? ""))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("Signed in")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    authViewModel.signOut()
                                }) {
                                    Text("Sign Out")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        }
                        .padding(.top, 16)
                        
                        // Professor outreach section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Professor Outreach")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                                
                                Text("\(outreachViewModel.outreachRecords.count) contacts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            
                            if outreachViewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading your outreach history...")
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                        .padding()
                                    Spacer()
                                }
                            } else if let error = outreachViewModel.errorMessage {
                                Text("Error: \(error)")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if outreachViewModel.outreachRecords.isEmpty {
                                VStack(spacing: 16) {
                                    Spacer()
                                        .frame(height: 20)
                                    
                                    Image(systemName: "envelope.badge.shield.half.filled")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding()
                                    
                                    Text("No outreach yet")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("When you contact professors, your outreach history will appear here")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                        .padding(.bottom)
                                    
                                    Spacer()
                                        .frame(height: 20)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                                )
                                .padding(.horizontal)
                            } else {
                                // Enhanced outreach records display
                                VStack(spacing: 16) {
                                    ForEach(outreachViewModel.outreachRecords) { record in
                                        EnhancedOutreachRecordRow(
                                            record: record,
                                            followUpThresholdDays: followUpThresholdDays
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    } else {
                        // Not logged in view
                        VStack(spacing: 24) {
                            Spacer()
                                .frame(height: 40)
                            
                            Image(systemName: "person.badge.shield.checkmark")
                                .font(.system(size: 70))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.bottom, 16)
                            
                            Text("Sign in to Track Your Outreach")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Create an account to keep track of professors you've contacted and when you need to follow up")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                showingLoginSheet = true
                            }) {
                                Text("Sign In / Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 200)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 8)
                            
                            Spacer()
                        }
                        .padding(.vertical, 60)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
                .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper to get only the username part of the email
    private func getDisplayName(from email: String) -> String {
        if email.isEmpty { return "" }
        
        // Get everything before the @ symbol
        let components = email.components(separatedBy: "@")
        if components.count > 0 {
            return components[0]
        }
        return email
    }
    
    // Helper to get the first letter of the email for the avatar
    private func getFirstLetter(of email: String) -> String {
        if email.isEmpty { return "?" }
        
        // Get the first character of the email
        return String(email.prefix(1)).uppercased()
    }
}
