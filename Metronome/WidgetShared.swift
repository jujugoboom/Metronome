//
//  WidgetShared.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//

import SwiftUI
import SwiftData
import AppIntents
import WidgetKit

struct MetronomeEntry: TimelineEntry {
    var date: Date
    
    var playing: Bool
    var bpm: Double
}

struct PlayMetronome: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Start metronome"
    
    init() {
        
    }
    
    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(sharedModelContainer)
        guard let config = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
            return .result()
        }
        await Metronome.shared.setConfiguration(configuration: config)
        await Metronome.shared.play()
        config.playing = true
        try modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct StopMetronome: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Stop metronome"
    
    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(sharedModelContainer)
        guard let config = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
            return .result()
        }
        await Metronome.shared.setConfiguration(configuration: config)
        await Metronome.shared.stop()
        config.playing = false
        try modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct IncrementBPM: AppIntent {
    static var title: LocalizedStringResource = "Increment current bpm"
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init(amount: Int) {
        self.amount = amount
    }
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(sharedModelContainer)
        guard let configuration = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
            return .result()
        }
        configuration.bpm += Double(amount)
        try modelContext.save()
        await Metronome.shared.setConfiguration(configuration: configuration)
        if configuration.playing {
            Task {
                await Metronome.shared.play()
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

}

struct DecrementBPM: AppIntent {
    static var title: LocalizedStringResource = "Increment current bpm"
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init(amount: Int) {
        self.amount = amount
    }
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(sharedModelContainer)
        guard let configuration = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
            return .result()
        }
        configuration.bpm -= Double(amount)
        try modelContext.save()
        await Metronome.shared.setConfiguration(configuration: configuration)
        WidgetCenter.shared.reloadAllTimelines()
        if configuration.playing {
            Task {
                await Metronome.shared.play()
            }
        }
        return .result()
    }

}


struct MetronomeProvider: TimelineProvider {
    typealias Entry = MetronomeEntry
    
    func placeholder(in context: Context) -> MetronomeEntry {
        MetronomeEntry(date: Date(), playing: false, bpm: 120)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MetronomeEntry) -> ()) {
        Task { @MainActor in
            let now = Date.now
            
            let modelContext = ModelContext(sharedModelContainer)
            guard let configuration = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
                let entry = MetronomeEntry(date: now, playing: false, bpm: -1)
                completion(entry)
                return
            }
            Metronome.shared.setConfiguration(configuration: configuration)
            let entry = MetronomeEntry(date: now, playing: Metronome.shared.playing, bpm: Metronome.shared.bpm)
            completion(entry)
        }
    }

    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MetronomeEntry>) -> Void) {
        Task { @MainActor in
            let now = Date.now
            
            let modelContext = ModelContext(sharedModelContainer)
            guard let configuration = try modelContext.fetch(FetchDescriptor<Configuration>()).first else {
                let entry = MetronomeEntry(date: now, playing: false, bpm: -1)
                let timeline = Timeline(entries: [entry], policy: .never)
                completion(timeline)
                return
            }
            Metronome.shared.setConfiguration(configuration: configuration)
            let entry = MetronomeEntry(date: now, playing: Metronome.shared.playing, bpm: Metronome.shared.bpm)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct MetronomeWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily;
    var entry: MetronomeProvider.Entry
    
    var body: some View {
        VStack {
            HStack {
                if (widgetFamily == .systemMedium) {
                    Button(intent: DecrementBPM(amount: 10)) {
                        Label("Decrement 10", systemImage: "backward.fill").labelStyle(.iconOnly)
                    }
                }
                Button(intent: DecrementBPM(amount: 1)) {
                    Label("Decrement", systemImage: "minus.square.fill").labelStyle(.iconOnly)
                }
                Text("\(Int(entry.bpm))")
                Button(intent: IncrementBPM(amount: 1)) {
                    Label("Increment", systemImage: "plus.square.fill").labelStyle(.iconOnly)
                }
                if (widgetFamily == .systemMedium) {
                    Button(intent: IncrementBPM(amount: 10)) {
                        Label("Increment 10", systemImage: "forward.fill").labelStyle(.iconOnly)
                    }
                }
            }
            !entry.playing ? Button(intent: PlayMetronome()) {
                Label("Play", systemImage: "play.fill").labelStyle(.iconOnly)
            } : Button(intent: StopMetronome()) {
                Label("Pause", systemImage: "pause.fill").labelStyle(.iconOnly)
            }
        }
    }
}
