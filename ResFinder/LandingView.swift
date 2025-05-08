import SwiftUI

struct LandingView: View {
    @State private var isActive = false

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: – Splash UI
                VStack(spacing: 30) {
                    Spacer()

                    // Bigger logo
                    Image("rf_logo")        // your asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    // App title
                    Text("ResFinder")
                        .font(.largeTitle)
                        .bold()

                    // Get Started button
                    Button(action: {
                        withAnimation {
                            isActive = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .frame(minWidth: 200, minHeight: 44)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()
                }

                // MARK: – Hidden NavigationLink to push to pick‑school screen
                NavigationLink(
                    destination: ContentView(),   // your pick‑school view
                    isActive: $isActive
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
            .ignoresSafeArea() // full‑screen
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}

