//
//  Toolbar.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct Toolbar<ResetButtonView: View>: ToolbarContent {
    
    @ObservedObject var appProperties: AppProperties
    @ViewBuilder let resetButtonView: ResetButtonView
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            resetButtonView
        }
        
        ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
                Text("Score Counter")
                    .font(.custom("Noteworthy-Bold", size: 30))
                Text("ver. \(appVersion)")
                    .font(.system(size: 10, weight: .medium, design:.default))
                
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: toggleSpeaker) {
                if appProperties.isSpeakerON {
                    Image(systemName: "speaker.wave.3.fill")
                } else {
                    Image(systemName: "speaker.slash.fill")
                }
            }
        }
    }
    
    private func toggleSpeaker() {
        appProperties.isSpeakerON.toggle()
    }
}

