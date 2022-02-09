//
//  ContentView.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import Foundation
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var isNewSetButtonPopoverShown = false
    @State private var isUndoButtonPopoverShown = false
    @State private var isTrashButtonPopoverShown = false
    
    @State private var isGoToPreviousSetButtonShown = false
    @State private var isUndoLastScoreButtonShown = false
    @State private var isNewSetButtonShown = false
    @State private var isTrashButtonShown = false
    @State private var isAlertShown = false
    @State private var alertMessage = ""
    
    private var teamOnTheLeft: Team { appProperties.isTeamAonTheLeft ? .teamA : .teamB }
    private var teamOnTheRight: Team { appProperties.isTeamAonTheLeft ? .teamB : .teamA }
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {
                    VStack(spacing: 0) {
                        Spacer()
                        VStack {
                            Text("Set no.")
                                .font(.system(size: 20, weight: .bold , design: .rounded))
                                .foregroundColor(.gray)
                            Text("\(appProperties.currentSet)")
                                .font(.system(size: 26, weight: .heavy , design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        CurrentScore()
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                            BigButton(side: teamOnTheLeft)
                            Spacer()
                            BigButton(side: teamOnTheRight)
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("WhiteBlack")).shadow(radius: 8))
                    .frame(height: geo.size.height*3/5)
                    .padding()
                    
                    Spacer()
                    HistoryOfSets()
                        .padding()
                }
                .toolbar {
                    Toolbar(appProperties: appProperties,
                            previousSetView: {
                                if isGoToPreviousSetButtonShown {
                                    Button(action: goToPreviousSet) {
                                        Image(systemName: "chevron.backward.square")
                                    }
                                }
                            },
                            undoButtonView: {
                                if isUndoLastScoreButtonShown {
                                    Button(action: { isUndoButtonPopoverShown = true }) {
                                        Image(systemName: "arrow.uturn.backward.square")
                                            .popover(isPresented: $isUndoButtonPopoverShown) {
                                                UndoScorePopover(confirmAction: undoLastScore)
                                            }
                                    }
                                }
                            },
                            newSetView: {
                                if isNewSetButtonShown {
                                    Button(action: { isNewSetButtonPopoverShown = true }) {
                                        Text("New set")
                                            .popover(isPresented: $isNewSetButtonPopoverShown) {
                                                NewSetPopover(confirmAction: createNewSet)
                                            }
                                    }
                                }
                            },
                            trashButtonView: {
                                if isTrashButtonShown {
                                    Button(action: { isTrashButtonPopoverShown = true }) {
                                        Image(systemName: "trash")
                                            .popover(isPresented: $isTrashButtonPopoverShown) {
                                                TrashButtonPopover(confirmAction: eraseAllScoresAndSets)
                                            }
                                    }
                                }
                    })
                }
                .navigationBarTitleDisplayMode(.inline)
                .alert(isPresented: $isAlertShown, content: alertContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear(perform: showOrRemoveToolbarButtons)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave)) { _ in showOrRemoveToolbarButtons()  }
            .onChange(of: appProperties.currentSet) { _ in showOrRemoveToolbarButtons() }
        }
    }
    
    private func goToPreviousSet() {
        guard appProperties.currentSet > 1 else { return } //do not go below 1
        
        appProperties.currentSet -= 1
        appProperties.isTeamAonTheLeft.toggle() //swap the courts
        appProperties.setSelectedAtTabView = appProperties.currentSet //initially select the new tab (later the user can change it)
        
        try? calculateGainedSets() // this should always work because it is going back in the sets
    }
    
    private func createNewSet() {
        guard appProperties.currentSet < 5 else { return } //there can be no more than 5 sets
        
        do {
            appProperties.currentSet += 1 //increment the current set number
            
            try calculateGainedSets()
            
            appProperties.isTeamAonTheLeft.toggle() //swap the courts
            appProperties.setSelectedAtTabView = appProperties.currentSet //initially select the new tab (later the user can change it)
            
        } catch {
            appProperties.currentSet -= 1 //go to the previous set number
            if let error = error as? String {
                alertMessage = error
                isAlertShown = true
            }
        }
        
        isNewSetButtonPopoverShown = false
    }
    
    private func calculateGainedSets() throws {
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        var gainedSetsOfTeamA = 0
        var gainedSetsOfTeamB = 0
        
        for setNumber in 1..<appProperties.currentSet {
            let score = coreDataOperations.getScore(of: setNumber, with: Date() /* making it "now" means that the calculation should be made for all the set */)
            if score.teamA > (score.teamB + 1) {
                gainedSetsOfTeamA += 1
            } else if score.teamB > (score.teamA + 1) {
                gainedSetsOfTeamB += 1
            } else {
                throw "A team can win only with minimum two-point advantage"
            }
        }
        
        appProperties.gainedSetsOfTeamA = gainedSetsOfTeamA
        appProperties.gainedSetsOfTeamB = gainedSetsOfTeamB
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
    
    private func eraseAllScoresAndSets() {
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        if coreDataOperations.eraseEverything() {
            if appProperties.isSpeakerON {
                let systemSoundID: SystemSoundID = 1024
                AudioServicesPlaySystemSound(systemSoundID)
            }
            
            appProperties.currentSet = 1 //reset to the first set
            appProperties.setSelectedAtTabView = 1
            isTrashButtonPopoverShown = false
            
            try? calculateGainedSets() // this should always work
        }
    }
    
    private func showOrRemoveToolbarButtons() {
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        let fetchedPoints = coreDataOperations.fetchGainedPoints(of: appProperties.currentSet)
        
        // isGoToPreviousSetButtonShown
        if appProperties.currentSet == 1 {
            isGoToPreviousSetButtonShown = false
        } else if appProperties.currentSet > 1 {
            isGoToPreviousSetButtonShown = fetchedPoints.count == 0 ? true : false
        }
        
        // isUndoLastScoreButtonShown
        isUndoLastScoreButtonShown = fetchedPoints.count > 0 ? true : false
        
        // isNewSetButtonShown
        if appProperties.currentSet < 5 {
            
            let score = coreDataOperations.getScore(of: appProperties.currentSet, with: Date())
            if score.teamA >= 15 || score.teamB >= 15 {
                isNewSetButtonShown = true
            } else {
                isNewSetButtonShown = false
            }
            
        } else {
            isNewSetButtonShown = false
        }
        
        // isTrashButtonShown
        let fetchedPointsOfAllSets = coreDataOperations.fetchGainedPointsOfAllSets()
        isTrashButtonShown = fetchedPointsOfAllSets.count > 0 ? true : false
    }
    
    private func alertContent() -> Alert {
        Alert(
            title: Text(alertMessage),
            dismissButton: Alert.Button.default(Text("Continue playing"))
        )
    }
}

//======================================================================================
struct NewSetPopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing this set and starting a new one within the same game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Moving to a new set will result in gaining a set for one of the teams and also swapping the playing courts")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: confirmAction) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.red)
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(Color("WhiteBlack")).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 300)
    }
}

//======================================================================================
struct UndoScorePopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("It will undo the last gained point")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Button(action: confirmAction) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.red)
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(Color("WhiteBlack")).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 300)
    }
}
//======================================================================================
struct TrashButtonPopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing the game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Finishing the game will result in erasing all the scores (both the points and the sets).\n\nYou cannot undo this action")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: confirmAction) {
                Text("CONFIRM")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color("WhiteBlack"))
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(.red).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 300)
    }
}

