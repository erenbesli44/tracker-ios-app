import Foundation

nonisolated struct EconomicThesis: Codable, Sendable {
    let language: String
    let economicThesis: ThesisCore
    let mainViewForFollowers: MainView
    let macroOutlook: MacroOutlook
    let primaryDriver: PrimaryDriver
    let economicChain: EconomicChain
    let topInsights: [Insight]
    let keyWarnings: [Warning]
    let importantForFollowers: [FollowerPoint]
    let supportingEvidence: [Evidence]
    let secondaryTopics: [SecondaryTopic]
}

nonisolated struct ThesisCore: Codable, Sendable {
    let title: String
    let statement: String
    let confidence: Double
}

nonisolated struct MainView: Codable, Sendable {
    let summary: String
    let actionBias: String
    let confidence: Double
}

nonisolated struct MacroOutlook: Codable, Sendable {
    let direction: String
    let summary: String
}

nonisolated struct PrimaryDriver: Codable, Sendable {
    let label: String
    let summary: String
}

nonisolated struct EconomicChain: Codable, Sendable {
    let cause: String
    let transmission: [TransmissionStep]
    let macroEffect: [MacroEffect]
    let marketEffect: [MarketEffect]
    let finalTakeaway: String
}

nonisolated struct TransmissionStep: Codable, Sendable {
    let step: String
}

nonisolated struct MacroEffect: Codable, Sendable {
    let effect: String
}

nonisolated struct MarketEffect: Codable, Sendable {
    let effect: String
}

nonisolated struct Insight: Codable, Sendable {
    let insight: String
    let importance: Double
}

nonisolated struct Warning: Codable, Sendable {
    let warning: String
    let severity: String
}

nonisolated struct FollowerPoint: Codable, Sendable {
    let point: String
}

nonisolated struct Evidence: Codable, Sendable {
    let evidence: String
}

nonisolated struct SecondaryTopic: Codable, Sendable {
    let topic: String
    let role: String
}
