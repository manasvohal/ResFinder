import SwiftUI

struct EnhancedOutreachRecordRow: View {
    let record: OutreachRecord
    let followUpThresholdDays: Int
    
    @State private var isExpanded = false
    @State private var navigateToFollowUp = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Professor info and days counter
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.professorName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(formatDate(record.dateEmailed))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Days counter with prominent display
                VStack(alignment: .center, spacing: 0) {
                    Text("\(record.daysSinceContact)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(getDayCountColor(days: record.daysSinceContact))
                    
                    Text("days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 60)
                .padding(.horizontal, 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Preview of email with expand/collapse
            VStack(alignment: .leading, spacing: 8) {
                Text(isExpanded ? record.emailSent : record.emailSent.prefix(100) + "...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                    .padding(.horizontal, 16)
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 12)
            
            // Follow-up section
            if record.hasFollowedUp {
                // Show follow-up information
                VStack(alignment: .leading, spacing: 6) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        
                        Text("Follow-up sent on \(formatDate(record.followUpDate ?? Date()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            } else {
                // Show follow-up button immediately (0 days threshold)
                VStack(alignment: .leading, spacing: 6) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    Button(action: {
                        // Trigger navigation
                        navigateToFollowUp = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.badge.clock.fill")
                                .font(.system(size: 14))
                            Text("Send Follow-up Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
        )
        .background(
            // Better navigation implementation
            NavigationLink(
                destination: FollowUpEmailView(outreachRecord: record),
                isActive: $navigateToFollowUp
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getDayCountColor(days: Int) -> Color {
        if days >= followUpThresholdDays {
            return .orange
        } else if days > 14 {
            return .red
        } else {
            return .blue
        }
    }
}
