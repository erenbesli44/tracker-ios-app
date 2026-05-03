import SwiftUI

enum Stance {
    case bullish, bearish, neutral, unknown

    init(rawSentiment: String?) {
        switch rawSentiment?.lowercased() {
        case "bullish": self = .bullish
        case "bearish": self = .bearish
        case "neutral": self = .neutral
        default: self = .unknown
        }
    }

    var label: String {
        let loc = AppLocalization.shared
        switch self {
        case .bullish: return loc.bullish
        case .bearish: return loc.bearish
        case .neutral: return loc.neutral
        case .unknown: return "—"
        }
    }

    var symbol: String {
        switch self {
        case .bullish: return "arrow.up.right"
        case .bearish: return "arrow.down.right"
        case .neutral: return "minus"
        case .unknown: return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .orange
        case .unknown: return .gray
        }
    }
}

struct StancePill: View {
    let stance: Stance

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: stance.symbol)
                .font(.caption2.weight(.bold))
            Text(stance.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(stance.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(stance.color.opacity(0.12), in: Capsule())
    }
}
