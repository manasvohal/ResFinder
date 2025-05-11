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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Profile button
            // Using existing ProfileButton instead of redeclaring it
            ProfileButton()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color.red)
    }
}

// Move this to a separate file called ProfileButton.swift to avoid redeclaration
// struct ProfileButton: View {
//     @State private var showingProfile = false
//     @EnvironmentObject var authViewModel: AuthViewModel
//
//     var body: some View {
//         Button(action: {
//             showingProfile = true
//         }) {
//             ZStack {
//                 Circle()
//                     .fill(Color.white.opacity(0.2))
//                     .frame(width: 36, height: 36)
//
//                 if authViewModel.isAuthenticated {
//                     // Show authenticated icon
//                     Image(systemName: "person.circle.fill")
//                         .font(.system(size: 20))
//                         .foregroundColor(.white)
//                 } else {
//                     // Show unauthenticated icon
//                     Image(systemName: "person.circle")
//                         .font(.system(size: 20))
//                         .foregroundColor(.white)
//                 }
//             }
//         }
//         .sheet(isPresented: $showingProfile) {
//             ProfileView()
//                 .environmentObject(authViewModel)
//         }
//     }
// }
