//
//  AccentSelector.swift
//  Metronome
//
//  Created by Justin Covell on 9/21/24.
//
import SwiftUI

struct AccentSelector: View {
    var accents: [Bool]
    var toggleAccent: (Int) -> Void
    
    
    var body: some View {
        HStack {
            ForEach(Array(accents.enumerated()), id: \.offset) {index, accented in
                Button(action: {doToggle(index: index)}) {
                    Label("Accent", systemImage: accented ? "circle.fill" : "circle").labelStyle(.iconOnly)
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        }.padding()
    }
    
    func doToggle(index: Int) {
        toggleAccent(index)
        if Metronome.shared.playing {
            Task {
                await Metronome.shared.play()
            }
        }
    }
}
