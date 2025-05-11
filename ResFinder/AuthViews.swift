import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogin = true
    @State private var showResumeUpload = false
    @State private var showSchoolSelection = false
    @State private var debugMessage = "Waiting for auth..."
    
    var body: some View {
        VStack(spacing: 0) {
            // Red header bar
            HStack {
                Text(showingLogin ? "Sign In" : "Create Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Debug info - remove in production
                if debugMessage != "Waiting for auth..." {
                    Text(debugMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color.red)
            
            if showingLogin {
                LoginView(showSignUp: $showingLogin)
                    .environmentObject(authViewModel)
            } else {
                SignUpView(showSignIn: $showingLogin)
                    .environmentObject(authViewModel)
            }
            
            // Debug controls - remove in production
            HStack {
                Text("Auth: \(authViewModel.isAuthenticated ? "Yes" : "No")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if authViewModel.isAuthenticated {
                    Button("Manual Continue") {
                        showResumeUpload = true
                    }
                    .font(.caption)
                    .padding(6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
            self.debugMessage = isAuthenticated ? "Authenticated ✓" : "Not authenticated"
            print("AuthContainerView: isAuthenticated changed to \(isAuthenticated)")
            
            if isAuthenticated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showResumeUpload = true
                }
            }
        }
        .fullScreenCover(isPresented: $showResumeUpload) {
            // After resume upload, we'll navigate to the school selection
            ResumeUploadView(
                isSheet: false,
                onComplete: {
                    showResumeUpload = false
                    showSchoolSelection = true
                }
            )
            .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $showSchoolSelection) {
            NavigationView {
                ContentView()
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Binding var showSignUp: Bool
    @State private var authState = "Not authenticated"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Form fields
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    if let error = authViewModel.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Debug auth state info - can remove after fixing
                    Text("Auth State: \(authState)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                    }) {
                        HStack {
                            Text("Sign In")
                                .fontWeight(.semibold)
                            
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 4)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                    .opacity(email.isEmpty || password.isEmpty || authViewModel.isLoading ? 0.6 : 1)
                    
                    Button(action: {
                        showSignUp = false
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
                self.authState = isAuthenticated ? "Authenticated" : "Not authenticated"
                print("LoginView: Auth state changed to \(isAuthenticated)")
            }
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordMismatch = false
    @State private var name = ""
    @State private var major = ""
    @State private var year = ""
    @Binding var showSignIn: Bool
    
    // Year options
    let yearOptions = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate Student", "PhD Student"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Form fields
                VStack(spacing: 20) {
                    // Account Information Section
                    Group {
                        Text("Account Information")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    // Personal Information Section
                    Group {
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                        
                        TextField("Full Name", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        TextField("Major (e.g., Computer Science)", text: $major)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Picker("Academic Year", selection: $year) {
                            Text("Select Year").tag("")
                            ForEach(yearOptions, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    if passwordMismatch {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if let error = authViewModel.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        if password == confirmPassword {
                            passwordMismatch = false
                            
                            // Save the user information to UserDefaults first
                            UserDefaults.standard.set(name, forKey: "userName")
                            UserDefaults.standard.set(major, forKey: "userMajor")
                            UserDefaults.standard.set(year, forKey: "userYear")
                            
                            // Then create the account
                            authViewModel.signUp(email: email, password: password)
                        } else {
                            passwordMismatch = true
                        }
                    }) {
                        HStack {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                            
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 4)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .disabled(isFormIncomplete || authViewModel.isLoading)
                    .opacity(isFormIncomplete || authViewModel.isLoading ? 0.6 : 1)
                    
                    Button(action: {
                        showSignIn = true
                    }) {
                        Text("Already have an account? Sign In")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
    
    private var isFormIncomplete: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
        name.isEmpty || major.isEmpty || year.isEmpty
    }
}
