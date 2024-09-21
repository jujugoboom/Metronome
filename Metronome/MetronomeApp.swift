//
//  MetronomeApp.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//

import SwiftUI
import SwiftData
import AVFoundation

@main
struct MetronomeApp: App {
    
    static var appModelContainer: ModelContainer = {
        do {
            if try sharedModelContainer.mainContext.fetch<Configuration>(FetchDescriptor<Configuration>()).isEmpty {
                let config = Configuration(bpm: 120, quarterVolume: 100, eighthVolume: 0, tripletVolume: 0, playing: false)
                sharedModelContainer.mainContext.insert(config)
                try sharedModelContainer.mainContext.save()
            }
            return sharedModelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    static var metronome: Metronome {
        do {
            guard let configuration = try MetronomeApp.appModelContainer.mainContext.fetch(FetchDescriptor<Configuration>()).first else {
                return Metronome.shared
            }
            Metronome.shared.setConfiguration(configuration: configuration)
            return Metronome.shared
        } catch {
            return Metronome.shared
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(metronome: MetronomeApp.metronome)
        }
        .modelContainer(MetronomeApp.appModelContainer)
    }
}
