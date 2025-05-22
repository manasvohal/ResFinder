import SwiftUI

// MARK: - Reusable UI Components

struct GradientBackground: View {
    var body: some View {
        AppTheme.backgroundColor.ignoresSafeArea()
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryRed))
                .scaleEffect(1.5)
            
            Text(message)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.primaryText)
            
            Text(message)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let retryAction = retryAction {
                Button("Retry") {
                    retryAction()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.secondaryBackground)
                    .frame(width: 80, height: 80)
                
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.secondaryText)
            }
            
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.primaryText)
            
            Text(message)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.primaryRed)
            
            TextField(placeholder, text: $searchText)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.primaryText)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct TagView: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AppTheme.smallCaptionFont)
                .foregroundColor(isSelected ? AppTheme.primaryText : AppTheme.primaryRed)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? AppTheme.primaryRed : AppTheme.primaryRed.opacity(0.1))
                )
        }
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.primaryRed)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

