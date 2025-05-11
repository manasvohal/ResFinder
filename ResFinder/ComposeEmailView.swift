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
    @State private var showSignUp = true // Default to show sign up
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var outreachViewModel = OutreachViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Use common navigation header
            CommonNavigationHeader(title: "Email \(prof.name)")
                .environmentObject(authViewModel)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Add professor's website link and note
                    VStack(alignment: .leading, spacing: 8) {
                        // Professor website link
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Need the professor's email? Find it on their website:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Link(destination: prof.profileUrl) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                    Text("Visit \(prof.name)'s Website")
                                        .foregroundColor(.blue)
                                        .underline()
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    // Email form
                    VStack(spacing: 16) {
                        // To field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("To")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            TextField("prof@example.edu", text: $recipient)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal)
                        
                        // Subject field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subject")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            TextField("", text: $subject)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Body field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Body")
                                .font(.headline)
                                .foregroundColor(.red)
                            
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
                        .padding(.horizontal)
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Generate button - styled like follow-up view
                        Button(action: {
                            generateTemplate()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text(hasUploadedResume ? "Generate Personalized Email" : "Generate Template")
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
                        
                        // Send button - styled like follow-up view
                        Button(action: {
                            if isValidEmail(recipient) {
                                sendEmail()
                            } else {
                                showingMailAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Email")
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
                .padding(.top, 8)
            }
        }
        .onAppear {
            // Use a simple, generic subject line without any specific research areas
            subject = "Research Interest"
            
            // Pre-populate recipient if available in the professor data
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
                // Fix: Pass the required showSignUp binding parameter
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
        
        // Get professor's last name for greeting
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
        // Ensure user is authenticated
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
                    // Track outreach in Firebase
                    outreachViewModel.saveOutreachRecord(for: prof, emailSent: bodyText)
                    showingSuccessAlert = true
                } else {
                    // Handle case where Mail app isn't available
                    generationError = "Failed to open Mail app"
                }
            }
        }
    }
}

// MARK: - Preview
struct ComposeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock professor for the preview
        let mockProfessor = Professor(
            _id: "123",
            name: "Dr. Jane Smith",
            university: "UMD",
            department: "Computer Science",
            profileUrl: URL(string: "https://example.com")!,
            researchAreas: ["Machine Learning", "Artificial Intelligence"]
        )
        
        NavigationView {
            ComposeEmailView(prof: mockProfessor)
                .environmentObject(AuthViewModel())
        }
    }
}

