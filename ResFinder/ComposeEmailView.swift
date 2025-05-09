import SwiftUI

struct ComposeEmailView: View {
    let prof: Professor
    
    @State private var recipient = ""
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isGenerating = false
    @State private var generationError: String?
    @State private var showingMailAlert = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        Form {
            Section(header: Text("To").foregroundColor(.red)) {
                TextField("prof@example.edu", text: $recipient)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("Subject").foregroundColor(.red)) {
                TextField("", text: $subject)
            }
            
            Section(header: Text("Body").foregroundColor(.red)) {
                if isGenerating {
                    HStack {
                        Spacer()
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            Text("Generating personalized email...")
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
                
                if !hasUploadedResume {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        Text("Resume data unavailable. Your email may not be fully personalized.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            
            Section {
                Button(action: {
                    generateTemplate()
                }) {
                    HStack {
                        Spacer()
                        Text(hasUploadedResume ? "Generate Personalized Email" : "Generate Template")
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
                        Text("Send Email")
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
        .navigationTitle("Email \(prof.name)")
        .onAppear {
            // Pre-populate subject with research areas
            subject = "Inquiry about your research in \(prof.researchAreas.joined(separator: ", "))"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func generateTemplate() {
        isGenerating = true
        generationError = nil
        
        OpenRouterService.shared.generateEmailBody(for: prof.researchAreas) { result in
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
                if !success {
                    // Handle case where Mail app isn't available
                    print("Failed to open Mail app")
                }
            }
        }
    }
}
