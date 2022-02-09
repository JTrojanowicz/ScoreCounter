//
//  CoreDataOperations.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 09/02/2022.
//

import Foundation
import CoreData

class CoreDataOperations {
    private let moc: NSManagedObjectContext
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    func fetchGainedPointsOfAllSets() -> [OneGainedPoint] {
        return fetchGainedPoints()
    }
    
    func fetchGainedPoints(of setNumber: Int? = nil) -> [OneGainedPoint] {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: true)]
        if let setNumber = setNumber {
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber) //filter out all the scores gained at different sets
        }
        
        do {
            let allGainedPoints = try moc.fetch(fetchRequest) // Execute Fetch Request
            return allGainedPoints
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        
        return []
    }
    
    func getScore(of setNumber: Int16, with timeStampMax: Date?) -> (teamA: Int, teamB: Int) { //method overloading
        return getScore(of: Int(setNumber), with: timeStampMax)
    }
    
    func getScore(of setNumber: Int, with timeStampMax: Date?) -> (teamA: Int, teamB: Int) {
        
        var score: (teamA: Int, teamB: Int) = (0, 0)
        
        let fetchedGainedPoints = fetchGainedPoints(of: setNumber)
        
        for fetchedPoint in fetchedGainedPoints {
            if let timeStampOfFetchedPoint = fetchedPoint.timeStamp, let timeStampMax = timeStampMax {
                if timeStampOfFetchedPoint <= timeStampMax {
                    if fetchedPoint.isIcrementingTeamA {
                        score.teamA += 1
                    }
                    
                    if fetchedPoint.isIcrementingTeamB {
                        score.teamB += 1
                    }
                }
            }
        }
        
        return score
    }
    
    func eraseEverything() -> Bool {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        do {
            // Execute Fetch Request
            let fetchedItems = try moc.fetch(fetchRequest)
            
            for fetchedItem in fetchedItems {
                moc.delete(fetchedItem)
            }
            
            PersistenceController.shared.save()
            
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func removeLastScore(of setNumber: Int) -> Bool {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)] //last item will come first
        fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber) //filter out the items other than for the currentSet
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedItems = try moc.fetch(fetchRequest) // Execute Fetch Request
            
            if let lastItem = fetchedItems.first { //there will only one item or none
                moc.delete(lastItem)
                
                PersistenceController.shared.save()
                
                return true
            }
            
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        return false
    }
}
