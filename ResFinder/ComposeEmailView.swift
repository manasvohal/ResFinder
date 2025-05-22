import SwiftUI

struct ComposeEmailView: View {
    let prof: Professor

    @State private var recipient = ""
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isGenerating = false
    @State private var generationError: String?
    @State private var showingMailAlert = false
    @State private var showingLoginAlert = false
    @State private var showingSuccessAlert = false
    @State private var showSignUp = true

    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CommonNavigationHeader(title: "Email \(prof.name)")
                    .environmentObject(authViewModel)

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // MARK: Website Link Card
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            HStack(spacing: AppTheme.Spacing.xSmall) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Need the professor's email? Find it on their website:")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }

                            Link(destination: prof.profileUrl) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                    Text("Visit \(prof.name)'s Website")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.blue)
                                        .underline()
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(AppTheme.Colors.accent.opacity(0.1))
                                .cornerRadius(AppTheme.CornerRadius.small)
                            }
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.CornerRadius.large)

                        // MARK: Email Form (fields styled like follow-up page)
                        VStack(spacing: AppTheme.Spacing.small) {
                            // To field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                                Text("To")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                TextField("professor@university.edu", text: $recipient)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)

                            // Subject field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                                Text("Subject")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                TextField("Research Interest", text: $subject)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)

                            // Body field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                                Text("Body")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                if isGenerating {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                            .scaleEffect(1.2)
                                        Spacer()
                                    }
                                    .frame(height: 200)
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                                } else {
                                    TextEditor(text: $bodyText)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                        .padding()
                                        .background(AppTheme.Colors.buttonSecondary)
                                        .cornerRadius(AppTheme.CornerRadius.medium)
                                        .frame(minHeight: 200)
                                }

                                if let err = generationError {
                                    Text(err)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.error)
                                }

                                if !hasUploadedResume {
                                    HStack(spacing: AppTheme.Spacing.xxSmall) {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.orange)
                                        Text("Resume data unavailable. Your email may not be fully personalized.")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)
                        }
                        // remove .darkCard() wrapper here
                        // so each field stands alone like follow-up page

                        // MARK: Buttons
                        VStack(spacing: AppTheme.Spacing.small) {
                            Button {
                                generateTemplate()
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text(hasUploadedResume
                                            ? "Generate Personalized Email"
                                            : "Generate Template")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.accent)
                                .foregroundColor(.white)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                            .disabled(isGenerating)

                            Button {
                                if isValidEmail(recipient) {
                                    sendEmail()
                                } else {
                                    showingMailAlert = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Email")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.buttonSecondary)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                            .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.bottom, AppTheme.Spacing.large)
                    }
                    .padding(.top, AppTheme.Spacing.small)
                }
            }
        }
        .alert("Invalid Email", isPresented: $showingMailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid email address.")
        }
        .alert("Email Sent", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your email has been sent and will be tracked in your profile.")
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            // Pre-fill fields
            subject = "Research Interest"
            if let email = prof.profileUrl.absoluteString.components(separatedBy: "mailto:").last,
               isValidEmail(email) {
                recipient = email
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: email)
    }

    private func generateTemplate() {
        isGenerating = true
        generationError = nil
        let lastName = prof.name.split(separator: " ").last.map(String.init) ?? prof.name
        OpenRouterService.shared.generateEmailBody(
            for: prof.researchAreas,
            professorLastName: lastName
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let txt): bodyText = txt
                case .failure(let err): generationError = err.localizedDescription
                }
            }
        }
    }

    private func sendEmail() {
        guard authViewModel.isAuthenticated else {
            showingLoginAlert = true
            return
        }
        let to = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(to)?subject=\(subj)&body=\(body)") {
            UIApplication.shared.open(url) { success in
                if success {
                    outreachViewModel.saveOutreachRecord(
                        for: prof,
                        emailSent: bodyText
                    )
                    showingSuccessAlert = true
                } else {
                    generationError = "Failed to open Mail app"
                }
            }
        }
    }
}
