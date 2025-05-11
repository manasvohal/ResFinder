import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct ResumeUploadView: View {
    var destinationView: AnyView? = nil
    var isSheet: Bool = false
    var onComplete: (() -> Void)? = nil
    
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
    @AppStorage("resumeFileName") private var savedResumeFileName = ""
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with red background and profile button
                HStack {
                    Text(isSheet ? "Update Your Resume" : "Upload Your Resume")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Profile button if authenticated
                    if authViewModel.isAuthenticated {
                        // Use the ProfileButton component defined in ProfileButton.swift
                        ProfileButton()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color.red)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
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
                                        Image(systemName: (resumeFileName != nil || savedResumeFileName.count > 0) ? "arrow.triangle.2.circlepath" : "doc.badge.plus")
                                            .font(.headline)
                                        Text((resumeFileName != nil || savedResumeFileName.count > 0) ? "Change Resume" : "Upload PDF Resume")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                                }
                                
                                // Show file name if uploaded
                                if resumeFileName != nil || savedResumeFileName.count > 0 {
                                    HStack {
                                        Image(systemName: "doc.fill")
                                            .foregroundColor(.red)
                                        Text(resumeFileName ?? savedResumeFileName)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                
                                // Continue button
                                Button(action: {
                                    if resumeFileName != nil || savedResumeFileName.count > 0 {
                                        saveUserInfo()
                                        
                                        if let onComplete = onComplete {
                                            onComplete()
                                        } else if let _ = destinationView {
                                            isNavigationActive = true
                                        } else {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    } else {
                                        alertMessage = "Please upload your resume."
                                        showingAlert = true
                                    }
                                }) {
                                    HStack {
                                        Text(isSheet ? "Save Changes" : "Continue")
                                            .fontWeight(.semibold)
                                        
                                        if !isSheet {
                                            Image(systemName: "arrow.right")
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background((resumeFileName != nil || savedResumeFileName.count > 0) ? Color.black : Color.gray)
                                    .cornerRadius(10)
                                }
                                .disabled(!(resumeFileName != nil || savedResumeFileName.count > 0))
                                .padding(.top, 12)
                                
                                if isSheet {
                                    // Cancel button (only in sheet mode)
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Text("Cancel")
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.red, lineWidth: 1)
                                            )
                                            .cornerRadius(10)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                        )
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
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
            .onAppear {
                // Pre-fill user info from UserDefaults
                name = savedName
                major = savedMajor
                year = savedYear
                
                // Load saved file name on appear
                if resumeFileName == nil && !savedResumeFileName.isEmpty {
                    resumeFileName = savedResumeFileName
                }
                
                // Load saved resume text on appear
                if resumeText.isEmpty && !savedResumeText.isEmpty {
                    resumeText = savedResumeText
                }
            }
            .background(
                Group {
                    if let destinationView = destinationView {
                        NavigationLink(
                            destination: destinationView,
                            isActive: $isNavigationActive
                        ) {
                            EmptyView()
                        }
                    }
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveUserInfo() {
        // Save resume info if new file was selected
        if let fileName = resumeFileName {
            savedResumeFileName = fileName
        }
        
        if !resumeText.isEmpty {
            savedResumeText = resumeText
        }
        
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
            
            // Use PDFKit to extract text from the PDF
            extractTextFromPDF(url: url)
        }
        
        private func extractTextFromPDF(url: URL) {
            // Create a PDF document from the URL
            guard let pdfDocument = PDFDocument(url: url) else {
                print("Failed to create PDF document from URL")
                parent.resumeText = "Could not extract text from PDF. Please ensure it's a valid PDF file."
                return
            }
            
            var extractedText = ""
            
            // Extract text from each page
            for pageIndex in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }
                
                if let pageText = page.string {
                    extractedText += pageText + "\n"
                }
            }
            
            // If no text was extracted (possibly a scanned PDF without OCR)
            if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.resumeText = "The PDF appears to be a scanned document without machine-readable text. Please upload a PDF with extractable text."
                return
            }
            
            // Clean up the extracted text
            extractedText = extractedText.replacingOccurrences(of: "\n\n+", with: "\n\n", options: .regularExpression)
            
            // Limit the text to a reasonable length if it's too long
            let maxCharacters = 4000
            if extractedText.count > maxCharacters {
                extractedText = String(extractedText.prefix(maxCharacters)) + "\n\n[Text truncated due to length]"
            }
            
            // Set the extracted text
            parent.resumeText = extractedText
            
            print("Successfully extracted \(extractedText.count) characters from PDF")
        }
    }
}
