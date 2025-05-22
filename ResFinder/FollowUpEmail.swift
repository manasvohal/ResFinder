import SwiftUI

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
        return outreachRecord.daysSinceContact >= minimumDaysForFollowUp
    }
    
    private var professorLastName: String {
        let components = outreachRecord.professorName.components(separatedBy: " ")
        if components.count > 1 {
            return components.last ?? ""
        }
        return outreachRecord.professorName
    }
    
    private var bestWebsiteUrl: URL {
        if let profileUrl = outreachRecord.profileUrl {
            return profileUrl
        }
        
        if let professor = professorDetails, professor.id == outreachRecord.professorId {
            return professor.profileUrl
        }
        
        return URL(string: "https://www.google.com/search?q=\(outreachRecord.professorName.replacingOccurrences(of: " ", with: "+"))") ?? URL(string: "https://www.google.com")!
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
                    
                    Text("Follow-up Email")
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
                        // Original email info
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                            Text("Following up with: \(outreachRecord.professorName)")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text("Original email sent \(outreachRecord.daysSinceContact) days ago")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            
                            // Professor's website link
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
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
                                        
                                        if outreachRecord.profileUrl != nil || professorDetails != nil {
                                            Text("Visit \(outreachRecord.professorName)'s Website")
                                                .foregroundColor(AppTheme.Colors.accent)
                                                .underline()
                                        } else {
                                            Text("Search for \(outreachRecord.professorName)")
                                                .foregroundColor(AppTheme.Colors.accent)
                                                .underline()
                                        }
                                        
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(AppTheme.Colors.accent)
                                    }
                                    .padding(AppTheme.Spacing.xSmall)
                                    .background(AppTheme.Colors.accent.opacity(0.1))
                                    .cornerRadius(AppTheme.CornerRadius.small)
                                }
                            }
                            
                            // Warning if not enough days have passed
                            if !canSendFollowUp {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(AppTheme.Colors.warning)
                                    Text("It's recommended to wait at least \(minimumDaysForFollowUp) days before sending a follow-up email.")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                                .padding(.top, AppTheme.Spacing.xxxSmall)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.top, AppTheme.Spacing.xxSmall)
                        
                        // Email form
                        VStack(spacing: AppTheme.Spacing.small) {
                            // To field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
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
                            
                            // Subject field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
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
                            
                            // Body field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                                Text("Message")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                
                                if isGenerating {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: AppTheme.Spacing.small) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                            Text("Generating follow-up email...")
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                        }
                                        .padding(AppTheme.Spacing.xxLarge)
                                        Spacer()
                                    }
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                                    .frame(height: 200)
                                } else {
                                    TextEditor(text: $bodyText)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                        .frame(minHeight: 200)
                                        .padding(AppTheme.Spacing.xxSmall)
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
                        
                        // Buttons
                        VStack(spacing: AppTheme.Spacing.xSmall) {
                            Button(action: {
                                generateFollowUpTemplate()
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Generate Brief Follow-up")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.small)
                                .background(isGenerating ? AppTheme.Colors.buttonSecondary : AppTheme.Colors.warning)
                                .foregroundColor(isGenerating ? AppTheme.Colors.secondaryText : AppTheme.Colors.background)
                                .cornerRadius(AppTheme.CornerRadius.pill)
                            }
                            .disabled(isGenerating)
                            .padding(.horizontal, AppTheme.Spacing.small)
                            
                            Button(action: {
                                if !canSendFollowUp {
                                    showingTooEarlyAlert = true
                                } else if isValidEmail(recipient) {
                                    sendEmail()
                                } else {
                                    showingMailAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Follow-up Email")
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
            subject = "Follow-up: Research Inquiry"
            
            if outreachRecord.profileUrl == nil {
                outreachViewModel.fetchProfessorDetails(byId: outreachRecord.professorId) { professor in
                    self.professorDetails = professor
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateFollowUpTemplate()
            }
        }
        .alert(isPresented: $showingMailAlert) {
            Alert(
                title: Text("Invalid Email"),
                message: Text("Please enter a valid email address."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showingTooEarlyAlert) {
            Alert(
                title: Text("Follow-up Too Early"),
                message: Text("It's recommended to wait at least \(minimumDaysForFollowUp) days before sending a follow-up email. Only \(outreachRecord.daysSinceContact) days have passed since your initial email."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Follow-up Sent"),
                message: Text("Your follow-up email has been sent and recorded."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // Helper methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
        
        for (index, line) in lines.prefix(3).enumerated() {
            let lowercaseLine = line.lowercased()
            if lowercaseLine.contains("subject:") ||
               lowercaseLine.contains("re:") ||
               lowercaseLine.hasPrefix("subject") {
                let componentsToRemove = lines.prefix(index + 2).joined(separator: "\n")
                result = result.replacingOccurrences(of: componentsToRemove, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        return result
    }
    
    private func sendEmail() {
        let to = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(subj)&body=\(body)"
        
        if let url = URL(string: urlString) {
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
}
