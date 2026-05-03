import SwiftUI

struct EconomicThesisView: View {
    let videoId: Int
    let videoTitle: String
    @State private var viewModel: EconomicThesisViewModel

    init(videoId: Int, videoTitle: String) {
        self.videoId = videoId
        self.videoTitle = videoTitle
        _viewModel = State(initialValue: EconomicThesisViewModel(videoId: videoId))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ThesisLoadingView()

            case .error(let message):
                let loc = AppLocalization.shared
                ContentUnavailableView {
                    Label(loc.analysisUnavailable, systemImage: "chart.bar.xaxis.ascending.badge.clock")
                } description: {
                    Text(message)
                } actions: {
                    Button(loc.retry) { Task { await viewModel.load() } }
                }

            case .empty:
                ContentUnavailableView(AppLocalization.shared.noThesisGenerated, systemImage: "doc.text.magnifyingglass")

            case .loaded(let thesis):
                ThesisContent(thesis: thesis)
            }
        }
        .navigationTitle(videoTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Loading placeholder

private struct ThesisLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(AppLocalization.shared.analysingTranscript)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Main content

private struct ThesisContent: View {
    let thesis: EconomicThesis

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // 1. Hero — thesis title + statement + action bias
                ThesisHeroCard(
                    core: thesis.economicThesis,
                    view: thesis.mainViewForFollowers
                )

                // 2. Macro outlook
                MacroOutlookCard(outlook: thesis.macroOutlook)

                // 3. Primary driver
                DriverCard(driver: thesis.primaryDriver)

                // 4. Economic chain
                ChainCard(chain: thesis.economicChain)

                // 5. Key warnings
                if !thesis.keyWarnings.isEmpty {
                    WarningsCard(warnings: thesis.keyWarnings)
                }

                // 6. Insights
                if !thesis.topInsights.isEmpty {
                    InsightsCard(insights: thesis.topInsights)
                }

                // 7. Important for followers
                if !thesis.importantForFollowers.isEmpty {
                    FollowerPointsCard(points: thesis.importantForFollowers)
                }

                // 8. Supporting evidence (quotes)
                if !thesis.supportingEvidence.isEmpty {
                    EvidenceCard(items: thesis.supportingEvidence)
                }

                // 9. Secondary topics (least prominent)
                if !thesis.secondaryTopics.isEmpty {
                    SecondaryTopicsCard(topics: thesis.secondaryTopics)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Hero card

private struct ThesisHeroCard: View {
    let core: ThesisCore
    let view: MainView

    private var actionBias: ActionBias { ActionBias(raw: view.actionBias) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(core.title)
                    .font(.title3.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 12)
                ActionBiasPill(bias: actionBias)
            }

            Text(core.statement)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text(AppLocalization.shared.keyTakeaway)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                Text(view.summary)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }

            HStack {
                Spacer()
                ConfidenceTag(value: core.confidence)
            }
        }
        .cardStyle()
    }
}

// MARK: - Macro outlook

private struct MacroOutlookCard: View {
    let outlook: MacroOutlook

    private var direction: MacroDirection { MacroDirection(raw: outlook.direction) }

    var body: some View {
        let loc = AppLocalization.shared
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.macroOutlook)
            HStack(spacing: 10) {
                Image(systemName: direction.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(direction.color)
                    .frame(width: 32)
                Text(outlook.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .cardStyle()
    }
}

// MARK: - Primary driver

private struct DriverCard: View {
    let driver: PrimaryDriver

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.primaryDriver)
            Text(driver.label)
                .font(.subheadline.weight(.semibold))
            Text(driver.summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .cardStyle()
    }
}

// MARK: - Economic chain

private struct ChainCard: View {
    let chain: EconomicChain

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 12) {
            SectionTitle(loc.economicChain)

            ChainStep(icon: "bolt.fill", color: .orange, label: loc.causeLabel, text: chain.cause)

            if !chain.transmission.isEmpty {
                ChainBlock(
                    icon: "arrow.right",
                    color: .blue,
                    label: loc.transmissionLabel,
                    items: chain.transmission.map { $0.step }
                )
            }

            if !chain.macroEffect.isEmpty {
                ChainBlock(
                    icon: "waveform.path.ecg",
                    color: .purple,
                    label: loc.macroEffects,
                    items: chain.macroEffect.map { $0.effect }
                )
            }

            if !chain.marketEffect.isEmpty {
                ChainBlock(
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    label: loc.marketEffects,
                    items: chain.marketEffect.map { $0.effect }
                )
            }

            ChainStep(icon: "flag.fill", color: .accentColor, label: loc.conclusionLabel, text: chain.finalTakeaway)
        }
        .cardStyle()
    }
}

