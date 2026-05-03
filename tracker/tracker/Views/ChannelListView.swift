import SwiftUI

struct ChannelListView: View {
    @State private var viewModel = ChannelListViewModel()

    var body: some View {
        LoadingStateView(
            state: viewModel.state,
            emptyTitle: AppLocalization.shared.noChannels,
            emptySymbol: "tv.slash",
            retryAction: { await viewModel.loadChannels() }
        ) { channels in
            List(channels) { channel in
                NavigationLink(value: channel) {
                    ChannelRowView(channel: channel)
                }
            }
            .refreshable {
                await viewModel.loadChannels()
            }
        }
        .navigationTitle(AppLocalization.shared.channelsTab)
        .task {
            if case .idle = viewModel.state {
                await viewModel.loadChannels()
            }
        }
    }
}
