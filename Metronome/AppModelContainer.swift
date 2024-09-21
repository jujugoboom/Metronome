//
//  ModelContainer.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//
import SwiftData
import Foundation

var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        Configuration.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
