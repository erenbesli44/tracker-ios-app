import Foundation

enum APIPath {
    static let channels = "channels/"
    static let topics = "topics/"
    static let videos = "videos/"

    static func channel(channelId: Int) -> String {
        "channels/\(channelId)"
    }

    static func channelTopicsOverview(channelId: Int) -> String {
        "channels/\(channelId)/topics/overview"
    }

    static func channelTopicTimeline(channelId: Int, topicId: Int) -> String {
        "channels/\(channelId)/topics/\(topicId)/timeline"
    }

    static func videoSummary(videoId: Int) -> String {
        "videos/\(videoId)/summary"
    }

    static func videoClassification(videoId: Int) -> String {
        "videos/\(videoId)/classification"
    }

    static func economicThesis(videoId: Int) -> String {
        "videos/\(videoId)/economic-thesis"
    }

    static let ingestYoutube = "ingestions/youtube"
    static let ingestYoutubeURL = "ingestions/youtube/url"

    static func topicOpinions(slug: String) -> String {
        "topics/\(slug)/opinions"
    }
}
