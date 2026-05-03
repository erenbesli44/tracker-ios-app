import Foundation

nonisolated struct TopicOpinionsResponse: Codable, Sendable {
    let topic: TopicDetail
    let totalChannels: Int
    let channelOpinions: [ChannelOpinionGroup]
}

nonisolated struct TopicDetail: Codable, Sendable {
    let id: Int
    let name: String
    let slug: String
    let parentId: Int?
    let description: String?
    let createdAt: String
}

nonisolated struct ChannelOpinionGroup: Codable, Identifiable, Sendable {
    let channelId: Int
    let channelName: String
    let channelSlug: String
    let channelHandle: String?
    let avatarUrl: String?
    let mentionCount: Int
    let latestSentiment: String?
    let entries: [ChannelOpinionEntry]

    var id: Int { channelId }

    var asChannel: Channel {
        Channel(
            id: channelId,
            name: channelName,
            slug: channelSlug,
            platform: "youtube",
            channelHandle: channelHandle,
            youtubeChannelId: nil,
            channelUrl: nil,
            bio: nil,
            primaryTopicSlug: nil,
            expectedSubtopics: nil,
            legacyPersonId: nil,
            createdAt: "",
            updatedAt: nil,
            channelMetadata: avatarUrl.map { url in
                ChannelMetadata(
                    youtubeChannelId: nil, channelUrl: nil, channelName: channelName,
                    uploaderId: channelHandle, uploaderUrl: nil, subscriberCount: nil,
                    viewCount: nil, videoCount: nil, isVerified: nil, description: nil,
                    tags: nil, avatarUrl: url, bannerUrl: nil, thumbnails: nil, fetchedAt: nil
                )
            }
        )
    }
}

nonisolated struct ChannelOpinionEntry: Codable, Identifiable, Sendable {
    let mentionId: Int
    let videoId: Int
    let videoTitle: String?
    let videoUrl: String
    let publishedAt: String?
    let summary: String
    let sentiment: String?
    let keyLevels: [String]?
    let confidence: Double

    var id: Int { mentionId }

    func asFeedItem(channel: Channel) -> FeedItem {
        let video = Video(
            id: videoId,
            personId: nil,
            channelId: channel.id,
            platform: channel.platform.isEmpty ? "youtube" : channel.platform,
            videoUrl: videoUrl,
            videoId: String(videoId),
            title: videoTitle,
            publishedAt: publishedAt,
            duration: nil,
            createdAt: publishedAt ?? ""
        )
        return FeedItem(
            channel: channel,
            video: video,
            shortSummary: summary,
            longSummary: nil,
            highlights: [],
            topics: []
        )
    }
}
