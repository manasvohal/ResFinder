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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with red background
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Follow-up Email")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color.red)
                
                VStack(spacing: 20) {
                    // Original email info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Following up with: \(outreachRecord.professorName)")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("Original email sent \(outreachRecord.daysSinceContact) days ago")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Email form
                    VStack(spacing: 16) {
                        // To field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("To")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            TextField("professor@university.edu", text: $recipient)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Subject field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subject")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            TextField("Re: Research Inquiry", text: $subject)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Body field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Message")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            if isGenerating {
                                HStack {
                                    Spacer()
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                        Text("Generating follow-up email...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                    .padding(40)
                                    Spacer()
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .frame(height: 200)
                            } else {
                                TextEditor(text: $bodyText)
                                    .frame(minHeight: 200)
                                    .padding(2)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            if let err = generationError {
                                Text(err)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            generateFollowUpTemplate()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Brief Follow-up")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isGenerating ? Color.gray : Color.orange)
                            .cornerRadius(10)
                        }
                        .disabled(isGenerating)
                        .padding(.horizontal)
                        
                        Button(action: {
                            if isValidEmail(recipient) {
                                sendEmail()
                            } else {
                                showingMailAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Follow-up Email")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear {
            // Pre-populate subject with "Follow-up"
            subject = "Follow-up: \(extractSubject())"
            
            // Try to extract email from professor name
            extractEmailFromName()
            
            // Generate template automatically on appear
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
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Follow-up Sent"),
                message: Text("Your follow-up email has been sent and recorded."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationBarHidden(true)
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
        
        // Create prompt for follow-up email
        let followUpPrompt = """
        Generate a brief follow-up email for a professor I contacted about research opportunities.
        
        ORIGINAL EMAIL I SENT:
        \(outreachRecord.emailSent)
        
        DAYS SINCE SENT: \(outreachRecord.daysSinceContact)
        
        Guidelines:
        - Keep it very brief and polite (3-5 sentences maximum)
        - Remind them of my initial email about research opportunities
        - Ask if they've had a chance to review my email
        - Offer to provide additional information if needed
        - Thank them for their time
        """
        
        OpenRouterService.shared.generateFollowUpEmail(prompt: followUpPrompt) { result in
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
    
    private func sendEmail() {
        let to = recipient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subj = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(subj)&body=\(body)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url) { success in
                if success {
                    // Save the follow-up email to Firebase
                    outreachViewModel.saveFollowUpEmail(for: outreachRecord, followUpEmail: bodyText)
                    showingSuccessAlert = true
                } else {
                    // Handle case where Mail app isn't available
                    generationError = "Failed to open Mail app"
                }
            }
        }
    }
    
    // Helper to extract email from name
    private func extractEmailFromName() {
        let name = outreachRecord.professorName.lowercased()
        let components = name.components(separatedBy: " ")
        
        if components.count >= 2 {
            let firstName = components.first ?? ""
            let lastName = components.last ?? ""
            
            if !firstName.isEmpty && !lastName.isEmpty {
                recipient = "\(firstName).\(lastName)@university.edu"
            } else {
                recipient = "\(name.replacingOccurrences(of: " ", with: ""))@university.edu"
            }
        } else {
            recipient = "\(name.replacingOccurrences(of: " ", with: ""))@university.edu"
        }
    }
    
    // Helper to extract subject from original email
    private func extractSubject() -> String {
        let originalEmail = outreachRecord.emailSent
        
        // Look for research-related keywords in the first few lines
        let lines = originalEmail.split(separator: "\n", maxSplits: 5, omittingEmptySubsequences: true)
        
        for line in lines {
            let lineText = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            if lineText.lowercased().contains("research") {
                return lineText
            }
        }
        
        return "Research Inquiry"
    }
}
