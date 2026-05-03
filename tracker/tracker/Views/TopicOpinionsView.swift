import SwiftUI

struct TopicOpinionsView: View {
    @State private var viewModel: TopicOpinionsViewModel

    init(topic: Topic) {
        _viewModel = State(initialValue: TopicOpinionsViewModel(topic: topic))
    }

    var body: some View {
        LoadingStateView(
            state: viewModel.state,
            emptyTitle: AppLocalization.shared.noOpinionsTopic,
            emptySymbol: "text.bubble",
            retryAction: { await viewModel.load() }
        ) { response in
            List {
                Section {
                    SentimentSummaryBar(opinions: response.channelOpinions)
                }

                // MARK: Channel Opinions
                ForEach(response.channelOpinions) { group in
                    Section {
                        if let entry = group.entries.first {
                            OpinionEntryRow(entry: entry, channel: group.asChannel)
                        }
                    } header: {
                        NavigationLink(value: group.asChannel) {
                            ChannelOpinionHeader(group: group)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle(viewModel.topic.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Sentiment Summary Bar

private struct SentimentSummaryBar: View {
    let opinions: [ChannelOpinionGroup]

    private var bullish: Int { opinions.filter { $0.latestSentiment?.lowercased() == "bullish" }.count }
    private var bearish: Int { opinions.filter { $0.latestSentiment?.lowercased() == "bearish" }.count }
    private var neutral: Int { opinions.filter { $0.latestSentiment?.lowercased() == "neutral" }.count }
    private var total: Int { opinions.count }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                let loc = AppLocalization.shared
                SentimentCount(count: bullish, label: loc.bullish, color: .green)
                Divider().frame(height: 28)
                SentimentCount(count: bearish, label: loc.bearish, color: .red)
                Divider().frame(height: 28)
                SentimentCount(count: neutral, label: loc.neutral, color: .orange)
            }

            if total > 0 {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        if bullish > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green)
                                .frame(width: geo.size.width * CGFloat(bullish) / CGFloat(total))
                        }
                        if neutral > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * CGFloat(neutral) / CGFloat(total))
                        }
                        if bearish > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(bearish) / CGFloat(total))
                        }
                    }
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SentimentCount: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(count > 0 ? color : .secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Channel Opinion Header

private struct ChannelOpinionHeader: View {
    let group: ChannelOpinionGroup

    var body: some View {
        HStack(spacing: 12) {
            ChannelAvatarView(name: group.channelName, size: 40, url: group.avatarUrl)

            VStack(alignment: .leading, spacing: 2) {
                Text(group.channelName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let handle = group.channelHandle, !handle.isEmpty {
                    Text(handle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let relative = DateFormatting.relativeDate(group.entries.first?.publishedAt) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(relative)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.accentColor.opacity(0.85))
                }

                HStack(spacing: 6) {
                    Text("\(group.mentionCount) \(AppLocalization.shared.mentions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let sentiment = group.latestSentiment {
                        SentimentBadge(sentiment: sentiment)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .textCase(nil)
    }
}

// MARK: - Opinion Entry Row

private struct OpinionEntryRow: View {
    let entry: ChannelOpinionEntry
    let channel: Channel
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date + sentiment
            HStack(spacing: 6) {
                if let relative = DateFormatting.relativeDate(entry.publishedAt) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(relative)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.accentColor.opacity(0.85))
                }

                if let displayDate = DateFormatting.shortDate(entry.publishedAt) {
                    Text("· \(displayDate)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let sentiment = entry.sentiment {
                    SentimentBadge(sentiment: sentiment)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDetails.toggle()
                    }
                } label: {
                    Image(systemName: showDetails ? "info.circle.fill" : "info.circle")
                        .font(.caption)
                        .foregroundStyle(showDetails ? Color.accentColor : Color.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            // Video title
            if let title = entry.videoTitle, !title.isEmpty {
                NavigationLink(value: entry.asFeedItem(channel: channel)) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 1)
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.primary.opacity(0.75))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            // Summary text
            Text(entry.summary)
                .font(.subheadline)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            // Details (key levels + confidence) — revealed by info button
            if showDetails {
                VStack(alignment: .leading, spacing: 6) {
                    if let levels = entry.keyLevels, !levels.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(levels.joined(separator: " / "))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text(AppLocalization.shared.confidence)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("\(Int(entry.confidence * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sentiment Components

private struct SentimentDot: View {
    let sentiment: String

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }

    private var color: Color {
        switch sentiment.lowercased() {
        case "bullish": return .green
        case "bearish": return .red
        case "neutral": return .orange
        default: return .gray
        }
    }
}

private struct SentimentBadge: View {
    let sentiment: String

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        let loc = AppLocalization.shared
        switch sentiment.lowercased() {
        case "bullish": return loc.bullish
        case "bearish": return loc.bearish
        case "neutral": return loc.neutral
        default: return sentiment.capitalized
        }
    }

    private var color: Color {
        switch sentiment.lowercased() {
        case "bullish": return .green
        case "bearish": return .red
        case "neutral": return .orange
        default: return .gray
        }
    }
}
