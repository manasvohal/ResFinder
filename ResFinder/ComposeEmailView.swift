import SwiftUI

struct ComposeEmailView: View {
    let prof: Professor

    @State private var recipient = ""
    @State private var subject = ""
    @State private var bodyText = ""
    @State private var isGenerating = false
    @State private var generationError: String?

    var body: some View {
        Form {
            Section(header: Text("To")) {
                TextField("prof@example.edu", text: $recipient)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            Section(header: Text("Subject")) {
                TextField("", text: $subject)
            }

            Section(header: Text("Body")) {
                if isGenerating {
                    ProgressView("Generating…")
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
                Button("Generate Template") {
                    generateTemplate()
                }
                .disabled(isGenerating)

                Button("Send Email") {
                    sendEmail()
                }
                .disabled(recipient.isEmpty || subject.isEmpty || bodyText.isEmpty)
            }
        }
        .navigationTitle("Email \(prof.name)")
        .onAppear {
            subject = "Inquiry about your research in \(prof.researchAreas.joined(separator: ", "))"
        }
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
            UIApplication.shared.open(url)
        }
    }
}

struct ComposeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComposeEmailView(prof: Professor(
                _id: "1",
                name: "Jane Doe",
                university: "UMD",
                department: "CS",
                profileUrl: URL(string: "https://cs.umd.edu")!,
                researchAreas: ["Machine Learning", "Computer Vision"]
            ))
        }
    }
}

