import SwiftUI

struct SummaryReadView: View {
    let summary: VideoSummary
    private let loc = AppLocalization.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !summary.shortSummary.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        label(loc.quickTake)
                        Text(summary.shortSummary)
                            .font(.body)
                            .fontWeight(.medium)
                            .lineSpacing(4)
                    }
                }

                // Long summary
                if let long = summary.longSummary, !long.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        label(loc.fullSummary)
                        Text(long)
                            .font(.body)
                            .lineSpacing(5)
                    }
                }

                // Highlights
                if let highlights = summary.highlights, !highlights.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        label(loc.highlights)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(highlights, id: \.self) { highlight in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("·")
                                        .foregroundStyle(.secondary)
                                    Text(highlight)
                                        .font(.body)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle(loc.summaryTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}
