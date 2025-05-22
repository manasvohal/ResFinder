import SwiftUI

// Profile button that opens the profile view
struct ProfileButton: View {
    @State private var showingProfile = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.buttonSecondary)
                    .frame(width: 44, height: 44)
                
                if authViewModel.isAuthenticated {
                    // Show authenticated icon
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.primaryText)
                } else {
                    // Show unauthenticated icon
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(authViewModel)
        }
    }
}
