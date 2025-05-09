import SwiftUI
import UniformTypeIdentifiers

struct ResumeUploadView: View {
    var destinationView: AnyView
    
    @State private var name = ""
    @State private var major = ""
    @State private var year = ""
    @State private var showingDocumentPicker = false
    @State private var resumeFileName: String?
    @State private var resumeFileURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isNavigationActive = false
    @State private var resumeText = ""
    
    @AppStorage("userName") private var savedName = ""
    @AppStorage("userMajor") private var savedMajor = ""
    @AppStorage("userYear") private var savedYear = ""
    @AppStorage("resumeText") private var savedResumeText = ""
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    
    // Year options
    let yearOptions = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate Student", "PhD Student"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with red background
            VStack {
                Text("Upload Your Resume")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.red)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Instructions section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Your full name", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onAppear {
                                    if name.isEmpty && !savedName.isEmpty {
                                        name = savedName
                                    }
                                }
                        }
                        
                        // Major field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Major")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Your major (e.g., Computer Science)", text: $major)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onAppear {
                                    if major.isEmpty && !savedMajor.isEmpty {
                                        major = savedMajor
                                    }
                                }
                        }
                        
                        // Year picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Academic Year")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Academic Year", selection: $year) {
                                Text("Select Year").tag("")
                                ForEach(yearOptions, id: \.self) { year in
                                    Text(year).tag(year)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .onAppear {
                                if year.isEmpty && !savedYear.isEmpty {
                                    year = savedYear
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                    )
                    
                    // Resume section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resume")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Please upload your resume as a PDF file. This will be used to personalize email templates when contacting professors.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Upload button
                            Button(action: {
                                showingDocumentPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.headline)
                                    Text(resumeFileName != nil ? "Change Resume" : "Upload PDF Resume")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                            
                            // Show file name if uploaded
                            if let fileName = resumeFileName {
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(.red)
                                    Text(fileName)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                    )
                    
                    // Continue button
                    Button(action: {
                        if isFormValid {
                            saveUserInfo()
                            isNavigationActive = true
                        } else {
                            alertMessage = "Please fill in all fields and upload your resume."
                            showingAlert = true
                        }
                    }) {
                        HStack {
                            Text("Continue to School Selection")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.black : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(
                fileURL: $resumeFileURL,
                fileName: $resumeFileName,
                resumeText: $resumeText
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Missing Information"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(
            NavigationLink(
                destination: destinationView,
                isActive: $isNavigationActive
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty && !major.isEmpty && !year.isEmpty && resumeFileName != nil
    }
    
    private func saveUserInfo() {
        // Save user info to UserDefaults
        savedName = name
        savedMajor = major
        savedYear = year
        savedResumeText = resumeText
        hasUploadedResume = true
    }
}

// Document Picker for PDF files
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var fileName: String?
    @Binding var resumeText: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Get file name
            parent.fileName = url.lastPathComponent
            parent.fileURL = url
            
            // We're simulating getting text from the PDF
            // In a real app, you'd use PDFKit or a PDF parser library to extract text
            parent.resumeText = "Experience in \(["programming", "research", "data analysis", "machine learning"].randomElement() ?? "research") and \(["teamwork", "leadership", "project management"].randomElement() ?? "teamwork"). Education in \(["Computer Science", "Engineering", "Biology", "Physics"].randomElement() ?? "Computer Science")."
        }
    }
}
