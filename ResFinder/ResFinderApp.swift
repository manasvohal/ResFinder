import SwiftUI

@main
struct ResFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var outreachViewModel = OutreachViewModel()

    // Holds the record ID passed via deep-link
    @State private var followUpRecordId: String?

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(authViewModel)
                .environmentObject(outreachViewModel)
                // Pre-load outreach docs on launch
                .onAppear {
                    outreachViewModel.loadOutreachRecords()
                }
                // Handle incoming resfinder:// URLs
                .onOpenURL { url in
                    print("💡 Deep link received:", url)
                    guard
                        url.scheme == "resfinder",
                        url.host   == "followup",
                        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                        let id = comps.queryItems?.first(where: { $0.name == "recordId" })?.value
                    else { return }
                    followUpRecordId = id
                }
                // Show the follow-up screen when an ID arrives
                .fullScreenCover(
                    isPresented: Binding<Bool>(
                        get: { followUpRecordId != nil },
                        set: { if !$0 { followUpRecordId = nil } }
                    )
                ) {
                    if
                        let recordId = followUpRecordId,
                        let record = outreachViewModel.outreachRecords.first(where: { $0.id == recordId })
                    {
                        FollowUpEmailView(outreachRecord: record)
                            .environmentObject(authViewModel)
                            .environmentObject(outreachViewModel)
                    } else {
                        Text("Could not locate that outreach.")
                            .padding()
                    }
                }
        }
    }
}
