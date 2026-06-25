//
//  IdleDetectorApp.swift
//  IdleDetector
//

import SwiftUI

@main
struct IdleDetectorApp: App {
    @State private var monitor = IdleMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView(monitor: monitor)
                .task { monitor.start() }
        }
        .windowResizability(.contentSize)
    }
}
