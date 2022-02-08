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
    @EnvironmentObject var appProperties: AppProperties
    
    var pointForTheRow: OneGainedPoint
    
    @State private var scoreOfTeamA: Int = 0
    @State private var scoreOfTeamB: Int = 0
    
    private var timeStamp: String {
        return pointForTheRow.timeStamp?.toString(dateFormat: "HH:mm:ss") ?? "Unknown"
    }
    
    private var isIcrementingTeamLeft: Bool { return appProperties.isTeamAonTheLeft ? pointForTheRow.isIcrementingTeamA :  pointForTheRow.isIcrementingTeamB }
    private var isIcrementingTeamRight: Bool { return appProperties.isTeamAonTheLeft ? pointForTheRow.isIcrementingTeamB :  pointForTheRow.isIcrementingTeamA }
    
    private var scoreOfTeamLeft: Int { return appProperties.isTeamAonTheLeft ? scoreOfTeamA :  scoreOfTeamB }
    private var scoreOfTeamRight: Int { return appProperties.isTeamAonTheLeft ? scoreOfTeamB :  scoreOfTeamA }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                
                if isIcrementingTeamLeft {
                    Image(systemName: "arrowtriangle.up.square")
                } else {
                    Spacer().frame(width: 20)
                }
                
                HStack {
                    Spacer()
                    Text("\(scoreOfTeamLeft)")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                }
                .frame(width: 60)
                
                Text(":")
                    .font(.system(size: 30, weight: .bold))
                
                HStack {
                    Spacer()
                    Text("\(scoreOfTeamRight)")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                }
                .frame(width: 60)
                
                if isIcrementingTeamRight {
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
        fetchRequest.predicate = NSPredicate(format: "setNumber == %i", pointForTheRow.setNumber) //filter out all the scores gained at different sets
        
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

