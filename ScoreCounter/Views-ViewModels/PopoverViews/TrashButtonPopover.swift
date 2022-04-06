//
//  TrashButtonPopover.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 30/03/2022.
//

import SwiftUI
import AVFoundation

//======================================================================================
struct TrashButtonPopover: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isTrashButtonPopoverShown: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing the game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Finishing the game will result in erasing all the scores (both the points and the sets).\n\nYou cannot undo this action")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: eraseAllScoresAndSets) {
                Text("CONFIRM")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color("WhiteBlack"))
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(.red).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 340)
    }
    
    private func eraseAllScoresAndSets() {
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        if coreDataOperations.eraseEverything() {
            if appProperties.isSpeakerON {
                let systemSoundID: SystemSoundID = 1024
                AudioServicesPlaySystemSound(systemSoundID)
            }
            
            appProperties.currentSet = 1 //reset to the first set
            appProperties.setSelectedAtTabView = 1
            appProperties.isTeamAonTheLeft = true
            isTrashButtonPopoverShown = false
            
            appProperties.gainedSetsOfTeamA = 0
            appProperties.gainedSetsOfTeamB = 0
        }
    }
}
