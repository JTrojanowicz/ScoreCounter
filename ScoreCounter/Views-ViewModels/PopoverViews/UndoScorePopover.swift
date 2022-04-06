//
//  UndoScorePopover.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 30/03/2022.
//

import SwiftUI
import AVFoundation

//======================================================================================
struct UndoScorePopover: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isUndoButtonPopoverShown: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("It will undo the last gained point")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Button(action: undoLastScore) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.red)
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 340)
    }
    
    private func undoLastScore() {
        
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        if coreDataOperations.removeLastScore(of: appProperties.currentSet) {
            if appProperties.isSpeakerON {
                let systemSoundID: SystemSoundID = 1034
                AudioServicesPlaySystemSound(systemSoundID)
            }
            
            isUndoButtonPopoverShown = false
        }
    }
}
