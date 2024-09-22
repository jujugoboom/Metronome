//
//  Configuration.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//
import SwiftData
import AVFoundation

@Model
final class Configuration {
    var bpm: Double
    var quarterVolume: Double
    var eighthVolume: Double
    var tripletVolume: Double
    var quarterAccents: [AccentSelection] = [AccentSelection](repeating: 2, count: 4)
    var eighthAccents: [AccentSelection] = [AccentSelection](repeating: 1, count: 8)
    var tripletAccents: [AccentSelection] = [AccentSelection](repeating: 1, count: 12)
    var playing: Bool = false
    
    init(bpm: Double, quarterVolume: Double, eighthVolume: Double, tripletVolume: Double, playing: Bool) {
        self.bpm = bpm
        self.quarterVolume = quarterVolume
        self.eighthVolume = eighthVolume
        self.tripletVolume = tripletVolume
        self.playing = playing
    }
}
