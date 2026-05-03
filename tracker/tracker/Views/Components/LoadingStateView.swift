import SwiftUI

struct LoadingStateView<T: Sendable, Content: View>: View {
    let state: LoadingState<T>
    let emptyTitle: String
    let emptySymbol: String
    let retryAction: (@Sendable () async -> Void)?
    @ViewBuilder let content: (T) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let data):
            content(data)

        case .empty:
            ContentUnavailableView(
                emptyTitle,
                systemImage: emptySymbol
            )

        case .error(let message):
            let loc = AppLocalization.shared
            ContentUnavailableView {
                Label(loc.somethingWentWrong, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                if let retryAction {
                    Button(loc.tryAgain) {
                        Task { await retryAction() }
                    }
                }
            }
        }
    }
}
