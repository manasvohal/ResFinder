import SwiftUI

struct DetailView: View {
    let prof: Professor
    @State private var isInfoExpanded = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CommonNavigationHeader(title: prof.name)
                    .environmentObject(authViewModel)
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        // Professor header with avatar
                        HStack(alignment: .center, spacing: AppTheme.Spacing.small) {
                            // Large initial avatar
                            if let initial = prof.name.first {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.Colors.accent.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Text(String(initial))
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.accent)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                                Text(prof.name)
                                    .font(AppTheme.Typography.title2)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                
                                Text(prof.university)
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                
                                Text(prof.department)
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .padding(.leading, AppTheme.Spacing.xxSmall)
                            
                            Spacer()
                        }
                        .padding(AppTheme.Spacing.small)
                        .darkCard()
                        
                        // Research areas section
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                            Text("Research Areas")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.accent)
                            
                            ForEach(prof.researchAreas, id: \.self) { area in
                                HStack(alignment: .top) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(AppTheme.Colors.accent)
                                        .padding(.top, 6)
                                    
                                    Text(area)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.small)
                        .darkCard()
                        
                        // Website link
                        Link(destination: prof.profileUrl) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(AppTheme.Colors.accent)
                                
                                Text("View Professor Profile")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .padding(AppTheme.Spacing.small)
                            .darkCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Contact section
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Text("Contact")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.accent)
                            
                            NavigationLink(destination: ComposeEmailView(prof: prof).environmentObject(authViewModel)) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(AppTheme.Colors.accent)
                                        .font(.system(size: 18))
                                    
                                    Text("Send Email")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .font(.system(size: 14))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(AppTheme.Spacing.small)
                        .darkCard()
                    }
                    .padding(AppTheme.Spacing.small)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
}
