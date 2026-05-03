import SwiftUI

struct VideoDetailView: View {
    @State private var viewModel: VideoDetailViewModel

    init(item: FeedItem) {
        _viewModel = State(initialValue: VideoDetailViewModel(item: item))
    }

    private var item: FeedItem { viewModel.item }

    private let loc = AppLocalization.shared

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.video.title ?? loc.untitled)
                        .font(.body)
                        .fontWeight(.medium)

                    HStack(spacing: 4) {
                        Text(item.channel.name)

                        if let dateText = DateFormatting.displayDate(item.video.publishedAt ?? item.video.createdAt) {
                            Text("·")
                            Text(dateText)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }

            if !item.highlights.isEmpty {
                Section {
                    ForEach(item.highlights, id: \.self) { highlight in
                        HStack(alignment: .top, spacing: 8) {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(highlight)
                                .font(.subheadline)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 1)
                    }
                } header: {
                    Text(loc.highlights)
                }
            }

            if !item.topics.isEmpty {
                Section {
                    ForEach(item.topics) { topic in
                        NavigationLink(value: topic) {
                            TopicRowView(topic: topic)
                        }
                    }
                } header: {
                    Text(loc.topicsLabel)
                }
            }

            if FeatureFlags.showFullSummary && (item.longSummary != nil || item.shortSummary != nil) {
                Section {
                    NavigationLink(value: makeSummary()) {
                        Text(loc.fullSummary)
                            .font(.body)
                    }
                }
            }

            if let url = URL(string: item.video.videoUrl) {
                Section {
                    Link(destination: url) {
                        HStack {
                            Text(loc.watchSource)
                                .font(.body)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isEnriching && item.highlights.isEmpty && item.topics.isEmpty {
                ProgressView()
            }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    private func makeSummary() -> VideoSummary {
        VideoSummary(
            id: item.video.id,
            videoId: item.video.id,
            shortSummary: item.shortSummary ?? "",
            longSummary: item.longSummary,
            highlights: item.highlights.isEmpty ? nil : item.highlights,
            language: "",
            source: "",
            createdAt: "",
            updatedAt: nil
        )
    }
}

struct TopicRowView: View {
    let topic: ResolvedTopic

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(topic.name)
                    .font(.body)

                if let summary = topic.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if let sentiment = topic.sentiment {
                TopicBadgeView(name: AppLocalization.shared.sentimentLabel(sentiment), sentiment: sentiment)
            }
        }
        .padding(.vertical, 2)
    }
}
