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
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var body: some View {
        GeometryReader { geo in // it looks like using GeometryReader also somewhere else (in a nested view) mess up the views... (also it is better to use it on the top of the view)
            NavigationView {
                VStack {
                    ScoresPanel()
                        .frame(height: geo.size.height*3/5)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
                        .padding()
                        
                    HistoryOfSets() //List view behaves like a Spacer() --> it fills possible space in the container (or even with greater force it pushes other view... I don't understand it.., eg. replacing it with Spacer will NOT get the same results - it is stronger.)
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
                                        if geo.size.width > 400 {
                                            Text("New set")
                                                .popover(isPresented: $isNewSetButtonPopoverShown) {
                                                    NewSetPopover(confirmAction: createNewSet)
                                                }
                                        } else { // .compact
                                            VStack(spacing: 0) {
                                                Text("New")
                                                Text("set")
                                            }
                                            .popover(isPresented: $isNewSetButtonPopoverShown) {
                                                NewSetPopover(confirmAction: createNewSet)
                                            }
                                        }
                                    }
                                }
                            },
                            titleView: {
                                VStack(spacing: 0) {
                                    Text("Score Counter")
                                        .font(.custom("Noteworthy-Bold", size: /*geo.size.width > 400 ? 22 :*/ 18))
                                    Text("ver. \(appVersion)")
                                        .font(.system(size: 10, weight: .medium, design:.default))
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
            appProperties.isTeamAonTheLeft = true
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

