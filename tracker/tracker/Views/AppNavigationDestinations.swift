import SwiftUI

/// Centralized navigation destinations. Applied once per tab's NavigationStack
/// so every view in the stack can push any app-level route without redeclaring.
struct AppNavigationDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FeedItem.self) { item in
                VideoDetailView(item: item)
            }
            .navigationDestination(for: ResolvedTopic.self) { topic in
                TopicDetailView(topic: topic)
            }
            .navigationDestination(for: VideoSummary.self) { summary in
                SummaryReadView(summary: summary)
            }
            .navigationDestination(for: EconomicThesisTarget.self) { target in
                EconomicThesisView(videoId: target.videoId, videoTitle: target.videoTitle)
            }
            .navigationDestination(for: Channel.self) { channel in
                ChannelProfileView(channel: channel)
            }
            .navigationDestination(for: Topic.self) { topic in
                TopicOpinionsView(topic: topic)
            }
    }
}

extension View {
    func appNavigationDestinations() -> some View {
        modifier(AppNavigationDestinations())
    }
}
