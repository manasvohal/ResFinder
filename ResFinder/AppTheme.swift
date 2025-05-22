import SwiftUI

// MARK: - App Theme Configuration
struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let background = Color.black
        static let secondaryBackground = Color(UIColor.systemGray6).opacity(0.1)
        static let cardBackground = Color(white: 0.1)
        static let primaryText = Color.white
        static let secondaryText = Color(white: 0.7)
        static let accent = Color.red
        static let buttonPrimary = Color.white
        static let buttonSecondary = Color(white: 0.15)
        static let divider = Color(white: 0.2)
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17)
        static let callout = Font.system(size: 16)
        static let subheadline = Font.system(size: 15)
        static let footnote = Font.system(size: 13)
        static let caption = Font.system(size: 12)
        static let caption2 = Font.system(size: 11)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxxSmall: CGFloat = 4
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let pill: CGFloat = 100
    }
}

// MARK: - Custom View Modifiers
struct DarkCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct PrimaryButtonModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.headline)
            .foregroundColor(isEnabled ? AppTheme.Colors.background : AppTheme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(isEnabled ? AppTheme.Colors.buttonPrimary : AppTheme.Colors.buttonSecondary)
            .cornerRadius(AppTheme.CornerRadius.pill)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(AppTheme.Colors.buttonSecondary)
            .cornerRadius(AppTheme.CornerRadius.pill)
    }
}

// MARK: - View Extensions
extension View {
    func darkCard() -> some View {
        modifier(DarkCardModifier())
    }
    
    func primaryButton(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonModifier(isEnabled: isEnabled))
    }
    
    func secondaryButton() -> some View {
        modifier(SecondaryButtonModifier())
    }
}

// MARK: - Convenience & Legacy Shorthands
extension AppTheme {
    // Typography shorthands
    static var bodyFont: Font             { Typography.body }
    static var headlineFont: Font         { Typography.headline }
    static var captionFont: Font          { Typography.caption }
    static var smallCaptionFont: Font     { Typography.caption2 }

    // Color shorthands
    static var primaryText: Color         { Colors.primaryText }
    static var secondaryText: Color       { Colors.secondaryText }
    static var cardBackground: Color      { Colors.cardBackground }
    static var backgroundColor: Color     { Colors.background }
    static var primaryRed: Color          { Colors.accent }
    static var secondaryBackground: Color { Colors.secondaryBackground }

    // Layout shorthands
    static var cornerRadius: CGFloat      { CornerRadius.medium }
    static var buttonCornerRadius: CGFloat { CornerRadius.pill }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .primaryButton()
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
