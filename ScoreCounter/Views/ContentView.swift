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
    @EnvironmentObject var appProperties: AppProperties
    
    @State private var isResetDialogShown = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                CurrentScore()
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    BigButton(side: .teamA)
                    Spacer()
                    BigButton(side: .teamB)
                    Spacer()
                }
                Spacer()
                ScoreHistoryList()
            }
            .toolbar {
                Toolbar(appProperties: appProperties) {
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
            
            if appProperties.isSpeakerON {
                let systemSoundID: SystemSoundID = 1024
                AudioServicesPlaySystemSound(systemSoundID)
            }
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: Unable to Execute Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

