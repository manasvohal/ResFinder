import SwiftUI

struct LandingView: View {
    @State private var isActive = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    
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
                    
                    // Logo with subtle shadow
                    Image("rf_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                        )
                    
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
                            isActive = true
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
                
                // Hidden NavigationLink
                NavigationLink(
                    destination: ResumeUploadView(destinationView: AnyView(ContentView().navigationBarBackButtonHidden(true))),
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
