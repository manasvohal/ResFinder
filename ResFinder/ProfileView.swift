import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()
    @State private var showingLoginSheet = false
    @State private var showSignUp = true // Add this state variable
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
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
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text(authViewModel.user?.email ?? "")
                                    .font(.subheadline)
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
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
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
                        Text("Professor Outreach")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                        
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
                            VStack {
                                Image(systemName: "envelope.badge.shield.half.filled")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                Text("No outreach yet")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("When you contact professors, your outreach history will appear here")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        } else {
                            List {
                                ForEach(outreachViewModel.outreachRecords) { record in
                                    OutreachRecordRow(record: record)
                                }
                                .listRowBackground(Color(.systemBackground))
                            }
                            .listStyle(InsetGroupedListStyle())
                        }
                    }
                } else {
                    // Not logged in view
                    VStack(spacing: 24) {
                        Image(systemName: "person.badge.shield.checkmark")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding(.top, 40)
                        
                        Text("Sign in to Track Your Outreach")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Create an account to keep track of professors you've contacted and when you need to follow up")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
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
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    .padding()
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
                    // Fix: Pass the required showSignUp binding parameter
                    LoginView(showSignUp: $showSignUp)
                        .environmentObject(authViewModel)
                }
            }
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            )
        }
    }
}

// Make sure you have this struct defined in your code
struct OutreachRecordRow: View {
    let record: OutreachRecord
    @State private var showingFollowUpView = false
    
    var body: some View {
        NavigationLink(destination: record.needsFollowUp ? FollowUpEmailView(outreachRecord: record) : nil,
                       isActive: $showingFollowUpView) {
            EmptyView()
        }
        .hidden()
        
        VStack(alignment: .leading, spacing: 8) {
            // Your OutreachRecordRow implementation...
            Text(record.professorName)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Other view components...
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
