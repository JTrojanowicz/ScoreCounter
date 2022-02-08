//
//  Toolbar.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct Toolbar<PreviousSetView: View, UndoButtonView: View, NewSetView: View, TrashButtonView: View>: ToolbarContent {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var appProperties: AppProperties
    
    @ViewBuilder var previousSetView: PreviousSetView
    @ViewBuilder var undoButtonView: UndoButtonView
    @ViewBuilder var newSetView: NewSetView
    @ViewBuilder var trashButtonView: TrashButtonView
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                undoButtonView
                newSetView
            }
        }
        
        ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
                Text("Score Counter")
                    .font(.custom("Noteworthy-Bold", size: 22))
                Text("ver. \(appVersion)")
                    .font(.system(size: 10, weight: .medium, design:.default))
                
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                trashButtonView
                Button(action: toggleSpeaker) {
                    if appProperties.isSpeakerON {
                        Image(systemName: "speaker.wave.3.fill")
                    } else {
                        Image(systemName: "speaker.slash.fill")
                    }
                }
            }
        }
    }
    
    private func toggleSpeaker() {
        appProperties.isSpeakerON.toggle()
    }
}

