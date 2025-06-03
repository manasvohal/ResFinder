//
//  ResumeUploadView.swift
//  ResFinder
//

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
                                // Icon and file name
                                VStack(spacing: AppTheme.Spacing.medium) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.Colors.buttonSecondary)
                                            .frame(width: 120, height: 120)

                                        Image(systemName:
                                            (resumeFileName != nil || !savedResumeFileName.isEmpty)
                                            ? "doc.fill" : "doc.badge.plus"
                                        )
                                        .font(.system(size: 50))
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    }

                                    if let fileName = resumeFileName
                                        ?? (savedResumeFileName.isEmpty ? nil : savedResumeFileName) {
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

                                // Change / Upload button
                                Button {
                                    showingDocumentPicker = true
                                } label: {
                                    Text(
                                        (resumeFileName != nil || !savedResumeFileName.isEmpty)
                                        ? "Change Resume" : "Upload PDF Resume"
                                    )
                                    .secondaryButton()
                                }

                                // Save or Continue Without Resume buttons
                                VStack(spacing: AppTheme.Spacing.small) {
                                    // Save Resume (only enabled if file is present)
                                    Button {
                                        saveUserInfo()
                                        proceed()
                                    } label: {
                                        Text(isSheet ? "Save Changes" : "Save Resume")
                                            .primaryButton(
                                                isEnabled: resumeFileName != nil
                                                   || !savedResumeFileName.isEmpty
                                            )
                                    }
                                    .disabled(!(resumeFileName != nil || !savedResumeFileName.isEmpty))

                                    // Continue without uploading
                                    Button {
                                        proceed()
                                    } label: {
                                        Text("Continue Without Resume")
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(AppTheme.Colors.accent)
                                    }
                                    .padding(.top, AppTheme.Spacing.xxSmall)
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
            .onAppear {
                // If there’s already a saved file, reflect that
                if resumeFileName == nil && !savedResumeFileName.isEmpty {
                    resumeFileName = savedResumeFileName
                }
                if resumeText.isEmpty && !savedResumeText.isEmpty {
                    resumeText = savedResumeText
                }
            }
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
        hasUploadedResume = resumeFileName != nil || !savedResumeFileName.isEmpty
    }

    private func proceed() {
        if let onComplete = onComplete {
            onComplete()
        } else if destinationView != nil {
            isNavigationActive = true
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// DocumentPicker remains unchanged
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

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let started = url.startAccessingSecurityScopedResource()
            defer { if started { url.stopAccessingSecurityScopedResource() } }
            parent.fileName = url.lastPathComponent
            parent.fileURL = url
            extractTextFromPDF(url: url)
        }
        private func extractTextFromPDF(url: URL) {
            guard let doc = PDFDocument(url: url) else {
                parent.resumeText = "Could not extract text from PDF."
                return
            }
            var text = ""
            for i in 0..<doc.pageCount {
                if let page = doc.page(at: i), let s = page.string {
                    text += s + "\n"
                }
            }
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.resumeText = "Scanned PDF—no extractable text."
                return
            }
            text = text.replacingOccurrences(of: "\n\n+", with: "\n\n", options: .regularExpression)
            if text.count > 4000 {
                text = String(text.prefix(4000)) + "\n\n[Truncated]"
            }
            parent.resumeText = text
        }
    }
}
