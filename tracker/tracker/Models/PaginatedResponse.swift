import Foundation

nonisolated struct PaginatedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let items: [T]
    let total: Int
    let page: Int
    let size: Int
    let pages: Int
}
