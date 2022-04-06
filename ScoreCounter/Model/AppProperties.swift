//
//  AppProperties.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 30/03/2022.
//

import SwiftUI
import CoreData

class AppProperties: ObservableObject {
    
    @AppStorage("nameOfTeamA") var nameOfTeamA = "🐙 Octopuses 🐙" /*defaul value if the key does not exist in UserDefaults - BUT: THIS WILL NOT INITIALISE USERDEFAULTS and will not set it - you need to do it explicitly*/ {
        willSet { objectWillChange.send() } // see: https://developer.apple.com/forums/thread/652384
    }
    @AppStorage("nameOfTeamB")  var nameOfTeamB = "🦁 Lions 🦁" {
        willSet { objectWillChange.send() }
    }
    @AppStorage("gainedSetsOfTeamA")  var gainedSetsOfTeamA = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("gainedSetsOfTeamB")  var gainedSetsOfTeamB = 0 {
        willSet { objectWillChange.send() }
    }
    
    @Published var isSpeakerON = false
    @Published var isTeamAonTheLeft = true
    @Published var currentSet = 1
    @Published var setSelectedAtTabView = 1
    
    var teamNameLeft: String { return isTeamAonTheLeft ? nameOfTeamA : nameOfTeamB }
    var teamNameRight: String { return isTeamAonTheLeft ? nameOfTeamB : nameOfTeamA }
    
    func swapTheCourts() {
        isTeamAonTheLeft.toggle()
    }
    
    func goToPreviousSet(with moc: NSManagedObjectContext) {
        guard currentSet > 1 else { return } //do not go below 1
        
        currentSet -= 1
        setSelectedAtTabView -= 1 //initially select the new tab (later the user can change it)
        swapTheCourts()
        
        try? calculateGainedSets(with: moc) // this should always work because it is going back in the sets
    }
    
    func calculateGainedSets(with moc: NSManagedObjectContext) throws {
        
        let coreDataOperations = CoreDataOperations(moc: moc)
        var gainedSetsOfTeamA = 0
        var gainedSetsOfTeamB = 0
        
        for setNumber in 1...currentSet {
            let score = coreDataOperations.getScore(of: setNumber, with: Date.now /* making it "now" means that the calculation should be made for all the set */)
            if score.teamA > (score.teamB + 1) {
                gainedSetsOfTeamA += 1
            } else if score.teamB > (score.teamA + 1) {
                gainedSetsOfTeamB += 1
            } else {
                throw "A team can win only with minimum two-point advantage"
            }
        }
        
        self.gainedSetsOfTeamA = gainedSetsOfTeamA
        self.gainedSetsOfTeamB = gainedSetsOfTeamB
    }
}
