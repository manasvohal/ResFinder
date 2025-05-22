import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct ResumeUploadView: View {
    // MARK: Configuration
    var isSheet: Bool = false
    var onComplete: (() -> Void)? = nil

    // MARK: AppStorage
    @AppStorage("resumeFileName")   private var savedFileName = ""
    @AppStorage("resumeText")       private var savedText     = ""
    @AppStorage("hasUploadedResume")private var hasUploaded   = false

    // MARK: Local State
    @State private var fileURL: URL?           = nil
    @State private var fileName: String?       = nil
    @State private var extractedText: String   = ""
    @State private var showingPicker           = false
    @State private var showingAlert            = false
    @State private var alertMessage            = ""
    @State private var iconTapped              = false
    @Namespace private var ns

    @Environment(\.presentationMode) private var dismiss

    var canContinue: Bool {
        (fileName ?? savedFileName).isEmpty == false
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(white: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // MARK: Header
                HStack {
                    if isSheet {
                        Button {
                            dismiss.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                    Text(isSheet ? "Update Resume" : "Upload Resume")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .matchedGeometryEffect(id: "title", in: ns)
                    Spacer()
                    if isSheet {
                        Spacer().frame(width: 44)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)

                Spacer(minLength: 40)

                // MARK: Content
                VStack(spacing: 30) {
                    // Animated icon
                    ZStack {
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)]),
                                    center: .center
                                )
                            )
                            .frame(width: 100, height: 100)
                        Image(systemName: "doc.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .scaleEffect(iconTapped ? 1.2 : 1.0)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    iconTapped.toggle()
                                }
                                showingPicker = true
                            }
                    }
                    .matchedGeometryEffect(id: "icon", in: ns)

                    // File name display
                    if let name = fileName ?? (savedFileName.isEmpty ? nil : savedFileName) {
                        Text(name)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeOut, value: name)
                    } else {
                        Text("No file selected")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    // Buttons
                    VStack(spacing: 20) {
                        Button {
                            showingPicker = true
                        } label: {
                            Text(fileName != nil || !savedFileName.isEmpty
                                 ? "Change Resume"
                                 : "Select PDF Resume")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .scaleEffect(showingPicker ? 1.05 : 1.0)
                        .animation(.easeInOut, value: showingPicker)

                        Button {
                            saveAndProceed()
                        } label: {
                            Text(isSheet ? "Save Changes" : "Continue")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(canContinue ? Color.white : Color.white.opacity(0.3))
                                .foregroundColor(canContinue ? Color.black : Color.black.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(color: Color.black.opacity(canContinue ? 0.3 : 0.1),
                                        radius: canContinue ? 5 : 2, x: 0, y: canContinue ? 3 : 1)
                        }
                        .disabled(!canContinue)
                        .animation(.easeInOut, value: canContinue)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
        // PDF picker sheet
        .sheet(isPresented: $showingPicker) {
            DocumentPicker(fileURL: $fileURL,
                           fileName: $fileName,
                           resumeText: $extractedText)
        }
        // Alert for errors
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        // Load saved state
        .onAppear {
            if fileName == nil { fileName = savedFileName.isEmpty ? nil : savedFileName }
            if extractedText.isEmpty { extractedText = savedText }
        }
    }

    // MARK: Helpers
    private func saveAndProceed() {
        guard canContinue else {
            alertMessage = "Please select a PDF resume to continue."
            showingAlert = true
            return
        }
        if let name = fileName { savedFileName = name }
        if !extractedText.isEmpty { savedText = extractedText }
        hasUploaded = true
        if let cb = onComplete { cb() }
        else { dismiss.wrappedValue.dismiss() }
    }
}

// MARK: PDF Document Picker
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

    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }

        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let _ = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }

            parent.fileName = url.lastPathComponent
            parent.fileURL  = url

            // Extract text
            guard let pdf = PDFDocument(url: url) else {
                parent.resumeText = ""
                return
            }
            var text = ""
            for i in 0..<pdf.pageCount {
                text += pdf.page(at: i)?.string ?? ""
                text += "\n"
            }
            parent.resumeText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
