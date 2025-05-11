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
        VStack(spacing: 0) {
            // Use common navigation header
            CommonNavigationHeader(title: "Follow-up: \(outreachRecord.professorName)")
                .environmentObject(authViewModel)
            
            Form {
                Section(header: Text("Original Email").foregroundColor(.red)) {
                    Text(outreachRecord.emailSent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
                
                Section(header: Text("To").foregroundColor(.red)) {
                    TextField("prof@example.edu", text: $recipient)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Subject").foregroundColor(.red)) {
                    TextField("", text: $subject)
                }
                
                Section(header: Text("Follow-up Email").foregroundColor(.red)) {
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
                            Spacer()
                        }
                        .frame(height: 150)
                    } else {
                        TextEditor(text: $bodyText)
                            .frame(minHeight: 200)
                    }
                    
                    if let err = generationError {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        generateFollowUpTemplate()
                    }) {
                        HStack {
                            Spacer()
                            Text("Generate Follow-up Email")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(isGenerating ? Color.gray : Color.red)
                        .cornerRadius(8)
                    }
                    .disabled(isGenerating)
                    .listRowBackground(Color.clear)
                    
                    Button(action: {
                        if isValidEmail(recipient) {
                            sendEmail()
                        } else {
                            showingMailAlert = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Send Follow-up Email")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(8)
                    }
                    .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
                    .listRowBackground(Color.clear)
                    .alert(isPresented: $showingMailAlert) {
                        Alert(
                            title: Text("Invalid Email"),
                            message: Text("Please enter a valid email address."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
        .onAppear {
            // Pre-populate subject with "Follow-up"
            subject = "Follow-up: Research Inquiry"
            
            // Extract email from the professor name if possible
            // This is a simplified approach - in a real app you might want to store the email address in the OutreachRecord
            let possibleEmail = outreachRecord.professorName.lowercased().filter { $0 != " " } + "@university.edu"
            if isValidEmail(possibleEmail) {
                recipient = possibleEmail
            }
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Follow-up Recorded"),
                message: Text("Your follow-up email has been sent and recorded."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationBarHidden(true)
    }
    
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
        Generate a follow-up email for a professor I contacted about research opportunities.
        
        ORIGINAL EMAIL I SENT:
        \(outreachRecord.emailSent)
        
        DAYS SINCE SENT: \(outreachRecord.daysSinceContact)
        
        Guidelines:
        - Keep it brief and polite
        - Remind the professor of my initial email
        - Express continued interest
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
}
