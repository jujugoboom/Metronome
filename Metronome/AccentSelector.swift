//
//  AccentSelector.swift
//  Metronome
//
//  Created by Justin Covell on 9/21/24.
//
import SwiftUI

public typealias AccentSelection = Int

extension AccentSelection {
    static let disabled = 0
    static let tick = 1
    static let accent = 2
    
    static func nextSelection(currentSelection: AccentSelection) -> AccentSelection {
        return (currentSelection + 1) % 3
    }
}

struct AccentSelector: View {
    var accents: [AccentSelection]
    var toggleAccent: (Int) -> Void
    
    
    var body: some View {
        HStack {
            ForEach(Array(accents.enumerated()), id: \.offset) {index, accented in
                Button(action: {doToggle(index: index)}) {
                    Label("Accent", systemImage: getImage(selection: accented)).labelStyle(.iconOnly)
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        }.padding()
    }
    
    func getImage(selection: AccentSelection) -> String {
        switch selection {
            case .disabled:
                return "circle"
            case .tick:
                return "circle.fill"
            case .accent:
                return "plus.circle.fill"
            default:
                return ""
        }
        
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
