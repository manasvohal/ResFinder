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
            AppTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CommonNavigationHeader(title: "Email \(prof.name)")
                    .environmentObject(authViewModel)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Professor website link
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Need the professor's email? Find it on their website:")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            
                            Link(destination: prof.profileUrl) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "globe")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                    
                                    Text("Visit \(prof.name)'s Website")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(.blue)
                                        .underline()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                }
                                .padding(16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(20)
                        .darkCard()
                        // Email form
                        VStack(spacing: 20) {
                            // To field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("To")
                                    .font(AppTheme.headlineFont)
                                    .foregroundColor(AppTheme.primaryRed)
                                
                                TextField("prof@example.edu", text: $recipient)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.primaryText)
                                    .padding(16)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Subject field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subject")
                                    .font(AppTheme.headlineFont)
                                    .foregroundColor(AppTheme.primaryRed)
                                
                                TextField("Research Interest", text: $subject)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.primaryText)
                                    .padding(16)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                            
                            // Body field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Body")
                                    .font(AppTheme.headlineFont)
                                    .foregroundColor(AppTheme.primaryRed)
                                
                                if isGenerating {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryRed))
                                            .scaleEffect(1.2)
                                        
                                        Text("Generating personalized email...")
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                                } else {
                                    ZStack(alignment: .topLeading) {
                                        if bodyText.isEmpty {
                                            Text("Your email content will appear here...")
                                                .font(AppTheme.bodyFont)
                                                .foregroundColor(AppTheme.secondaryText)
                                                .padding(16)
                                        }
                                        
                                        TextEditor(text: $bodyText)
                                            .font(AppTheme.bodyFont)
                                            .foregroundColor(AppTheme.primaryText)
                                            .padding(8)
                                            .background(Color.clear)
                                    }
                                    .frame(minHeight: 200)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                                
                                if let err = generationError {
                                    Text(err)
                                        .foregroundColor(.red)
                                        .font(AppTheme.captionFont)
                                }
                                
                                if !hasUploadedResume {
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.orange)
                                        Text("Resume data unavailable. Your email may not be fully personalized.")
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(20)
                        .darkCard()
                        // Buttons
                        VStack(spacing: 16) {
                            // Generate button
                            Button(action: {
                                generateTemplate()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                    Text(hasUploadedResume ? "Generate Personalized Email" : "Generate Template")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isGenerating ? AppTheme.secondaryBackground : Color.orange)
                                .cornerRadius(AppTheme.buttonCornerRadius)
                            }
                            .disabled(isGenerating)
                            
                            // Send button
                            Button(action: {
                                if isValidEmail(recipient) {
                                    sendEmail()
                                } else {
                                    showingMailAlert = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16))
                                    Text("Send Email")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    recipient.isEmpty || subject.isEmpty || bodyText.isEmpty
                                    ? AppTheme.secondaryBackground
                                    : Color.blue
                                )
                                .cornerRadius(AppTheme.buttonCornerRadius)
                            }
                            .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            subject = "Research Interest"
            
            if let email = prof.profileUrl.absoluteString.components(separatedBy: "mailto:").last,
               isValidEmail(email) {
                recipient = email
            }
        }
        .alert(isPresented: $showingMailAlert) {
            Alert(
                title: Text("Invalid Email"),
                message: Text("Please enter a valid email address."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingLoginAlert) {
            NavigationView {
                LoginView(showSignUp: $showSignUp)
                    .environmentObject(authViewModel)
            }
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Email Sent"),
                message: Text("Your email has been sent and will be tracked in your profile."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func generateTemplate() {
        isGenerating = true
        generationError = nil
        
        let lastName = extractLastName(from: prof.name)
        
        OpenRouterService.shared.generateEmailBody(for: prof.researchAreas, professorLastName: lastName) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let txt):
                    bodyText = txt
                case .failure(let err):
                    generationError = err.localizedDescription
                }
            }
        }
    }
    
    private func extractLastName(from fullName: String) -> String {
        let components = fullName.components(separatedBy: " ")
        if components.count > 1 {
            return components.last ?? ""
        }
        return fullName
    }
    
    private func sendEmail() {
        guard authViewModel.isAuthenticated else {
            showingLoginAlert = true
            return
        }
        
        let to = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(subj)&body=\(body)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url) { success in
                if success {
                    outreachViewModel.saveOutreachRecord(for: prof, emailSent: bodyText)
                    showingSuccessAlert = true
                } else {
                    generationError = "Failed to open Mail app"
                }
            }
        }
    }
}
