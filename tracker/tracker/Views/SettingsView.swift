import SwiftUI

struct SettingsView: View {
    private let loc = AppLocalization.shared

    var body: some View {
        List {
            Section {
                ForEach(AppLanguage.allCases) { language in
                    LanguageRow(language: language)
                }
            } header: {
                Text(loc.languageLabel)
            }

            Section {
                ForEach(AppAppearance.allCases) { appearance in
                    AppearanceRow(appearance: appearance)
                }
            } header: {
                Text(loc.appearanceLabel)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(loc.settingsTab)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AppearanceRow: View {
    let appearance: AppAppearance
    private let loc = AppLocalization.shared
    private let manager = AppearanceManager.shared

    var body: some View {
        Button {
            manager.appearance = appearance
        } label: {
            HStack(spacing: 12) {
                Image(systemName: appearance.icon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                Text(loc.appearanceName(appearance))
                    .foregroundStyle(.primary)

                Spacer()

                if manager.appearance == appearance {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct LanguageRow: View {
    let language: AppLanguage
    private let loc = AppLocalization.shared

    var body: some View {
        Button {
            loc.language = language
        } label: {
            HStack(spacing: 12) {
                Text(language.flag)
                    .font(.title2)

                Text(language.displayName)
                    .foregroundStyle(.primary)

                Spacer()

                if loc.language == language {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 2)
        }
    }
}
