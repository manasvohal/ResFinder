import SwiftUI

// Common navigation header component that can be reused across views
struct CommonNavigationHeader: View {
    let title: String
    var showBackButton: Bool = true
    var onBackAction: (() -> Void)? = nil
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: {
                    if let action = onBackAction {
                        action()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
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
            
            Text(title)
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)
            
            Spacer()
            
            // Profile button
            ProfileButton()
        }
        .padding(.horizontal, AppTheme.Spacing.small)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(AppTheme.Colors.background)
    }
}
