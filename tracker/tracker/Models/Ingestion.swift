import Foundation

// MARK: - Request

nonisolated struct IngestByURLRequest: Encodable, Sendable {
    let url: String
    let transcriptLanguages: [String]?
}

// MARK: - Response

nonisolated struct IngestionResponse: Codable, Sendable {
    let status: String
    let videoId: Int
    let personId: Int?
    let channelId: Int
    let transcriptId: Int?
    let summaryId: Int?
    let videoAction: String?
    let transcriptAction: String?
    let summaryAction: String?
    let classificationAction: String?
}
