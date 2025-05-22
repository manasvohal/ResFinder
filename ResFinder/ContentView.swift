import SwiftUI

struct ContentView: View {
    // Schools data
    private let schools: [(name: String, imageName: String, description: String)] = [
        ("UMD", "umd_logo", "University of Maryland"),
        ("Rutgers", "rutgers_logo", "Rutgers University")
    ]

    @State private var showResumeUpload = false
    @State private var selectedSchool: String? = nil
    @AppStorage("hasUploadedResume") private var hasUploadedResume = false
    @AppStorage("userName") private var userName = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    /// Display name to show in the resume bar: prefer saved `userName`, fallback to email prefix
    private var displayName: String {
        if !userName.isEmpty {
            return userName
        }
        // Fallback: use email prefix (before '@')
        if let email = authViewModel.user?.email, let prefix = email.split(separator: "@").first {
            return String(prefix)
        }
        return ""
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header
                    HeaderView(title: "Select University")
                    
                    // Resume info bar with improved design
                    if hasUploadedResume {
                        ResumeInfoBar(
                            displayName: displayName,
                            onEditTapped: { showResumeUpload = true }
                        )
                    }
                    
                    // School list with improved spacing and design
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(schools, id: \.name) { school in
                                NavigationLink(
                                    destination: RecommendationView(school: school.name)
                                        .environmentObject(authViewModel),
                                    tag: school.name,
                                    selection: $selectedSchool
                                ) {
                                    SchoolCardView(
                                        name: school.name,
                                        logoName: school.imageName,
                                        description: school.description
                                    )
                                    .onTapGesture {
                                        // Set the selected school to trigger navigation
                                        selectedSchool = school.name
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showResumeUpload) {
                ResumeUploadView(isSheet: true)
                    .environmentObject(authViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - HeaderView
struct HeaderView: View {
    let title: String
    
    var body: some View {
        ZStack {
            // Header background
            Color(UIColor.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Profile button
                ProfileButton()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(height: 60)
    }
}

// MARK: - ResumeInfoBar
struct ResumeInfoBar: View {
    let displayName: String
    let onEditTapped: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                // Document icon with circle background
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.05))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "doc.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Text("Resume uploaded for \(displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onEditTapped) {
                Text("Edit")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - SchoolCardView
struct SchoolCardView: View {
    let name: String
    let logoName: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // School logo
            Image(logoName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
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
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.gray.opacity(0.7))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}
