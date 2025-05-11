import SwiftUI

struct LandingView: View {
    @State private var showAuthFlow = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background with red gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Main Content
                VStack(spacing: 30) {
                    Spacer()

                    // Logo with bigger size and stronger shadow
                    Image("rf_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 265, height: 265)
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 12,
                                x: 0,
                                y: 6)

                    // App title with SF font
                    Text("ResFinder")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    // Tagline
                    Text("Connect with professors in your field")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 10)

                    // Get Started button
                    Button(action: {
                        withAnimation {
                            showAuthFlow = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(minWidth: 240, minHeight: 54)
                            .background(Color.white)
                            .cornerRadius(27)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAuthFlow) {
                // Show the authentication flow when the user presses "Get Started"
                AuthContainerView()
                    .environmentObject(authViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // If user is already authenticated, skip directly to ContentView
        .onAppear {
            if authViewModel.isAuthenticated && hasUploadedResume {
                // User is already logged in and has a resume, so redirect to ContentView
                showAuthFlow = true
            }
        }
    }
    
    // Check if user has uploaded a resume
    private var hasUploadedResume: Bool {
        return UserDefaults.standard.bool(forKey: "hasUploadedResume")
    }
}
