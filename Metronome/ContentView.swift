//
//  ContentView.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//

import SwiftUI
import SwiftData
import AVFoundation
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) var scenePhase
    @Query private var configurations: [Configuration]
    private var configuration: Configuration {
        configurations.first ?? Configuration(bpm: 0, quarterVolume: 0, eighthVolume: 0, tripletVolume: 0, playing: false)
    }
    private var bindableConfiguration: Bindable<Configuration> {
        Bindable(configuration)
    }
    private var bpm: Double {
        configuration.bpm
    }
    private var quarterVolume: Double {
        configuration.quarterVolume
    }
    private var eighthVolume: Double {
        configuration.eighthVolume
    }
    private var tripletVolume: Double {
        configuration.tripletVolume
    }
    private var quarterAccents: [Bool] {
        configuration.quarterAccents
    }
    private var eighthAccents: [Bool] {
        configuration.eighthAccents
    }
    private var tripletAccents: [Bool] {
        configuration.tripletAccents
    }
    private var bindingBpm: Binding<Double> {
        bindableConfiguration.bpm
    }
    private var bindingQuarterVolume: Binding<Double> {
        bindableConfiguration.quarterVolume
    }
    private var bindingEighthVolume: Binding<Double> {
        bindableConfiguration.eighthVolume
    }
    private var bindingTripletVolume: Binding<Double> {
        bindableConfiguration.tripletVolume
    }
    @StateObject var metronome: Metronome
    
    @State private var editing = false {
        didSet {
            if !editing && metronome.playing {
                Task {
                    await metronome.play()
                }
            }
        }
    }

    var body: some View {
        VStack{
            HStack{
                Text("BPM")
                Slider(value: bindingBpm, in: 60...220, onEditingChanged: sliderEditing)
                Text("\(Int(bpm))")
            }.padding()
            HStack{
                Text("1/4")
                Slider(value: bindingQuarterVolume, in: 0...100, onEditingChanged: sliderEditing)
                Text("\(Int(quarterVolume))")
            }.padding()
            AccentSelector(accents: quarterAccents, toggleAccent: {i in configuration.quarterAccents[i] = !configuration.quarterAccents[i]})
            HStack{
                Text("1/8")
                Slider(value: bindingEighthVolume, in: 0...100, onEditingChanged: sliderEditing)
                Text("\(Int(eighthVolume))")
            }.padding()
            AccentSelector(accents: eighthAccents, toggleAccent: {i in configuration.eighthAccents[i] = !configuration.eighthAccents[i]})
            HStack {
                Text("1/3")
                Slider(value: bindingTripletVolume, in: 0...100, onEditingChanged: sliderEditing)
                Text("\(Int(tripletVolume))")
            }.padding()
            AccentSelector(accents: tripletAccents, toggleAccent: {i in configuration.tripletAccents[i] = !configuration.tripletAccents[i]})
            Button(action: {Task {!metronome.playing ? await play() : stop()}}) {
                !metronome.playing ? Label("Play", systemImage: "play.fill") : Label("Pause", systemImage: "pause.fill")
            }.padding()
        }.onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .inactive || newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            } else if newPhase == .active {
                Metronome.shared.setConfiguration(configuration: configuration)
            }
        }
    }
        
    private func sliderEditing(editing: Bool) {
        self.editing = editing
    }
    
    @MainActor
    private func play() async {
        await metronome.play()
        configuration.playing = true
    }
    
    private func stop() {
        metronome.stop()
        configuration.playing = false
    }
}

#Preview {
    ContentView(metronome: Metronome(configuration: Configuration(bpm: 120, quarterVolume: 100, eighthVolume: 0, tripletVolume: 0, playing: false)))
        .modelContainer(for: Configuration.self, inMemory: true)
}
