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
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                if authViewModel.isAuthenticated {
                    // Show authenticated icon
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else {
                    // Show unauthenticated icon
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(authViewModel)
        }
    }
}
