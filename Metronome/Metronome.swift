//
//  Metronome.swift
//  Metronome
//
//  Created by Justin Covell on 9/20/24.
//
import SwiftData
import SwiftUI
import AVFoundation
import AppIntents

class Metronome: ObservableObject {
    @MainActor
    static let shared = Metronome(configuration: Configuration(bpm: 0, quarterVolume: 0, eighthVolume: 0, tripletVolume: 0, playing: false))
    
    var configuration: Configuration
    
    var player: AVAudioPlayer?
    
    var playing: Bool {
        configuration.playing
    }
    var bpm: Double {
        configuration.bpm
    }
   var quarterVolume: Double {
        configuration.quarterVolume
    }
    var eighthVolume: Double {
        configuration.eighthVolume
    }
    var tripletVolume: Double {
        configuration.tripletVolume
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func stop() {
        player?.stop()
    }
            
    func play() async {
        if let currPlayer = player {
            currPlayer.stop()
        }
        let quarterTime = 60 / bpm
        let tripletTime = quarterTime * 0.33
        let eighthTime = quarterTime / 2
        
        let composition = AVMutableComposition()
        
        var accentTrack: AVAssetTrack
        var tickTrack: AVAssetTrack
        do {
            let accent = AVURLAsset(url: Bundle.main.url(forResource: "metaccentlong", withExtension: ".wav")!)
            accentTrack = try await accent.load(.tracks)[0]
            let tick = AVURLAsset(url: Bundle.main.url(forResource: "metreglong", withExtension: ".wav")!)
            tickTrack = try await tick.load(.tracks)[0]
            
            var mixParams: [AVMutableAudioMixInputParameters] = []
        
        
            if quarterVolume > 0 {
                let quarterTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
                let fullQuarterCMTime = CMTimeMakeWithSeconds(quarterTime, preferredTimescale: 600)
                for i in 0..<4 {
                    let quarterCMTime = CMTimeMakeWithSeconds(Double(i) * quarterTime, preferredTimescale: 600)
                    let quarterTimeRange = CMTimeRange(start: CMTime.zero, duration: fullQuarterCMTime)
                    try quarterTrack?.insertTimeRange(quarterTimeRange, of: configuration.quarterAccents[i] ? accentTrack : tickTrack, at: quarterCMTime)
                }
                
                let quarterAccentParams = AVMutableAudioMixInputParameters(track: accentTrack)
                quarterAccentParams.trackID = quarterTrack!.trackID
                quarterAccentParams.setVolume(Float(quarterVolume) / 100, at: CMTime.zero)
                let quarterTickParams = AVMutableAudioMixInputParameters(track: tickTrack)
                quarterTickParams.trackID = quarterTrack!.trackID
                quarterTickParams.setVolume(Float(quarterVolume) / 100, at: CMTime.zero)
                mixParams.append(quarterAccentParams)
                mixParams.append(quarterTickParams)
            }
                
            if eighthVolume > 0 {
                let eighthTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
                let fullEighthCMTime = CMTimeMakeWithSeconds(eighthTime, preferredTimescale: 600)
                for i in 0..<8 {
                    let eighthTimeRange = CMTimeRange(start: CMTime.zero, duration: fullEighthCMTime)
                    try eighthTrack?.insertTimeRange(eighthTimeRange, of: configuration.eighthAccents[i] ? accentTrack : tickTrack, at: CMTimeMakeWithSeconds(Double(i) * eighthTime, preferredTimescale: eighthTrack?.naturalTimeScale ?? 600))
                }
                
                let eighthTickParams = AVMutableAudioMixInputParameters(track: tickTrack)
                eighthTickParams.trackID = eighthTrack!.trackID
                eighthTickParams.setVolume(Float(eighthVolume) / 100, at: CMTime.zero)
                let eighthAccentParams = AVMutableAudioMixInputParameters(track: accentTrack)
                eighthAccentParams.trackID = eighthTrack!.trackID
                eighthAccentParams.setVolume(Float(eighthVolume) / 100, at: CMTime.zero)
                mixParams.append(eighthTickParams)
                mixParams.append(eighthAccentParams)
            }
                
            if tripletVolume > 0 {
                let tripletTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
                let fullTripletCMTime = CMTimeMakeWithSeconds(tripletTime, preferredTimescale: 600)
                for i in 0..<12 {
                    let tripletTimeRange = CMTimeRange(start: CMTime.zero, duration: fullTripletCMTime)
                    try tripletTrack?.insertTimeRange(tripletTimeRange, of: configuration.tripletAccents[i] ? accentTrack : tickTrack, at: CMTimeMakeWithSeconds(Double(i) * tripletTime, preferredTimescale:  tripletTrack?.naturalTimeScale ?? 600))
                }
                tripletTrack?.preferredVolume = Float(tripletVolume / 100)
                
                let tripletTickParams = AVMutableAudioMixInputParameters(track: tickTrack)
                tripletTickParams.trackID = tripletTrack!.trackID
                tripletTickParams.setVolume(Float(tripletVolume) / 100, at: CMTime.zero)
                let tripletAccentParams = AVMutableAudioMixInputParameters(track: tickTrack)
                tripletAccentParams.trackID = tripletTrack!.trackID
                tripletAccentParams.setVolume(Float(tripletVolume) / 100, at: CMTime.zero)

                mixParams.append(tripletTickParams)
                mixParams.append(tripletAccentParams)
            }
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = mixParams
            
            let documentDirectoryURL = NSTemporaryDirectory()
            let mergeAudioURL = NSURL.fileURL(withPathComponents: [documentDirectoryURL, NSUUID().uuidString])!

            let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
            assetExport?.audioMix = audioMix
            if #available(iOS 18, *) {
                try await assetExport?.export(to: mergeAudioURL as URL, as: AVFileType.m4a)
            } else {
                // Fallback on earlier versions
                assetExport?.outputFileType = AVFileType.m4a
                assetExport?.outputURL = mergeAudioURL as URL
                await assetExport?.export()
            }
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: mergeAudioURL as URL)

            player?.numberOfLoops = 1000000
            player?.play()
        } catch {
            print(error)
        }
    }
    
    func setConfiguration(configuration: Configuration) {
        self.configuration = configuration
    }

}
