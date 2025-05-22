// File: AppTheme.swift
// Defines colors, fonts, and layout constants for a sleek black & white theme
import SwiftUI

struct AppTheme {
    struct Colors {
        static let background     = Color("Background")      // White (#FFFFFF)
        static let surface        = Color("Surface")         // Black (#000000)
        static let textPrimary    = Color("TextPrimary")     // Near-black (#222222)
        static let textSecondary  = Color("TextSecondary")   // Gray (#555555)
    }

    struct Fonts {
        static let header   = Font.system(size: 28, weight: .bold,   design: .rounded)
        static let title    = Font.system(size: 22, weight: .semibold,design: .rounded)
        static let body     = Font.system(size: 16, weight: .regular, design: .rounded)
        static let caption  = Font.system(size: 12, weight: .regular, design: .rounded)
    }

    struct Layout {
        static let padding: CGFloat      = 16
        static let cornerRadius: CGFloat = 12
        static let cardShadow: CGFloat   = 6
    }
}