private struct ChainStep: View {
    let icon: String
    let color: Color
    let label: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
    }
}

private struct ChainBlock: View {
    let icon: String
    let color: Color
    let label: String
    let items: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 6) {
                        Text("·").foregroundStyle(.tertiary)
                        Text(item)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }
                }
            }
        }
    }
}

// MARK: - Warnings

private struct WarningsCard: View {
    let warnings: [Warning]

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.keyWarnings)
            ForEach(warnings, id: \.warning) { w in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SeverityColor.color(for: w.severity))
                        .frame(width: 20)
                        .padding(.top, 1)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(w.warning)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                        Text(w.severity.capitalized)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(SeverityColor.color(for: w.severity))
                    }
                }
            }
        }
        .cardStyle()
    }
}

private enum SeverityColor {
    static func color(for severity: String) -> Color {
        switch severity.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .yellow
        }
    }
}

// MARK: - Insights

private struct InsightsCard: View {
    let insights: [Insight]

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.topInsights)
            ForEach(insights, id: \.insight) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                        .frame(width: 20)
                        .padding(.top, 1)
                    Text(item.insight)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Follower points

private struct FollowerPointsCard: View {
    let points: [FollowerPoint]

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.importantForFollowers)
            ForEach(points, id: \.point) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "person.fill.checkmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 20)
                        .padding(.top, 1)
                    Text(item.point)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Evidence

private struct EvidenceCard: View {
    let items: [Evidence]

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.supportingEvidence)
            ForEach(items, id: \.evidence) { item in
                HStack(alignment: .top, spacing: 8) {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.6))
                        .frame(width: 3)
                        .clipShape(Capsule())
                    Text(item.evidence)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Secondary topics

private struct SecondaryTopicsCard: View {
    let topics: [SecondaryTopic]

    var body: some View {
        let loc = AppLocalization.shared
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(loc.secondaryTopics)
            FlowLayout(spacing: 6) {
                ForEach(topics, id: \.topic) { item in
                    HStack(spacing: 4) {
                        Text(item.topic)
                            .font(.caption.weight(.medium))
                        Text("·")
                            .foregroundStyle(.tertiary)
                            .font(.caption2)
                        Text(item.role)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray6), in: Capsule())
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Shared helpers

private struct SectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.tertiary)
            .textCase(.uppercase)
            .tracking(0.4)
    }
}

private struct ConfidenceTag: View {
    let value: Double

    var body: some View {
        Text("\(Int(value * 100))% \(AppLocalization.shared.confidence)")
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
}

// MARK: - Action bias

private enum ActionBias {
    case riskOff, riskOn, cautious, neutral, mixed

    init(raw: String) {
        switch raw.lowercased() {
        case "risk_off": self = .riskOff
        case "risk_on": self = .riskOn
        case "cautious": self = .cautious
        case "neutral": self = .neutral
        default: self = .mixed
        }
    }

    var label: String {
        let loc = AppLocalization.shared
        switch self {
        case .riskOff: return loc.riskOff
        case .riskOn: return loc.riskOn
        case .cautious: return loc.cautious
        case .neutral: return loc.neutral
        case .mixed: return loc.mixed
        }
    }

    var symbol: String {
        switch self {
        case .riskOff: return "shield.fill"
        case .riskOn: return "flame.fill"
        case .cautious: return "eye.fill"
        case .neutral: return "minus"
        case .mixed: return "arrow.left.arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .riskOff: return .red
        case .riskOn: return .green
        case .cautious: return .orange
        case .neutral: return .gray
        case .mixed: return .purple
        }
    }
}

private struct ActionBiasPill: View {
    let bias: ActionBias

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: bias.symbol)
                .font(.caption2.weight(.bold))
            Text(bias.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(bias.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(bias.color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Macro direction

private enum MacroDirection {
    case positive, negative, mixed, uncertain

    init(raw: String) {
        switch raw.lowercased() {
        case "positive": self = .positive
        case "negative": self = .negative
        case "mixed": self = .mixed
        default: self = .uncertain
        }
    }

    var symbol: String {
        switch self {
        case .positive: return "arrow.up.right.circle.fill"
        case .negative: return "arrow.down.right.circle.fill"
        case .mixed: return "arrow.left.arrow.right.circle.fill"
        case .uncertain: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .mixed: return .orange
        case .uncertain: return .gray
        }
    }
}

// MARK: - Card modifier

private extension View {
    func cardStyle() -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color(.systemGray5), lineWidth: 0.5)
            )
    }
}
