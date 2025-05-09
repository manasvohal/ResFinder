import SwiftUI

struct DetailView: View {
    let prof: Professor
    @State private var isInfoExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Professor header with avatar
                HStack(alignment: .center) {
                    // Large initial avatar
                    if let initial = prof.name.first {
                        Text(String(initial))
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prof.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(prof.university)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(prof.department)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                )
                
                // Research areas section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Research Areas")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(prof.researchAreas, id: \.self) { area in
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.blue)
                                .padding(.top, 6)
                            
                            Text(area)
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                )
                
                // Website link
                Link(destination: prof.profileUrl) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        
                        Text("View Professor Profile")
                            .font(.body)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Contact section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    NavigationLink(destination: ComposeEmailView(prof: prof)) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))
                            
                            Text("Send Email")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
                )
            }
            .padding()
        }
        .navigationTitle(prof.name)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
