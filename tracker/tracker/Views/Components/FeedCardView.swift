import SwiftUI

struct FeedCardView: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Channel + date row
            HStack(alignment: .center, spacing: 10) {
                ChannelAvatarView(
                    name: item.channel.name,
                    size: 32,
                    url: item.channel.channelMetadata?.avatarUrl
                )

                Text(item.channel.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                if let relative = DateFormatting.relativeDate(item.video.publishedAt ?? item.video.createdAt) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(relative)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.accentColor.opacity(0.85))
                }
            }

            // Video title
            Text(item.video.title ?? AppLocalization.shared.untitled)
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Highlights
            if !item.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(item.highlights.prefix(3).enumerated()), id: \.offset) { index, highlight in
                        HStack(alignment: .top, spacing: 10) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor.opacity(0.5))
                                .frame(width: 2)
                                .padding(.vertical, 2)

                            Text(highlight)
                                .font(.footnote)
                                .foregroundStyle(.primary.opacity(0.8))
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            index % 2 == 0
                                ? Color(.secondarySystemBackground)
                                : Color(.secondarySystemBackground).opacity(0.5)
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 2)
            }

            // Topic badges
            if !item.topics.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(item.topics.prefix(4)) { topic in
                        NavigationLink(value: topic) {
                            TopicBadgeView(name: topic.name, sentiment: topic.sentiment, tappable: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
