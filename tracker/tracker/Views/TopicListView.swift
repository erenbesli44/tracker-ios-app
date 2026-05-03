import SwiftUI

struct TopicListView: View {
    @State private var viewModel = TopicListViewModel()

    var body: some View {
        LoadingStateView(
            state: viewModel.state,
            emptyTitle: AppLocalization.shared.noTopics,
            emptySymbol: "tag",
            retryAction: { await viewModel.load() }
        ) { topics in
            List(topics) { topic in
                NavigationLink(value: topic) {
                    TopicListRowView(topic: topic)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle(AppLocalization.shared.topicsTab)
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }
}

private struct TopicListRowView: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor(for: topic.slug).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon(for: topic.slug))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor(for: topic.slug))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(topic.name)
                    .font(.body)
                    .fontWeight(.medium)
                if let desc = topic.description, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func icon(for slug: String) -> String {
        let s = slug.lowercased()
        if s.contains("macro") || s.contains("economy") { return "globe.americas" }
        if s.contains("crypto") || s.contains("bitcoin") || s.contains("defi") { return "bitcoinsign.circle" }
        if s.contains("tech") || s.contains("ai") || s.contains("software") { return "cpu" }
        if s.contains("energy") || s.contains("oil") || s.contains("gas") { return "bolt" }
        if s.contains("real.estate") || s.contains("realestate") || s.contains("housing") { return "building.2" }
        if s.contains("rate") || s.contains("fed") || s.contains("monetary") { return "percent" }
        if s.contains("earning") || s.contains("revenue") { return "chart.bar" }
        if s.contains("equity") || s.contains("stock") { return "chart.line.uptrend.xyaxis" }
        if s.contains("commodity") || s.contains("gold") || s.contains("metal") { return "cube.box" }
        if s.contains("geopolit") || s.contains("war") || s.contains("conflict") { return "flag" }
        return "tag"
    }

    private func iconColor(for slug: String) -> Color {
        let s = slug.lowercased()
        if s.contains("crypto") || s.contains("bitcoin") { return .orange }
        if s.contains("tech") || s.contains("ai") { return .blue }
        if s.contains("energy") || s.contains("oil") { return .yellow }
        if s.contains("rate") || s.contains("fed") { return .purple }
        if s.contains("earning") || s.contains("stock") || s.contains("equity") { return .green }
        if s.contains("real.estate") || s.contains("housing") { return .brown }
        if s.contains("geopolit") || s.contains("war") { return .red }
        if s.contains("commodity") || s.contains("gold") { return .yellow }
        if s.contains("macro") || s.contains("economy") { return .teal }
        return .accentColor
    }
}
