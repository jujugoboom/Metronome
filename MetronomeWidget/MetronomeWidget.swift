//
//  MetronomeWidget.swift
//  MetronomeWidget
//
//  Created by Justin Covell on 9/20/24.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct MetronomeWidget: Widget {
    @Environment(\.colorScheme) var colorScheme
    let kind: String = "MetronomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetronomeProvider()) { entry in
            MetronomeWidgetEntryView(entry: entry).containerBackground(Color.clear, for: .widget)
        }.supportedFamilies([.systemSmall, .systemMedium])
    }
}


#Preview(as: .systemMedium) {
    MetronomeWidget()
} timeline: {
    MetronomeEntry(date: Date.now, playing: false, bpm: 120)
    MetronomeEntry(date: Date.now, playing: true, bpm: 120)
}
