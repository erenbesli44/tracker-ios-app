import Foundation

@Observable
final class IngestViewModel {
    var url: String = ""
    var isLoading = false
    var result: IngestionResponse?
    var error: String?

    var canSubmit: Bool {
        !url.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }

    func ingest() async {
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        result = nil
        error = nil

        do {
            let request = IngestByURLRequest(url: trimmed, transcriptLanguages: ["tr", "en"])
            let response = try await APIClient.shared.post(
                IngestionResponse.self,
                path: APIPath.ingestYoutubeURL,
                body: request
            )
            result = response
            url = ""
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
