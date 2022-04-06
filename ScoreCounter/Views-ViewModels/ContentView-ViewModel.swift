//
//  ContentView-ViewModel.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 30/03/2022.
//

import SwiftUI
import CoreData

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        
        @Published var isNewSetButtonPopoverShown = false
        @Published var isUndoButtonPopoverShown = false
        @Published var isTrashButtonPopoverShown = false
        @Published var isMorePopoverShown = false
        
        @Published private(set) var isGoToPreviousSetButtonShown = false
        @Published private(set) var isUndoLastScoreButtonShown = false
        @Published private(set) var isNewSetButtonShown = false
        @Published private(set) var isTrashButtonShown = false
        
        var appVersion: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
        
        func showOrRemoveToolbarButtons(with currentSet: Int, and moc: NSManagedObjectContext) {
            
            let coreDataOperations = CoreDataOperations(moc: moc)
            let fetchedPoints = coreDataOperations.fetchGainedPoints(of: currentSet)
            
            // isGoToPreviousSetButtonShown
            if currentSet == 1 {
                isGoToPreviousSetButtonShown = false
            } else if currentSet > 1 {
                isGoToPreviousSetButtonShown = fetchedPoints.count == 0 ? true : false
            }
            
            // isUndoLastScoreButtonShown
            isUndoLastScoreButtonShown = fetchedPoints.count > 0 ? true : false
            
            // isNewSetButtonShown
            let score = coreDataOperations.getScore(of: currentSet, with: Date())
            if score.teamA >= 15 || score.teamB >= 15 {
                isNewSetButtonShown = true
            } else {
                isNewSetButtonShown = false
            }
            
            // isTrashButtonShown
            let fetchedPointsOfAllSets = coreDataOperations.fetchGainedPointsOfAllSets()
            isTrashButtonShown = fetchedPointsOfAllSets.count > 0 ? true : false
        }
        
    }
}
