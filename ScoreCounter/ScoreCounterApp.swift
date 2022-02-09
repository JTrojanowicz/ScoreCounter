//
//  ScoreCounterApp.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

@main
struct ScoreCounterApp: App {
    
    @StateObject var appProperties = AppProperties()
    
    let context = PersistenceController.shared.moc
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(appProperties)
        }
    }
}

class AppProperties: ObservableObject {
    
    @AppStorage("nameOfTeamA") var nameOfTeamA = "Octopuses 🐙" /*defaul value if the key does not exist in UserDefaults - BUT: THIS WILL NOT INITIALISE USERDEFAULTS and will not set it - you need to do it explicitly*/ {
        willSet { objectWillChange.send() } // see: https://developer.apple.com/forums/thread/652384
    }
    @AppStorage("nameOfTeamB")  var nameOfTeamB = "Lions 🦁" {
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
}
