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
    
    @StateObject var appInfo = AppInfo()
    
    let context = PersistenceController.shared.moc
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(appInfo)
                .onAppear(perform: onAppear)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave), perform: onReceive_MOCContextDidSave) 
        }
    }
    
    private func onAppear() {
        getCurrentScores()
    }
    
    private func onReceive_MOCContextDidSave(notification: Notification) {
        getCurrentScores()
    }
    
    private func getCurrentScores() {
        
        var scoreOfTeamA: Int = 0
        var scoreOfTeamB: Int = 0
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
            do {
                // Execute Fetch Request
                let fetchedGainedPoints = try context.fetch(fetchRequest)
                
                for gainedPoint in fetchedGainedPoints {
                    if gainedPoint.isIcrementingTeamA {
                        scoreOfTeamA += 1
                    }
                    
                    if gainedPoint.isIcrementingTeamB {
                        scoreOfTeamB += 1
                    }
                }
                
            } catch {
                let fetchError = error as NSError
                print("⛔️ Error: Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        print("A: \(scoreOfTeamA), B: \(scoreOfTeamB)")
        appInfo.currentScoreForTeamA = scoreOfTeamA
        appInfo.currentScoreForTeamB = scoreOfTeamB
    }
}

class AppInfo: ObservableObject {
    @Published var currentScoreForTeamA: Int = 0
    @Published var currentScoreForTeamB: Int = 0
}
