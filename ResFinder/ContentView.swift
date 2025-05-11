import SwiftUI

struct ContentView: View {
    // Schools data
    private let schools: [(name: String, imageName: String, description: String)] = [
        ("UMD", "umd_logo", "University of Maryland"),
        ("Rutgers", "rutgers_logo", "Rutgers University")
    ]
    
    @State private var showResumeUpload = false
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Title with red background and profile button
            HStack {
                Text("Select University")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Profile button
                ProfileButton()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color.red)
            
            // Resume info bar
            if hasUploadedResume {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.red)
                    
                    Text("Resume uploaded for \(userName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        showResumeUpload = true
                    }) {
                        Text("Edit")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            
            // School list
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(schools, id: \.name) { school in
                        NavigationLink(destination: ResearchAreasSelectionView(school: school.name).environmentObject(authViewModel)) {
                            SchoolCardView(name: school.name,
                                          logoName: school.imageName,
                                          description: school.description)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarTitle("Pick School", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showResumeUpload) {
            ResumeUploadView(isSheet: true)
                .environmentObject(authViewModel)
        }
    }
}

// Card View for Schools
struct SchoolCardView: View {
    let name: String
    let logoName: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Logo with improved styling
            Image(logoName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .overlay(
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                )
                .padding(.leading, 4)
            
            // School information
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.red)
                .padding(.trailing, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
        )
    }
}
