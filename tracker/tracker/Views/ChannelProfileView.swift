import SwiftUI

fileprivate enum ProfileTab: String, CaseIterable, Identifiable {
    case opinions
    case videos
    var id: String { rawValue }
    var label: String {
        switch self {
        case .opinions: return AppLocalization.shared.opinionsTab
        case .videos:   return AppLocalization.shared.videosTab
        }
    }
}

struct ChannelProfileView: View {
    @State private var viewModel: ChannelProfileViewModel
    @State private var selectedTab: ProfileTab = .opinions

    init(channel: Channel) {
        _viewModel = State(initialValue: ChannelProfileViewModel(channel: channel))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileHeader(channel: viewModel.channel)

                TabSwitcher(selection: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                Divider()
                    .padding(.top, 12)

                Group {
                    switch selectedTab {
                    case .opinions:
                        OpinionsSection(state: viewModel.state, channel: viewModel.channel) {
                            await viewModel.load()
                        }
                    case .videos:
                        VideosTabLink(channel: viewModel.channel)
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(viewModel.channel.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.load() }
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
        .navigationDestination(for: TopicOverview.self) { topic in
            ChannelTopicDetailView(channel: viewModel.channel, topicOverview: topic)
        }
    }


}

// MARK: - Header

private struct ProfileHeader: View {
    let channel: Channel

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                ChannelAvatarView(name: channel.name, size: 72, url: channel.channelMetadata?.avatarUrl)

                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.name)
                        .font(.title3.weight(.bold))
                        .lineLimit(1)

                    if let handle = channel.channelHandle ?? channel.channelMetadata?.uploaderId {
                        Text(handle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: platformSymbol)
                            .font(.caption2)
                        Text(channel.platform.capitalized)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            if let bio = bioText, !bio.isEmpty {
                Text(bio)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }

}
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var bioText: String? {
        if let bio = channel.bio, !bio.isEmpty { return bio }
        return channel.channelMetadata?.description
    }

    private var platformSymbol: String {
        switch channel.platform.lowercased() {
        case "youtube": return "play.rectangle.fill"
        case "twitter", "x": return "bubble.left.fill"
        default: return "link"
        }
    }
}

// MARK: - Tab Switcher

private struct TabSwitcher: View {
    @Binding var selection: ProfileTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.label)
                            .font(.subheadline.weight(selection == tab ? .semibold : .regular))
                            .foregroundStyle(selection == tab ? Color.primary : .secondary)
                        Rectangle()
                            .fill(selection == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Opinions Tab

private struct OpinionsSection: View {
    let state: LoadingState<[TopicOverview]>
    let channel: Channel
    let reload: @Sendable () async -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .padding(.top, 60)
                .frame(maxWidth: .infinity)

        case .empty:
            let loc = AppLocalization.shared
            ContentUnavailableView(
                loc.noOpinionsYet,
                systemImage: "text.bubble",
                description: Text(loc.noOpinionsDesc)
            )
            .padding(.top, 24)

        case .error(let message):
            let loc = AppLocalization.shared
            ContentUnavailableView {
                Label(loc.couldntLoadOpinions, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button(loc.tryAgain) { Task { await reload() } }
            }
            .padding(.top, 24)

        case .loaded(let topics):
            LazyVStack(spacing: 10) {
                ForEach(topics) { topic in
                    NavigationLink(value: topic) {
                        TopicOpinionCard(topic: topic)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Topic Opinion Card

private struct TopicOpinionCard: View {
    let topic: TopicOverview

    private var stance: Stance {
        Stance(rawSentiment: topic.latestSentiment)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left stance rail for instant glance
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(stance.color)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(topic.topic.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    StancePill(stance: stance)
                }

                Text(topic.latestSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 10) {
                    Label("\(topic.mentionCount)", systemImage: "quote.bubble")
                        .labelStyle(.titleAndIcon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let relative = DateFormatting.relativeDate(topic.latestPublishedAt) {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)
            .padding(.trailing, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

// MARK: - Videos Tab (links to existing feed view)

private struct VideosTabLink: View {
    let channel: Channel

    var body: some View {
        ChannelFeedView(channel: channel)
            .frame(minHeight: 400)
    }
}

// MARK: - Per-topic detail placeholder (drills into existing feed filtered by topic)

struct ChannelTopicDetailView: View {
    let channel: Channel
    let topicOverview: TopicOverview

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ChannelAvatarView(name: channel.name, size: 36, url: channel.channelMetadata?.avatarUrl)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(channel.name)
                            .font(.subheadline.weight(.semibold))
                        Text(AppLocalization.shared.onTopic(topicOverview.topic.name))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StancePill(stance: Stance(rawSentiment: topicOverview.latestSentiment))
                }

                Text(topicOverview.latestSummary)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                if let published = DateFormatting.displayDate(topicOverview.latestPublishedAt) {
                    Text("\(AppLocalization.shared.latestTake) · \(published)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationTitle(topicOverview.topic.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
