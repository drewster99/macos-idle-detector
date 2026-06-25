//
//  ContentView.swift
//  IdleDetector
//

import SwiftUI

struct ContentView: View {
    let monitor: IdleMonitor

    private var statusColor: Color { monitor.isIdle ? AppTheme.idle : AppTheme.active }

    private var lastInputDescription: String {
        let seconds = monitor.idleSeconds
        if seconds < 1 { return "active now" }
        return String(format: "last input %.0fs ago", seconds)
    }

    var body: some View {
        @Bindable var monitor = monitor

        VStack(spacing: 22) {
            Text("Idle Detector")
                .font(AppFont.appTitle)
                .foregroundStyle(.secondary)

            statusDial

            Text(lastInputDescription)
                .font(AppFont.counter)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.default, value: Int(monitor.idleSeconds))

            ProgressView(value: monitor.progressToIdle)
                .tint(statusColor)

            HStack(spacing: 14) {
                StatTile(label: "Mouse", seconds: monitor.mouseIdleSeconds)
                StatTile(label: "Keyboard", seconds: monitor.keyboardIdleSeconds)
            }

            thresholdControl(threshold: $monitor.idleThreshold)

            Text("System-wide — measured from the HID event stream for the whole machine, not a single app. No special permission required.")
                .font(AppFont.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(28)
        .frame(width: 380)
        .background(AppTheme.windowBackground)
    }

    private var statusDial: some View {
        ZStack {
            Circle()
                .fill(statusColor.gradient)
                .shadow(color: statusColor.opacity(0.45), radius: 26)
            VStack(spacing: 8) {
                Image(systemName: monitor.isIdle ? "moon.zzz.fill" : "bolt.fill")
                    .font(AppFont.statusGlyph)
                Text(monitor.isIdle ? "IDLE" : "ACTIVE")
                    .font(AppFont.status)
            }
            .foregroundStyle(.white)
        }
        .frame(width: 180, height: 180)
        .animation(.easeInOut(duration: 0.3), value: monitor.isIdle)
    }

    private func thresholdControl(threshold: Binding<Double>) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text("Idle after")
                Spacer()
                Text("\(Int(threshold.wrappedValue))s")
                    .font(AppFont.statValue)
                    .monospacedDigit()
            }
            Slider(value: threshold, in: 2...300, step: 1)
        }
        .padding(14)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct StatTile: View {
    let label: String
    let seconds: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1fs", seconds))
                .font(AppFont.statValue)
                .contentTransition(.numericText())
            Text(label)
                .font(AppFont.statLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 10))
    }
}
