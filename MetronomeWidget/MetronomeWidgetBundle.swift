//
//  MetronomeWidgetBundle.swift
//  MetronomeWidget
//
//  Created by Justin Covell on 9/20/24.
//

import WidgetKit
import SwiftUI
import SwiftData

@main
struct MetronomeWidgetBundle: WidgetBundle {
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
    
    var body: some Widget {
        MetronomeWidget()
    }
}
