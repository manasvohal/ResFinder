import SwiftUI

struct RecommendationView: View {
    let school: String

    @StateObject private var vm = RecommendationViewModel()
    @AppStorage("resumeText") private var resumeText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToResearchAreas = false

    var body: some View {
        VStack(spacing: 0) {
            CommonNavigationHeader(title: "Recommended Professors")
                .environmentObject(authViewModel)

            if vm.isLoading {
                Spacer()
                ProgressView("Finding best matches…")
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                Spacer()
            } else {
                List {
                    ForEach(vm.recommendations) { prof in
                        NavigationLink(
                            destination: ComposeEmailView(prof: prof)
                                .environmentObject(authViewModel)
                        ) {
                            ProfessorRowView(professor: prof)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            Divider()

            Button(action: {
                navigateToResearchAreas = true
            }) {
                Text("Can't see a good match? Select by Research Area")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
            }

            NavigationLink(
                destination: ResearchAreasSelectionView(school: school)
                    .environmentObject(authViewModel),
                isActive: $navigateToResearchAreas
            ) {
                EmptyView()
            }
            .hidden()
        }
        .onAppear {
            vm.loadRecommendations(for: school, resumeText: resumeText)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
