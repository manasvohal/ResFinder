import SwiftUI

struct TypingTextView: View {
    let text: String
    let typingSpeed: Double
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    var body: some View {
        Text(displayedText)
            .font(AppTheme.bodyFont)
            .foregroundColor(AppTheme.primaryText)
            .onAppear {
                startTyping()
            }
            .onChange(of: text) { newText in
                resetTyping()
                startTyping()
            }
    }
    
    private func startTyping() {
        guard currentIndex < text.count else { return }
        
        let index = text.index(text.startIndex, offsetBy: currentIndex)
        displayedText += String(text[index])
        currentIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
            startTyping()
        }
    }
    
    private func resetTyping() {
        displayedText = ""
        currentIndex = 0
    }
}


