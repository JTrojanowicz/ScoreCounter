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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var historyHeightRatio = 0.5
    @State private var isResetDialogShown = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 0) {
                    CurrentScoreAndButtons()
                        .frame(width: geo.size.width, height: geo.size.height*(1-historyHeightRatio), alignment: .center)
                    ScoreHistoryList()
                        .frame(width: geo.size.width,
                               height: geo.size.height*historyHeightRatio,
                               alignment: .center)
                        .background(Color.red)
                }
            }
            .toolbar {
                Toolbar() {
                    Button(action: resetWasTapped) {
                        Text("Reset")
                            .actionSheet(isPresented: $isResetDialogShown) {
                                ActionSheet(
                                    title: Text("Reset the score"),
                                    message: Text("Reseting will remove whole history of the scores"),
                                    buttons: [
                                        .destructive(Text("Confirm"), action: resetScore),
                                        .cancel()
                                    ])
                            }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func resetWasTapped() {
        isResetDialogShown = true
    }
    
    private func resetScore() {
        print("Reseting score!")

        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        do {
            // Execute Fetch Request
            let fetchedItems = try managedObjectContext.fetch(fetchRequest)
            
            for fetchedItem in fetchedItems {
                managedObjectContext.delete(fetchedItem)
            }
            
            PersistenceController.shared.save()
            
            let systemSoundID: SystemSoundID = 1024
            AudioServicesPlaySystemSound(systemSoundID)
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: Unable to Execute Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

