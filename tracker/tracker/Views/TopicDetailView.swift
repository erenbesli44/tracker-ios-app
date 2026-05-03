import SwiftUI

struct TopicDetailView: View {
    let topic: ResolvedTopic
    @State private var showDetails = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Topic header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(topic.name)
                            .font(.title2)
                            .fontWeight(.semibold)

                        if let sentiment = topic.sentiment {
                            TopicBadgeView(name: sentiment.capitalized, sentiment: sentiment)
                        }
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDetails.toggle()
                        }
                    } label: {
                        Image(systemName: showDetails ? "info.circle.fill" : "info.circle")
                            .font(.title3)
                            .foregroundStyle(showDetails ? Color.accentColor : Color.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }

                let loc = AppLocalization.shared
                // Summary
                if let summary = topic.summary, !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        label(loc.analysis)
                        Text(summary)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }

                // Details (key levels + confidence) — revealed by info button
                if showDetails {
                    VStack(alignment: .leading, spacing: 16) {
                        if !topic.keyLevels.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                label(loc.keyLevels)
                                FlowLayout(spacing: 8) {
                                    ForEach(topic.keyLevels, id: \.self) { level in
                                        Text(level)
                                            .font(.callout)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }

                        if let confidence = topic.confidence {
                            VStack(alignment: .leading, spacing: 4) {
                                label(loc.confidence)
                                Text("\(Int(confidence * 100))%")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle(topic.name)
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
