import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        LoadingStateView(
            state: viewModel.state,
            emptyTitle: AppLocalization.shared.noContent,
            emptySymbol: "tray",
            retryAction: { await viewModel.load() }
        ) { items in
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        FeedCardView(item: item)
                    }
                    .listRowSeparator(.visible)
                    .onAppear {
                        if item.id == items.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle(AppLocalization.shared.feedTab)
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }
}
