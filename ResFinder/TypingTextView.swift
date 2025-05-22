// File: TypingTextView.swift
// A simple typing‑effect view for SwiftUI
import SwiftUI

struct TypingTextView: View {
    let fullText: String
    let typingInterval: Double
    @State private var currentText: String = ""

    var body: some View {
        Text(currentText)
            .font(AppTheme.Fonts.body)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .onAppear {
                currentText = ""
                var charIndex = 0
                Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { timer in
                    if charIndex < fullText.count {
                        let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                        currentText.append(fullText[index])
                        charIndex += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
}
