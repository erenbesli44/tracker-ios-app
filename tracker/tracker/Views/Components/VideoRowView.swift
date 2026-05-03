import SwiftUI

struct VideoRowView: View {
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(video.title ?? AppLocalization.shared.untitled)
                .font(.headline)
                .lineLimit(2)

            HStack(spacing: 8) {
                if let dateText = DateFormatting.relativeDate(video.publishedAt) {
                    Text(dateText)
                }

            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
