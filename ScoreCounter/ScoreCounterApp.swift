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
    
    let context = PersistenceController.shared.moc
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
        }
    }
}
