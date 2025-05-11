import SwiftUI

struct LandingView: View {
    @State private var showAuthFlow = false
    @State private var isActive = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
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
                            if authViewModel.isAuthenticated && hasUploadedResume {
                                // User is already authenticated and has resume, go to content
                                isActive = true
                            } else {
                                // User needs to authenticate
                                showAuthFlow = true
                            }
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

                    // Debug auth state - remove in production
                    Text(authViewModel.isAuthenticated ? "Signed in as: \(authViewModel.user?.email ?? "Unknown")" : "Not signed in")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)

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
            .background(
                NavigationLink(
                    destination: ContentView()
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(authViewModel),
                    isActive: $isActive
                ) {
                    EmptyView()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Check if user is already authenticated on appear
        .onAppear {
            print("LandingView: onAppear - Auth state: \(authViewModel.isAuthenticated), Resume: \(hasUploadedResume)")
            
            // Small delay to ensure auth state is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if authViewModel.isAuthenticated && hasUploadedResume {
                    isActive = true
                }
            }
        }
    }
}
