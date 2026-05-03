import Foundation

@Observable
final class EconomicThesisViewModel {
    var state: LoadingState<EconomicThesis> = .idle
    let videoId: Int

    init(videoId: Int) {
        self.videoId = videoId
    }

    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            let thesis = try await APIClient.shared.postEmpty(
                EconomicThesis.self,
                path: APIPath.economicThesis(videoId: videoId)
            )
            state = .loaded(thesis)
        } catch APIError.notFound {
            state = .error("No transcript available for this video.")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
