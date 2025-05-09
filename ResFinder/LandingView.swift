import SwiftUI

struct LandingView: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color.blue.opacity(0.1)
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo with subtle shadow
                    Image("rf_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                        )
                    
                    // App title with SF font
                    Text("ResFinder")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Tagline
                    Text("Connect with professors in your field")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // Get Started button with modern style
                    Button(action: {
                        withAnimation {
                            isActive = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(minWidth: 240, minHeight: 54)
                            .background(Color.blue)
                            .cornerRadius(27)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Hidden NavigationLink
                NavigationLink(
                    destination: ContentView().navigationBarBackButtonHidden(true),
                    isActive: $isActive
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }
}
