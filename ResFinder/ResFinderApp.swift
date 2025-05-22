import SwiftUI

@main
struct ResFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var outreachViewModel = OutreachViewModel()

    /// For deep‐link follow-ups
    @State private var followUpRecordId: String?

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authViewModel)
                .environmentObject(outreachViewModel)
                .onAppear {
                    // preload outreach history
                    outreachViewModel.loadOutreachRecords()
                }
                .onOpenURL { url in
                    // handle resfinder://followup?recordId=XYZ
                    guard
                        url.scheme == "resfinder",
                        url.host   == "followup",
                        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                        let id    = comps.queryItems?.first(where: { $0.name == "recordId" })?.value
                    else { return }
                    followUpRecordId = id
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get:  { followUpRecordId != nil },
                        set:  { if !$0 { followUpRecordId = nil } }
                    )
                ) {
                    if
                        let recordId = followUpRecordId,
                        let record   = outreachViewModel.outreachRecords.first(where: { $0.id == recordId })
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
