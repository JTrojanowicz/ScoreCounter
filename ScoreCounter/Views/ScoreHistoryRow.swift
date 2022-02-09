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
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        let score = coreDataOperations.getScore(of: pointForTheRow.setNumber, with: pointForTheRow.timeStamp)
        scoreOfTeamA = score.teamA
        scoreOfTeamB = score.teamB
    }
}

