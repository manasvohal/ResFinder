// File: UIComponents.swift
// Card container and a filled text field style
import SwiftUI

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(AppTheme.Layout.padding)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .shadow(color: Color.black.opacity(0.1),
                    radius: AppTheme.Layout.cardShadow, x: 0, y: 2)
    }
}

struct FilledTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppTheme.Colors.surface.opacity(0.05))
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .font(AppTheme.Fonts.body)
    }
}
