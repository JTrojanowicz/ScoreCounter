//
//  BigButton.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 26/11/2021.
//

import SwiftUI
import CoreData
import AVFoundation

enum ButtonSide {
    case teamA, teamB
}

struct BigButton: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var appProperties: AppProperties
    
    var buttonSize: CGFloat {
        return horizontalSizeClass == .compact ? 120 : 170
    }
    
    var side: ButtonSide
    var body: some View {
        Button(action: scoreIcrement) {
            Image(systemName: "plus.app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: buttonSize, height: buttonSize)
        }
    }
    
    private func scoreIcrement() {
        
        managedObjectContext.performAndWait {
            let onePoint = OneGainedPoint(context: managedObjectContext)
            
            onePoint.timeStamp = Date()
            onePoint.setNumber = Int16(appProperties.currentSet)
            
            switch(side) {
            case .teamA:
                onePoint.isIcrementingTeamA = true

                if appProperties.isSpeakerON {
                    let systemSoundID: SystemSoundID = 1010
                    AudioServicesPlaySystemSound(systemSoundID)
                }
                
                print("isIcrementingTeamA")
                
            case .teamB:
                onePoint.isIcrementingTeamB = true

                if appProperties.isSpeakerON {
                    let systemSoundID: SystemSoundID = 1021
                    AudioServicesPlaySystemSound(systemSoundID)
                }
                
                print("isIcrementingTeamB")
            }
            
            PersistenceController.shared.save()
        }
        
        appProperties.setSelectedAtTabView = appProperties.currentSet //make sure the user observes the history of the current set
    }
}
