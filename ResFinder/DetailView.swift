import SwiftUI

struct DetailView: View {
    let prof: Professor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Professor’s basic info
                Text(prof.name)
                    .font(.title2)
                    .bold()

                Text(prof.university)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                // Department
                Text("Department")
                    .font(.headline)
                Text(prof.department)

                Divider()

                // Research areas
                Text("Research Areas")
                    .font(.headline)
                ForEach(prof.researchAreas, id: \.self) { area in
                    Text("• \(area)")
                }

                Divider()

                // Link out to their full profile
                Link("View Full Profile", destination: prof.profileUrl)
                    .padding(.top)

                Divider()

                // Compose an email to this professor
                NavigationLink("Compose Email") {
                    ComposeEmailView(prof: prof)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle(prof.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(
                prof: Professor(
                    _id: "1",
                    name: "Test Professor",
                    university: "UMD",
                    department: "Computer Science",
                    profileUrl: URL(string: "https://example.com")!,
                    researchAreas: ["Machine Learning", "Computer Vision"]
                )
            )
        }
    }
}

