import SwiftUI

@main
struct ResFinderApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // User session state
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(authViewModel)
        }
    }
}
