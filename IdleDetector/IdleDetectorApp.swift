//
//  IdleDetectorApp.swift
//  IdleDetector
//

import SwiftUI

@main
struct IdleDetectorApp: App {
    var body: some Scene {
        // Each window owns its own IdleMonitor (created inside ContentView), so opening a
        // second window doesn't share the first's toggle/threshold state.
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
