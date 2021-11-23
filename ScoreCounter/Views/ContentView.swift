//
//  ContentView.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    @EnvironmentObject var appInfo: AppInfo
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var historyHeightRatio = 0.33
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
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        
    }
    
    private func resetWasTapped() {
        isResetDialogShown = true
    }
    
    private func resetScore() {
        print("Reseting score!")
        managedObjectContext.performAndWait {
            
            //Perform batch delete of all the elements
            
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OneGainedPoint")
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                // Specify the result of the NSBatchDeleteRequest: should be the NSManagedObject IDs for the deleted objects
                batchDeleteRequest.resultType = .resultTypeObjectIDs
                
                let batchDelete =  try managedObjectContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                guard let ids = batchDelete?.result as? [NSManagedObjectID] else {
                    return
                }
                let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: ids]
                // Merge the delete changes into the managed object context
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [managedObjectContext])
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
}

