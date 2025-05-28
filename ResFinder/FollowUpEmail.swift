import SwiftUI
import UIKit

struct FollowUpEmailView: View {
    let outreachRecord: OutreachRecord

    @StateObject private var outreachViewModel = OutreachViewModel()
    @State private var recipient = ""
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isGenerating = false
    @State private var generationError: String?
    @State private var showingMailAlert = false
    @State private var showingSuccessAlert = false
    @State private var showingTooEarlyAlert = false
    @State private var professorDetails: Professor? = nil
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    private let minimumDaysForFollowUp = 7

    private var canSendFollowUp: Bool {
        outreachRecord.daysSinceContact >= minimumDaysForFollowUp
    }

    private var professorLastName: String {
        let comps = outreachRecord.professorName.split(separator: " ")
        return comps.last.map(String.init) ?? outreachRecord.professorName
    }

    private var bestWebsiteUrl: URL {
        if let profile = outreachRecord.profileUrl { return profile }
        if let prof = professorDetails, prof.id == outreachRecord.professorId {
            return prof.profileUrl
        }
        let q = outreachRecord.professorName.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://www.google.com/search?q=\(q)")!
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Header
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.Colors.buttonSecondary)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Follow‑up Email")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Spacer()

                    // placeholder
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, AppTheme.Spacing.small)

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        // MARK: Original info block
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                            Text("Following up with: \(outreachRecord.professorName)")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text("Original email sent \(outreachRecord.daysSinceContact) days ago")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            Divider()
                                .background(AppTheme.Colors.divider)
                                .padding(.vertical, AppTheme.Spacing.xxxSmall)

                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text("Need the professor's email? Find it on their website:")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }

                            Link(destination: bestWebsiteUrl) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(AppTheme.Colors.accent)
                                    Text(outreachRecord.profileUrl != nil || professorDetails != nil
                                         ? "Visit \(outreachRecord.professorName)'s Website"
                                         : "Search for \(outreachRecord.professorName)")
                                        .foregroundColor(AppTheme.Colors.accent)
                                        .underline()
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(AppTheme.Colors.accent)
                                }
                                .padding(AppTheme.Spacing.xSmall)
                                .background(AppTheme.Colors.accent.opacity(0.1))
                                .cornerRadius(AppTheme.CornerRadius.small)
                            }

                            if !canSendFollowUp {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(AppTheme.Colors.warning)
                                    Text("It's recommended to wait at least \(minimumDaysForFollowUp) days before sending a follow‑up email.")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                                .padding(.top, AppTheme.Spacing.xxxSmall)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.xxSmall)

                        // MARK: Form fields
                        VStack(spacing: AppTheme.Spacing.small) {
                            // To
                            Group {
                                Text("To")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                TextField("", text: $recipient)
                                    .placeholder(when: recipient.isEmpty) {
                                        Text("professor@university.edu")
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
                            .padding(.horizontal, AppTheme.Spacing.small)

                            // Subject
                            Group {
                                Text("Subject")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                TextField("", text: $subject)
                                    .placeholder(when: subject.isEmpty) {
                                        Text("Re: Research Inquiry")
                                            .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                                    }
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .padding()
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)

                            // Body
                            Group {
                                Text("Message")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                if isGenerating {
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                        Text("Generating follow‑up email…")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                                } else {
                                    TextEditor(text: $bodyText)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                        .padding(AppTheme.Spacing.xxSmall)
                                        .frame(minHeight: 200)
                                        .background(AppTheme.Colors.buttonSecondary)
                                        .cornerRadius(AppTheme.CornerRadius.medium)
                                }

                                if let err = generationError {
                                    Text(err)
                                        .foregroundColor(AppTheme.Colors.error)
                                        .font(AppTheme.Typography.caption)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.small)
                        }

                        // MARK: Generate & Send buttons
                        VStack(spacing: AppTheme.Spacing.xSmall) {
                            Button {
                                generateFollowUpTemplate()
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Generate Brief Follow‑up")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isGenerating ? AppTheme.Colors.buttonSecondary : AppTheme.Colors.warning)
                                .foregroundColor(isGenerating ? AppTheme.Colors.secondaryText : AppTheme.Colors.background)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                            .disabled(isGenerating)
                            .padding(.horizontal, AppTheme.Spacing.small)

                            Button {
                                if !canSendFollowUp {
                                    showingTooEarlyAlert = true
                                } else if !isValidEmail(recipient) {
                                    showingMailAlert = true
                                } else {
                                    sendEmail()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Follow‑up Email")
                                }
                                .primaryButton(isEnabled: !recipient.isEmpty && !subject.isEmpty && !bodyText.isEmpty && canSendFollowUp)
                            }
                            .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
                            .padding(.horizontal, AppTheme.Spacing.small)
                        }
                        .padding(.vertical, AppTheme.Spacing.medium)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            subject = "Follow‑up: Research Inquiry"
            if outreachRecord.profileUrl == nil {
                outreachViewModel.fetchProfessorDetails(byId: outreachRecord.professorId) { prof in
                    professorDetails = prof
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateFollowUpTemplate()
            }
        }
        .alert("Invalid Email", isPresented: $showingMailAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a valid email address.")
        }
        .alert("Follow‑up Too Early", isPresented: $showingTooEarlyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("It's recommended to wait at least \(minimumDaysForFollowUp) days before sending a follow‑up email. Only \(outreachRecord.daysSinceContact) days have passed.")
        }
        .alert("Follow‑up Sent", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your follow‑up email has been sent and recorded.")
        }
    }

    // MARK: Helper methods

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func generateFollowUpTemplate() {
        isGenerating = true
        generationError = nil
        OpenRouterService.shared.generateFollowUpEmail(
            for: professorLastName,
            originalEmail: outreachRecord.emailSent,
            daysSinceContact: outreachRecord.daysSinceContact
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let txt):
                    bodyText = removeSubjectLine(from: txt)
                case .failure(let err):
                    generationError = err.localizedDescription
                }
            }
        }
    }

    private func removeSubjectLine(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result = text
        for (i, line) in lines.prefix(3).enumerated() {
            let low = line.lowercased()
            if low.contains("subject:") || low.hasPrefix("re:") {
                let drop = lines.prefix(i + 1).joined(separator: "\n")
                result = result.replacingOccurrences(of: drop, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        return result
    }

    private func sendEmail() {
        let to    = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj  = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body  = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailto = "mailto:\(to)?subject=\(subj)&body=\(body)"

        guard let url = URL(string: mailto) else { return }
        UIApplication.shared.open(url) { success in
            if success {
                outreachViewModel.saveFollowUpEmail(for: outreachRecord, followUpEmail: bodyText)
                showingSuccessAlert = true
            } else {
                generationError = "Failed to open Mail app"
            }
        }
    }
}
