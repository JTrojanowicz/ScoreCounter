//
//  PopoverViews.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 09/02/2022.
//

import SwiftUI
import AVFoundation

//======================================================================================
struct NewSetPopover: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var moc
    @Binding var isNewSetButtonPopoverShown: Bool
    
    @State private var alertMessage: String = ""
    @State private var isAlertShown = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing this set and starting a new one within the same game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Moving to a new set will result in gaining a set for one of the teams and also swapping the playing courts")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: createNewSet) {
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
        .alert(isPresented: $isAlertShown, content: alertContent)
    }
    
    private func createNewSet() {
        do {
            try appProperties.calculateGainedSets(with: moc)
            
            appProperties.currentSet += 1 //increment the current set number
            appProperties.setSelectedAtTabView += 1 //initially select the new tab (later the user can change it)
            appProperties.swapTheCourts()
        }
        catch {
            if let error = error as? String {
                alertMessage = error
                isAlertShown = true
            }
        }
        isNewSetButtonPopoverShown = false
    }
    
    private func alertContent() -> Alert {
        Alert(
            title: Text(alertMessage),
            dismissButton: Alert.Button.default(Text("Continue playing"))
        )
    }
}




