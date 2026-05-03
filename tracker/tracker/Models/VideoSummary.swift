import Foundation

nonisolated struct VideoSummary: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let videoId: Int
    let shortSummary: String
    let longSummary: String?
    let highlights: [String]?
    let language: String
    let source: String
    let createdAt: String
    let updatedAt: String?
}
