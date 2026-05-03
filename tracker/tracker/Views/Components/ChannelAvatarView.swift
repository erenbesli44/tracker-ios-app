import SwiftUI

struct ChannelAvatarView: View {
    let name: String
    var size: CGFloat = 44
    var url: String? = nil

    var body: some View {
        Group {
            if let urlString = resolvedUrl, let imageUrl = URL(string: urlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var resolvedUrl: String? {
        guard let raw = url, !raw.isEmpty else { return nil }
        return raw.replacingOccurrences(of: "=s0", with: "=s256-c-k-c0x00ffffff-no-rj")
    }

    private var monogram: some View {
        ZStack {
            Circle().fill(background)
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let parts = name
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private var background: LinearGradient {
        let hash = name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let hue = Double(hash % 360) / 360.0
        let top = Color(hue: hue, saturation: 0.55, brightness: 0.92)
        let bottom = Color(hue: hue, saturation: 0.70, brightness: 0.72)
        return LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    HStack(spacing: 16) {
        ChannelAvatarView(name: "Ray Dalio", size: 72)
        ChannelAvatarView(name: "Cem Mansur", size: 44)
        ChannelAvatarView(name: "Finans 101", size: 32)
    }
    .padding()
}
