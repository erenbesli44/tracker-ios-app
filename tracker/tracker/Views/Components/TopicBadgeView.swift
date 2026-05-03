import SwiftUI

struct TopicBadgeView: View {
    let name: String
    let sentiment: String?
    var tappable: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let sentiment {
                Circle()
                    .fill(sentimentColor(sentiment))
                    .frame(width: 6, height: 6)
            }

            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            if tappable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Color.accentColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(tappable ? 0.08 : 0.12))
        .clipShape(Capsule())
        .overlay(
            tappable
                ? Capsule().strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1)
                : nil
        )
    }

    private func sentimentColor(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "bullish":
            return .green
        case "bearish":
            return .red
        case "neutral":
            return .orange
        default:
            return .secondary
        }
    }
}
