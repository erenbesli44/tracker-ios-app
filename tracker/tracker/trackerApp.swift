//
//  trackerApp.swift
//  tracker
//
//  Created by EREN BESLI on 11.04.2026.
//

import SwiftUI

@main
struct trackerApp: App {
    private let appearance = AppearanceManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearance.appearance.colorScheme)
        }
    }
}

private struct RootView: View {
    private let loc = AppLocalization.shared

    @State private var feedCoordinator = NavigationCoordinator()
    @State private var topicsCoordinator = NavigationCoordinator()
    @State private var channelsCoordinator = NavigationCoordinator()

    var body: some View {
        TabView {
            tabStack(coordinator: feedCoordinator) {
                FeedView()
            }
            .tabItem {
                Label(loc.feedTab, systemImage: "newspaper")
            }

            tabStack(coordinator: topicsCoordinator) {
                TopicListView()
            }
            .tabItem {
                Label(loc.topicsTab, systemImage: "tag")
            }

            tabStack(coordinator: channelsCoordinator) {
                ChannelListView()
            }
            .tabItem {
                Label(loc.channelsTab, systemImage: "play.rectangle.on.rectangle")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(loc.settingsTab, systemImage: "gearshape")
            }
        }
    }

    private func tabStack<Root: View>(
        coordinator: NavigationCoordinator,
        @ViewBuilder root: () -> Root
    ) -> some View {
        NavigationStack(path: Binding(
            get: { coordinator.path },
            set: { coordinator.path = $0 }
        )) {
            root()
                .appNavigationDestinations()
        }
        .environment(coordinator)
    }
}
