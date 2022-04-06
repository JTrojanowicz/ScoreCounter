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
    @Environment(\.horizontalSizeClass) var sizeClass
    
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
    
    private var scoreFontSize: CGFloat { return sizeClass == .regular ? 30 : 20 }
    private var scoreTextFrameWidth: CGFloat { return sizeClass == .regular ? 60 : 45 }
    
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
                        .font(.system(size: scoreFontSize, weight: .bold))
                    Spacer()
                }
                .frame(width: scoreTextFrameWidth)
                
                Text(":")
                    .font(.system(size: scoreFontSize, weight: .bold))
                
                HStack {
                    Spacer()
                    Text("\(scoreOfTeamRight)")
                        .font(.system(size: scoreFontSize, weight: .bold))
                    Spacer()
                }
                .frame(width: scoreTextFrameWidth)
                
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
                        .font(.system(size: 12, weight: .thin, design: .default))
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

