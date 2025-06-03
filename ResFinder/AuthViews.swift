import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogin = true
    @State private var showResumeUpload = false
    @State private var showSchoolSelection = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header (removed the X button)
                    HStack {
                        // Leading spacer to center title
                        Color.clear
                            .frame(width: 44, height: 44)

                        Spacer()

                        Text(showingLogin ? "Sign In" : "Create Account")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Spacer()

                        // Invisible placeholder
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.vertical, AppTheme.Spacing.small)

                    if showingLogin {
                        LoginView(showSignUp: $showingLogin)
                            .environmentObject(authViewModel)
                    } else {
                        SignUpView(showSignIn: $showingLogin)
                            .environmentObject(authViewModel)
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showResumeUpload = true
                    }
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
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Binding var showSignUp: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.xxLarge)
                    .padding(.bottom, AppTheme.Spacing.large)

                VStack(spacing: AppTheme.Spacing.small) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                        Text("Email")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("Enter your email")
                                    .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                            }
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(AppTheme.Colors.buttonSecondary)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                        Text("Password")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        SecureField("", text: $password)
                            .placeholder(when: password.isEmpty) {
                                Text("Enter your password")
                                    .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                            }
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding()
                            .background(AppTheme.Colors.buttonSecondary)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                    if let error = authViewModel.authError {
                        Text(error)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.error)
                            .multilineTextAlignment(.center)
                            .padding(.top, AppTheme.Spacing.xxSmall)
                    }
                }
                .padding(.horizontal)

                VStack(spacing: AppTheme.Spacing.small) {
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                    }) {
                        HStack {
                            Text("Sign In")
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.background))
                                    .scaleEffect(0.8)
                                    .padding(.leading, AppTheme.Spacing.xxSmall)
                            }
                        }
                        .primaryButton(isEnabled: !email.isEmpty && !password.isEmpty && !authViewModel.isLoading)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

                    Button(action: {
                        showSignUp = false
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    .padding(.top, AppTheme.Spacing.xxSmall)
                }
                .padding(.horizontal)
                .padding(.top, AppTheme.Spacing.medium)

                Spacer(minLength: AppTheme.Spacing.xxLarge)
            }
        }
        .background(AppTheme.Colors.background)
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

    let yearOptions = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate Student", "PhD Student"]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.medium) {
                    // Account Information
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Account Information")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.accent)
                        VStack(spacing: AppTheme.Spacing.small) {
                            CustomTextField(title: "Email", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)
                            CustomSecureField(title: "Password", text: $password, placeholder: "Create a password")
                            CustomSecureField(title: "Confirm Password", text: $confirmPassword, placeholder: "Confirm your password")
                        }
                    }
                    // Personal Information
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Personal Information")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.accent)
                        VStack(spacing: AppTheme.Spacing.small) {
                            CustomTextField(title: "Full Name", text: $name, placeholder: "Enter your name")
                            CustomTextField(title: "Major", text: $major, placeholder: "e.g., Computer Science")
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                                Text("Academic Year")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Menu {
                                    ForEach(yearOptions, id: \.self) { yearOption in
                                        Button(yearOption) { year = yearOption }
                                    }
                                } label: {
                                    HStack {
                                        Text(year.isEmpty ? "Select Year" : year)
                                            .foregroundColor(year.isEmpty ? AppTheme.Colors.secondaryText.opacity(0.5) : AppTheme.Colors.primaryText)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                                }
                            }
                        }
                    }
                    if passwordMismatch {
                        Text("Passwords do not match")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.error)
                    }
                    if let error = authViewModel.authError {
                        Text(error)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                VStack(spacing: AppTheme.Spacing.small) {
                    Button(action: {
                        if password == confirmPassword {
                            passwordMismatch = false
                            UserDefaults.standard.set(name, forKey: "userName")
                            UserDefaults.standard.set(major, forKey: "userMajor")
                            UserDefaults.standard.set(year, forKey: "userYear")
                            authViewModel.signUp(email: email, password: password)
                        } else {
                            passwordMismatch = true
                        }
                    }) {
                        HStack {
                            Text("Sign Up")
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.background))
                                    .scaleEffect(0.8)
                                    .padding(.leading, AppTheme.Spacing.xxSmall)
                            }
                        }
                        .primaryButton(isEnabled: !isFormIncomplete && !authViewModel.isLoading)
                    }
                    .disabled(isFormIncomplete || authViewModel.isLoading)

                    Button(action: {
                        showSignIn = true
                    }) {
                        Text("Already have an account? Sign In")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    .padding(.top, AppTheme.Spacing.xxSmall)
                }
                .padding(.horizontal)
                .padding(.top, AppTheme.Spacing.medium)

                Spacer(minLength: AppTheme.Spacing.xxLarge)
            }
            .padding(.top, AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background)
    }

    private var isFormIncomplete: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
        name.isEmpty || major.isEmpty || year.isEmpty
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                }
                .foregroundColor(AppTheme.Colors.primaryText)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding()
                .background(AppTheme.Colors.buttonSecondary)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
            SecureField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                }
                .foregroundColor(AppTheme.Colors.primaryText)
                .padding()
                .background(AppTheme.Colors.buttonSecondary)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
