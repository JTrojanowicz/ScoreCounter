//
//  ScoreHistoryRow.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 21/11/2021.
//

import SwiftUI
import CoreData

struct ScoreHistoryRow: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var pointForTheRow: OneGainedPoint
    
    @State private var scoreOfTeamA: Int = 0
    @State private var scoreOfTeamB: Int = 0
    
    private var timeStamp: String {
        return pointForTheRow.timeStamp?.toString(dateFormat: "HH:mm:ss") ?? "Unknown"
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                
                if pointForTheRow.isIcrementingTeamA {
                    Image(systemName: "arrowtriangle.up.square")
                } else {
                    Spacer().frame(width: 20)
                }
                
                HStack {
                    Spacer()
                    Text("\(scoreOfTeamA)")
                        .font(.system(size: 30, weight: .bold))
                }
                .frame(width: 50)
                
                Text(":")
                    .font(.system(size: 30, weight: .bold))
                
                HStack {
                    Text("\(scoreOfTeamB)")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                }
                .frame(width: 50)
                
                if pointForTheRow.isIcrementingTeamB {
                    Image(systemName: "arrowtriangle.up.square")
                } else {
                    Spacer().frame(width: 20)
                }
                
                Spacer()
            }
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("\(timeStamp)")
                        .font(.system(size: 12, weight: .thin, design: .monospaced))
                }
            }
        }
        .onAppear(perform: calculateScoreForTheRow)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave)) { _ in
            calculateScoreForTheRow()
        }
    }
    
    private func calculateScoreForTheRow() {
        
        var scoreA = 0
        var scoreB = 0
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: true)]
        do {
            // Execute Fetch Request
            let allGainedPoints = try managedObjectContext.fetch(fetchRequest)
            
            for fetchedPoint in allGainedPoints {
                if let timeStampOfFetchedPoint = fetchedPoint.timeStamp, let timeStampOfPointOfTheRow = pointForTheRow.timeStamp {
                    if timeStampOfFetchedPoint <= timeStampOfPointOfTheRow {
                        if fetchedPoint.isIcrementingTeamA {
                            scoreA += 1
                        }
                        
                        if fetchedPoint.isIcrementingTeamB {
                            scoreB += 1
                        }
                    }
                }
            }
            
            scoreOfTeamA = scoreA
            scoreOfTeamB = scoreB
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

