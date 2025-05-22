import SwiftUI

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogin = true
    @State private var showResumeUpload = false
    @State private var showSchoolSelection = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(showingLogin ? "Sign In" : "Create Account")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.black)

                // Form
                if showingLogin {
                    LoginView(showSignUp: $showingLogin)
                        .environmentObject(authViewModel)
                } else {
                    SignUpView(showLogin: $showingLogin)
                        .environmentObject(authViewModel)
                }

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showResumeUpload) {
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
        .onReceive(authViewModel.$isAuthenticated) { isAuth in
            if isAuth {
                showResumeUpload = true
            }
        }
    }
}

// MARK: - Styled Login
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                // Email field
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(focusedField == .email ? .black : .black.opacity(0.6))
                    TextField("Email", text: $email)
                        .foregroundColor(.black)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                }
                .padding(12)
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .email ? Color.black : Color.black.opacity(0.2), lineWidth: 1)
                )

                // Password field
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(focusedField == .password ? .black : .black.opacity(0.6))
                    SecureField("Password", text: $password)
                        .foregroundColor(.black)
                        .focused($focusedField, equals: .password)
                }
                .padding(12)
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .password ? Color.black : Color.black.opacity(0.2), lineWidth: 1)
                )

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 32)

            VStack(spacing: 16) {
                Button(action: signIn) {
                    Text("Sign In")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .disabled(email.isEmpty || password.isEmpty)

                Button(action: { showSignUp = false }) {
                    Text("Don't have an account? Sign Up")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 40)
    }

    private func signIn() {
        authViewModel.signIn(email: email, password: password)
        // Listen for errors
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let err = authViewModel.authError {
                errorMessage = err
            }
        }
    }
}

// MARK: - Styled SignUp
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var major = ""
    @State private var year = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field { case email, password, confirm }
    let yearOptions = ["Freshman","Sophomore","Junior","Senior","Graduate","PhD"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    // Email
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(focusedField == .email ? .black : .black.opacity(0.6))
                        TextField("Email", text: $email)
                            .foregroundColor(.black)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                    }
                    .fieldStyle(focused: focusedField == .email)

                    // Password
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(focusedField == .password ? .black : .black.opacity(0.6))
                        SecureField("Password", text: $password)
                            .foregroundColor(.black)
                            .focused($focusedField, equals: .password)
                    }
                    .fieldStyle(focused: focusedField == .password)

                    // Confirm
                    HStack {
                        Image(systemName: "lock.rotation")
                            .foregroundColor(focusedField == .confirm ? .black : .black.opacity(0.6))
                        SecureField("Confirm Password", text: $confirmPassword)
                            .foregroundColor(.black)
                            .focused($focusedField, equals: .confirm)
                    }
                    .fieldStyle(focused: focusedField == .confirm)

                    // Name
                    TextField("Full Name", text: $name)
                        .padding(12)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(12)
                        .foregroundColor(.black)

                    // Major
                    TextField("Major", text: $major)
                        .padding(12)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(12)
                        .foregroundColor(.black)

                    // Year
                    Picker("Year", selection: $year) {
                        ForEach(yearOptions, id: \ .self) { Text($0) }
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)

                    // Validation
                    if !passwordsMatch {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 32)

                VStack(spacing: 16) {
                    Button(action: signUp) {
                        Text("Sign Up")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                    .disabled(!formComplete)

                    Button(action: { showLogin = true }) {
                        Text("Already have an account? Sign In")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    // MARK: - Helpers
    private var passwordsMatch: Bool { !password.isEmpty && password == confirmPassword }
    private var formComplete: Bool {
        !email.isEmpty && passwordsMatch && !name.isEmpty && !major.isEmpty && !year.isEmpty
    }

    private func signUp() {
        guard passwordsMatch else { return }
        // Store extras
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(major, forKey: "userMajor")
        UserDefaults.standard.set(year, forKey: "userYear")

        authViewModel.signUp(email: email, password: password)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let err = authViewModel.authError {
                errorMessage = err
            }
        }
    }
}

// MARK: - Field Style Modifier
fileprivate extension View {
    func fieldStyle(focused: Bool) -> some View {
        self
            .padding(12)
            .background(Color.black.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? Color.black : Color.black.opacity(0.2), lineWidth: 1)
            )
    }
} 
