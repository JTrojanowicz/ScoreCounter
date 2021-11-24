//
//  ScoreHistoryList.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import AVFoundation

struct ScoreHistoryList: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timeStamp, order: .reverse)]) var gainedPoints: FetchedResults<OneGainedPoint>
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let header = Text("SCORE HISTORY")
    let footer = Text("To remove individual score swipe the row to the left")
                                        
    var body: some View {
        List {
            Section(header: header, footer: footer) {
                ForEach(gainedPoints, id: \.self) { oneGainedPoint in
                    ScoreHistoryRow(pointForTheRow: oneGainedPoint)
                }
                .onDelete(perform: onDelete_OneHistoryScore)
            }
        }
    }
    
    private func onDelete_OneHistoryScore(indexSet: IndexSet) {
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)] //when this sorting is applied then indexSet number is the same as the index number of the fetched array of items from CoreData
        
        do {
            let fetchedItems = try managedObjectContext.fetch(fetchRequest) // Execute Fetch Request
            
            for (index, fetchedItem) in fetchedItems.enumerated() {
                if let indexToRemove = indexSet.first /*there will be only one item to delete*/, index == indexToRemove {
                    managedObjectContext.delete(fetchedItem)
                    break //no need to continue the loop
                }
            }
            
            PersistenceController.shared.save()
            
            let systemSoundID: SystemSoundID = 1034
            AudioServicesPlaySystemSound(systemSoundID)
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

struct ScoreHistoryList_Previews: PreviewProvider {
    static var previews: some View {
        ScoreHistoryList()
    }
}
