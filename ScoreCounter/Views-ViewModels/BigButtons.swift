//
//  BigButton.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 26/11/2021.
//

import SwiftUI
import CoreData
import AVFoundation

enum Team {
    case teamA, teamB
}

struct BigButtons: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private var teamOnTheLeft: Team { appProperties.isTeamAonTheLeft ? .teamA : .teamB }
    private var teamOnTheRight: Team { appProperties.isTeamAonTheLeft ? .teamB : .teamA }
    private var sideLength: CGFloat { sizeClass == .regular ? 150 : 100 }
    
    var body: some View {
        HStack {
            Spacer()
            BigButton(side: teamOnTheLeft)
                .frame(width: sideLength, height: sideLength)
            Spacer()
            BigButton(side: teamOnTheRight)
                .frame(width: sideLength, height: sideLength)
            Spacer()
        }
    }
}

struct BigButton: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appProperties: AppProperties
    
    let side: Team
    
    var body: some View {
        Button(action: scoreIcrement) {
            Image(systemName: "plus.app.fill")
                .resizable()
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
