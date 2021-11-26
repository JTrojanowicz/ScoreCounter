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
    @Published var isSpeakerON = false
}
