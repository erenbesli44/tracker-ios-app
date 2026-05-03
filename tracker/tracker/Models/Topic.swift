import Foundation

nonisolated struct Topic: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let slug: String
    let parentId: Int?
    let description: String?
    let createdAt: String
}
