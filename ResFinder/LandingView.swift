import SwiftUI

struct LandingView: View {
    @State private var showAuthFlow = false
    @State private var isActive = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                AppTheme.Colors.background
                    .ignoresSafeArea()

                // Main Content
                VStack(spacing: AppTheme.Spacing.xLarge) {
                    Spacer()

                    // Logo
                    Image("rf_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .background(
                            Circle()
                                .fill(AppTheme.Colors.cardBackground)
                                .frame(width: 240, height: 240)
                        )

                    // App title
                    Text("ReachSearch")
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundColor(AppTheme.Colors.primaryText)

                    // Tagline
                    Text("Connect with professors in your field")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.bottom, AppTheme.Spacing.small)

                    // Get Started button
                    Button(action: {
                        withAnimation {
                            if authViewModel.isAuthenticated && hasUploadedResume {
                                isActive = true
                            } else {
                                showAuthFlow = true
                            }
                        }
                    }) {
                        Text("Get Started")
                            .primaryButton()
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxLarge)

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: $showAuthFlow) {
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if authViewModel.isAuthenticated && hasUploadedResume {
                    isActive = true
                }
            }
        }
    }
}
