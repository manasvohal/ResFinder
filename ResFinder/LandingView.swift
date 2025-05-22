import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @State private var showAuthFlow = false
    @State private var navigateNext = false

    // Typing effect state
    @State private var currentText = ""
    private let fullText = "Find faculty aligned with you."
    private let typingInterval = 0.05

    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo
                Image("rf_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                // App title
                Text("ReachSearch")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                // Typing effect
                Text(currentText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .onAppear(perform: startTyping)

                // Get Started button
                Button(action: handleGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        // Auth / Next flows
        .fullScreenCover(isPresented: $showAuthFlow) {
            AuthContainerView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $navigateNext) {
            ContentView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            // Auto‑advance if already signed in & resume uploaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if authViewModel.isAuthenticated && hasUploadedResume {
                    navigateNext = true
                }
            }
        }
    }

    private func handleGetStarted() {
        if authViewModel.isAuthenticated && hasUploadedResume {
            navigateNext = true
        } else {
            showAuthFlow = true
        }
    }

    private func startTyping() {
        currentText = ""
        var idx = 0
        Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { timer in
            if idx < fullText.count {
                let i = fullText.index(fullText.startIndex, offsetBy: idx)
                currentText.append(fullText[i])
                idx += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
