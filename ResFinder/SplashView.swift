import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @State private var showLetters: [Bool]
    @State private var didFinishAnimation = false

    private let letters = Array("ReachSearch")
    private let letterDelay: Double = 0.2  // slower reveal

    init() {
        _showLetters = State(initialValue: Array(repeating: false, count: letters.count))
    }

    var body: some View {
        Group {
            if didFinishAnimation {
                // after animation, pick next screen
                if authViewModel.isAuthenticated && hasUploadedResume {
                    ContentView()
                        .environmentObject(authViewModel)
                } else {
                    AuthContainerView()
                        .environmentObject(authViewModel)
                }
            } else {
                ZStack {
                    AppTheme.Colors.background.ignoresSafeArea()
                    HStack(spacing: 0) {
                        ForEach(letters.indices, id: \.self) { i in
                            Text(String(letters[i]))
                                .font(AppTheme.Typography.largeTitle)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .scaleEffect(showLetters[i] ? 1 : 0.5)
                                .opacity(showLetters[i] ? 1 : 0)
                        }
                    }
                }
                .onAppear(perform: playAnimation)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func playAnimation() {
        // reveal each letter
        for i in letters.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * letterDelay) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showLetters[i] = true
                }
            }
        }

        // when done, flip to next
        let total = Double(letters.count) * letterDelay + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + total) {
            withAnimation(.easeInOut(duration: 0.5)) {
                didFinishAnimation = true
            }
        }
    }
}
