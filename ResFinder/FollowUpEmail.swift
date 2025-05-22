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
    
    // Define the minimum days before showing the follow-up button
    private let minimumDaysForFollowUp = 7
    
    // Computed property to check if enough days have passed
    private var canSendFollowUp: Bool {
        return outreachRecord.daysSinceContact >= minimumDaysForFollowUp
    }
    
    // Extract professor's last name
    private var professorLastName: String {
        let components = outreachRecord.professorName.components(separatedBy: " ")
        if components.count > 1 {
            return components.last ?? ""
        }
        return outreachRecord.professorName
    }
    
    // Get the best available URL for the professor's website
    private var bestWebsiteUrl: URL {
        // First priority: use URL from outreach record if available
        if let profileUrl = outreachRecord.profileUrl {
            print("Using URL from outreach record: \(profileUrl)")
            return profileUrl
        }
        
        // Second priority: use URL from fetched professor details if available
        if let professor = professorDetails, professor.id == outreachRecord.professorId {
            print("Using URL from professor details: \(professor.profileUrl)")
            return professor.profileUrl
        }
        
        // Fallback: use Google search
        print("Falling back to Google search")
        return URL(string: "https://www.google.com/search?q=\(outreachRecord.professorName.replacingOccurrences(of: " ", with: "+"))") ?? URL(string: "https://www.google.com")!
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with black background
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
                    
                    // Empty view to balance the header
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .opacity(0) // Make it invisible but take up space
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color.black)
                
                VStack(spacing: 20) {
                    // Original email info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Following up with: \(outreachRecord.professorName)")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("Original email sent \(outreachRecord.daysSinceContact) days ago")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Add professor's website link and note
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.black)
                                Text("Need the professor's email? Find it on their website:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Link(destination: bestWebsiteUrl) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.black)
                                    
                                    if outreachRecord.profileUrl != nil || professorDetails != nil {
                                        Text("Visit \(outreachRecord.professorName)'s Website")
                                            .foregroundColor(.black)
                                            .underline()
                                    } else {
                                        Text("Search for \(outreachRecord.professorName)")
                                            .foregroundColor(.black)
                                            .underline()
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.black)
                                }
                                .padding(10)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Show warning if not enough days have passed
                        if !canSendFollowUp {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("It's recommended to wait at least \(minimumDaysForFollowUp) days before sending a follow-up email.")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.top, 4)
                        }
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
                                .foregroundColor(.black)
                            
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
                                .foregroundColor(.black)
                            
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
                                .foregroundColor(.black)
                            
                            if isGenerating {
                                HStack {
                                    Spacer()
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
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
                            .background(isGenerating ? Color.gray : Color.black)
                            .cornerRadius(10)
                        }
                        .disabled(isGenerating)
                        .padding(.horizontal)
                        
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
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                recipient.isEmpty || subject.isEmpty || bodyText.isEmpty || !canSendFollowUp
                                ? Color.gray
                                : Color.black
                            )
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
            // Pre-populate subject with shorter format
            subject = "Follow-up: Research Inquiry"
            
            // DO NOT pre-populate the email field - user needs to enter it again
            
            // Try to fetch professor details if we don't have a profileUrl
            if outreachRecord.profileUrl == nil {
                outreachViewModel.fetchProfessorDetails(byId: outreachRecord.professorId) { professor in
                    self.professorDetails = professor
                    print("Fetched professor details: \(String(describing: professor?.name)), URL: \(String(describing: professor?.profileUrl))")
                }
            } else {
                print("Already have profile URL: \(String(describing: outreachRecord.profileUrl))")
            }
            
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
        
        // Use the new version of generateFollowUpEmail that accepts professor's last name
        OpenRouterService.shared.generateFollowUpEmail(
            for: professorLastName,
            originalEmail: outreachRecord.emailSent,
            daysSinceContact: outreachRecord.daysSinceContact
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let txt):
                    // Remove any subject lines that might have been included
                    bodyText = removeSubjectLine(from: txt)
                case .failure(let err):
                    generationError = err.localizedDescription
                }
            }
        }
    }
    
    private func removeSubjectLine(from text: String) -> String {
        // Function to remove subject line if it was included anyway
        let lines = text.components(separatedBy: "\n")
        var result = text
        
        // Look for typical subject line patterns in the first few lines
        for (index, line) in lines.prefix(3).enumerated() {
            let lowercaseLine = line.lowercased()
            if lowercaseLine.contains("subject:") ||
               lowercaseLine.contains("re:") ||
               lowercaseLine.hasPrefix("subject") {
                // Remove this line and any empty line after it
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
