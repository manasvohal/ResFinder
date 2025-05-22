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
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                    Text(record.professorName)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(formatDate(record.dateEmailed))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                // Days counter with prominent display
                VStack(alignment: .center, spacing: 0) {
                    Text("\(record.daysSinceContact)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(getDayCountColor(days: record.daysSinceContact))

                    Text(record.daysSinceContact == 1 ? "day" : "days")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(width: 60)
                .padding(.horizontal, AppTheme.Spacing.xxxSmall)
            }
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xSmall)

            // Preview of email with expand/collapse
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                Text(isExpanded ? record.emailSent : record.emailSent.prefix(100) + "...")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineLimit(isExpanded ? nil : 2)
                    .padding(.horizontal, AppTheme.Spacing.small)

                Button(action: {
                    withAnimation { isExpanded.toggle() }
                }) {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.accent)
                        .padding(.horizontal, AppTheme.Spacing.small)
                }
            }
            .padding(.bottom, AppTheme.Spacing.xSmall)

            // Follow‑up section
            if record.hasFollowedUp {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                    Divider()
                        .background(AppTheme.Colors.divider)
                        .padding(.horizontal, AppTheme.Spacing.small)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.success)
                            .font(.system(size: 14))

                        Text("Follow-up sent on \(formatDate(record.followUpDate ?? Date()))")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.vertical, AppTheme.Spacing.xxSmall)
                }
            } else {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxSmall) {
                    Divider()
                        .background(AppTheme.Colors.divider)
                        .padding(.horizontal, AppTheme.Spacing.small)

                    Button(action: { navigateToFollowUp = true }) {
                        HStack {
                            Image(systemName: "envelope.badge.clock.fill")
                                .font(.system(size: 14))
                            Text("Send Follow-up Email")
                                .font(AppTheme.Typography.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.xxSmall)
                        .background(AppTheme.Colors.warning)
                        .cornerRadius(AppTheme.CornerRadius.small)
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.vertical, AppTheme.Spacing.xxSmall)
                    }
                }
            }
        }
        .darkCard()
        .background(
            NavigationLink(
                destination: FollowUpEmailView(outreachRecord: record),
                isActive: $navigateToFollowUp
            ) { EmptyView() }
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
            return AppTheme.Colors.warning
        } else if days > 14 {
            return AppTheme.Colors.accent
        } else {
            return AppTheme.Colors.accent
        }
    }
}
