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
    
    private var teamOnTheLeft: ButtonSide { appProperties.isTeamAonTheLeft ? .teamA : .teamB }
    private var teamOnTheRight: ButtonSide { appProperties.isTeamAonTheLeft ? .teamB : .teamA }
    
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
    }
    
    private func createNewSet() {
        guard appProperties.currentSet < 5 else { return } //there can be no more than 5 sets
        
        appProperties.currentSet += 1 //increment the current set number
        appProperties.isTeamAonTheLeft.toggle() //swap the courts
        appProperties.setSelectedAtTabView = appProperties.currentSet //initially select the new tab (later the user can change it)
        
        isNewSetButtonPopoverShown = false
    }
    
    private func undoLastScore() {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)] //last item will come first
        fetchRequest.predicate = NSPredicate(format: "setNumber == %i", appProperties.currentSet) //filter out the items other than for the currentSet
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedItems = try managedObjectContext.fetch(fetchRequest) // Execute Fetch Request
            
            if let lastItem = fetchedItems.first { //there will only one item or none
                managedObjectContext.delete(lastItem)
                
                PersistenceController.shared.save()
                
                if appProperties.isSpeakerON {
                    let systemSoundID: SystemSoundID = 1034
                    AudioServicesPlaySystemSound(systemSoundID)
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        
        isUndoButtonPopoverShown = false
    }
    
    private func eraseAllScoresAndSets() {
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        do {
            // Execute Fetch Request
            let fetchedItems = try managedObjectContext.fetch(fetchRequest)
            
            for fetchedItem in fetchedItems {
                managedObjectContext.delete(fetchedItem)
            }
            
            PersistenceController.shared.save()
            
            if appProperties.isSpeakerON {
                let systemSoundID: SystemSoundID = 1024
                AudioServicesPlaySystemSound(systemSoundID)
            }
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: Unable to Execute Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        appProperties.currentSet = 1 //reset to the first set
        appProperties.setSelectedAtTabView = 1
        isTrashButtonPopoverShown = false
    }
    
    private func showOrRemoveToolbarButtons() {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "setNumber == %i", appProperties.currentSet) //filter out the items other than for the currentSet
        
        do {
            let fetchedItems = try managedObjectContext.fetch(fetchRequest) // Execute Fetch Request
        
            // show or remove appropriate buttons from the toolbar:
            
            // isGoToPreviousSetButtonShown
            if appProperties.currentSet == 1 {
                isGoToPreviousSetButtonShown = false
            } else if appProperties.currentSet > 1 {
                isGoToPreviousSetButtonShown = fetchedItems.count == 0 ? true : false
            }
            
            // isUndoLastScoreButtonShown
            isUndoLastScoreButtonShown = fetchedItems.count > 0 ? true : false
            
            // isNewSetButtonShown
            if appProperties.currentSet < 5 {
                
                var scoreOfTeamA: Int = 0
                var scoreOfTeamB: Int = 0
                
                for gainedPoint in fetchedItems {
                    if gainedPoint.isIcrementingTeamA {
                        scoreOfTeamA += 1
                    }
                    
                    if gainedPoint.isIcrementingTeamB {
                        scoreOfTeamB += 1
                    }
                }
                
                if scoreOfTeamA >= 15 || scoreOfTeamB >= 15 {
                    isNewSetButtonShown = true
                } else {
                    isNewSetButtonShown = false
                }
                
            } else {
                isNewSetButtonShown = false
            }
            
            // isTrashButtonShown
            isTrashButtonShown = fetchedItems.count > 0 ? true : false
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
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
            Text("Moving to a new set will result in gaining a set for one of the teams and also swapping the courts.\nThe history of gained points for the current set will be removed")
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
            Text("It will undo the last score")
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

