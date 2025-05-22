import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct ResumeUploadView: View {
    var destinationView: AnyView? = nil
    var isSheet: Bool = false
    var onComplete: (() -> Void)? = nil
    
    @State private var showingDocumentPicker = false
    @State private var resumeFileName: String?
    @State private var resumeFileURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isNavigationActive = false
    @State private var resumeText = ""
    
    @AppStorage("resumeText") private var savedResumeText = ""
    @AppStorage("resumeFileName") private var savedResumeFileName = ""
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        if isSheet {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.Colors.buttonSecondary)
                                    .clipShape(Circle())
                            }
                        } else {
                            Color.clear
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text(isSheet ? "Update Resume" : "Upload Resume")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.vertical, AppTheme.Spacing.small)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.large) {
                            // Upload section
                            VStack(spacing: AppTheme.Spacing.medium) {
                                // File upload area
                                VStack(spacing: AppTheme.Spacing.medium) {
                                    // Icon
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.Colors.buttonSecondary)
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: resumeFileName != nil || !savedResumeFileName.isEmpty ? "doc.fill" : "doc.badge.plus")
                                            .font(.system(size: 50))
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                    }
                                    
                                    // File name or upload prompt
                                    if let fileName = resumeFileName ?? (savedResumeFileName.isEmpty ? nil : savedResumeFileName) {
                                        Text(fileName)
                                            .font(AppTheme.Typography.headline)
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                    } else {
                                        VStack(spacing: AppTheme.Spacing.xxSmall) {
                                            Text("No resume uploaded")
                                                .font(AppTheme.Typography.headline)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                            
                                            Text("Upload a PDF to get personalized recommendations")
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                                .padding(.vertical, AppTheme.Spacing.xLarge)
                                
                                // Upload/Change button
                                Button(action: {
                                    showingDocumentPicker = true
                                }) {
                                    Text(resumeFileName != nil || !savedResumeFileName.isEmpty ? "Change Resume" : "Upload PDF Resume")
                                        .secondaryButton()
                                }
                                
                                // Action buttons
                                VStack(spacing: AppTheme.Spacing.small) {
                                    Button(action: {
                                        if resumeFileName != nil || !savedResumeFileName.isEmpty {
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
                                        Text(isSheet ? "Save Changes" : "Save Resume")
                                            .primaryButton(isEnabled: resumeFileName != nil || !savedResumeFileName.isEmpty)
                                    }
                                    .disabled(!(resumeFileName != nil || !savedResumeFileName.isEmpty))
                                    
                                    if isSheet {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }) {
                                            Text("Cancel")
                                                .font(AppTheme.Typography.headline)
                                                .foregroundColor(AppTheme.Colors.accent)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.large)
                        }
                        .padding(.top, AppTheme.Spacing.large)
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
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
                if resumeFileName == nil && !savedResumeFileName.isEmpty {
                    resumeFileName = savedResumeFileName
                }
                
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
        if let fileName = resumeFileName {
            savedResumeFileName = fileName
        }
        
        if !resumeText.isEmpty {
            savedResumeText = resumeText
        }
        
        hasUploadedResume = true
    }
}

// Document Picker remains the same
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
            
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            parent.fileName = url.lastPathComponent
            parent.fileURL = url
            
            extractTextFromPDF(url: url)
        }
        
        private func extractTextFromPDF(url: URL) {
            guard let pdfDocument = PDFDocument(url: url) else {
                print("Failed to create PDF document from URL")
                parent.resumeText = "Could not extract text from PDF. Please ensure it's a valid PDF file."
                return
            }
            
            var extractedText = ""
            
            for pageIndex in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }
                
                if let pageText = page.string {
                    extractedText += pageText + "\n"
                }
            }
            
            if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.resumeText = "The PDF appears to be a scanned document without machine-readable text. Please upload a PDF with extractable text."
                return
            }
            
            extractedText = extractedText.replacingOccurrences(of: "\n\n+", with: "\n\n", options: .regularExpression)
            
            let maxCharacters = 4000
            if extractedText.count > maxCharacters {
                extractedText = String(extractedText.prefix(maxCharacters)) + "\n\n[Text truncated due to length]"
            }
            
            parent.resumeText = extractedText
            
            print("Successfully extracted \(extractedText.count) characters from PDF")
        }
    }
}
