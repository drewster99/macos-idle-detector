//
//  AppStyling.swift
//  IdleDetector
//
//  Centralized colors and fonts so the UI has one source of truth for its look.
//

import SwiftUI

enum AppTheme {
    /// Shown when the user is active (recent input).
    static let active = Color(red: 0.20, green: 0.78, blue: 0.43)

    /// Shown once the user has crossed the idle threshold.
    static let idle = Color(red: 0.96, green: 0.62, blue: 0.18)

    static let windowBackground = Color(nsColor: .windowBackgroundColor)
    static let cardBackground = Color(nsColor: .controlBackgroundColor)
}

enum AppFont {
    static let appTitle = Font.title3.weight(.semibold)
    static let status = Font.system(size: 26, weight: .heavy, design: .rounded)
    static let statusGlyph = Font.system(size: 50, weight: .bold)
    static let counter = Font.system(.title2, design: .rounded).monospacedDigit()
    static let statValue = Font.system(.title3, design: .rounded).monospacedDigit().weight(.semibold)
    static let statLabel = Font.caption.weight(.medium)
    static let caption = Font.footnote
}
