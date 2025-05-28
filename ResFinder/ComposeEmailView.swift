import SwiftUI
import UIKit

struct ComposeEmailView: View {
    let prof: Professor

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()

    @State private var recipient      = ""
    @State private var subject        = ""
    @State private var bodyText       = ""
    @State private var isGenerating   = false
    @State private var generationError: String?
    @State private var showingMailAlert = false
    @State private var showingSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom nav header
                CommonNavigationHeader(title: "Email \(prof.name)")
                    .environmentObject(authViewModel)

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // MARK: Website link card
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
                                    Image(systemName: "globe").foregroundColor(.blue)
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

                        // MARK: Form
                        VStack(spacing: AppTheme.Spacing.small) {
                            Group {
                                Text("To").font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                TextField("professor@university.edu", text: $recipient)
                                    .keyboardType(.emailAddress).autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)

                            Group {
                                Text("Subject").font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                TextField("Research Interest", text: $subject)
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)

                            Group {
                                Text("Body").font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                if isGenerating {
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                            .scaleEffect(1.2)
                                        Text("Generating email…")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 200)
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
                                        Image(systemName: "info.circle").foregroundColor(.orange)
                                        Text("Resume data unavailable. Your email may not be fully personalized.")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)
                        }

                        // MARK: Buttons
                        VStack(spacing: AppTheme.Spacing.small) {
                            Button {
                                generateTemplate()
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text(hasUploadedResume ? "Generate Personalized Email" : "Generate Template")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.accent)
                                .foregroundColor(.white)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                            .disabled(isGenerating)

                            Button {
                                if !isValidEmail(recipient) {
                                    showingMailAlert = true
                                } else {
                                    sendEmail()
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
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            subject = "Research Interest"
            // Optionally prefill “to” from the professor’s mailto:
            if let mailto = prof.profileUrl.absoluteString.split(separator: "mailto:").last,
               isValidEmail(String(mailto)) {
                recipient = String(mailto)
            }
        }
        .alert("Invalid Email", isPresented: $showingMailAlert) {
            Button("OK", role: .cancel) { }
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
    }

    // MARK: Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
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
        let to    = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj  = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body  = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailto = "mailto:\(to)?subject=\(subj)&body=\(body)"

        guard let url = URL(string: mailto) else { return }
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
