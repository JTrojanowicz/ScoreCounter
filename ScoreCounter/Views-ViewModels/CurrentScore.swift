//
//  CurrentScore.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct CurrentScore: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var currentScoreForTeamA = 0
    @State private var currentScoreForTeamB = 0
    
    var teamScoreFontSize: CGFloat { return sizeClass == .regular ? 90 : 50 }
    var teamScoreFrameSize: CGFloat { return sizeClass == .regular ? 120 : 70 }
    var teamGainedSetsFontSize: CGFloat { return sizeClass == .regular ? 40 : 17 }
    var paddingToSemicolon: CGFloat { return sizeClass == .regular ? 30 : 10 }
    
    var teamScoreLeft: String { return appProperties.isTeamAonTheLeft ? String(currentScoreForTeamA) : String(currentScoreForTeamB) }
    var teamScoreRight: String { return appProperties.isTeamAonTheLeft ? String(currentScoreForTeamB) : String(currentScoreForTeamA) }
    
    var gainedSetsTeamLeft: String { return appProperties.isTeamAonTheLeft ? String(appProperties.gainedSetsOfTeamA) : String(appProperties.gainedSetsOfTeamB) }
    var gainedSetsTeamRight: String { return appProperties.isTeamAonTheLeft ? String(appProperties.gainedSetsOfTeamB) : String(appProperties.gainedSetsOfTeamA) }
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            Text("(\(gainedSetsTeamLeft))")
                .font(.system(size: teamGainedSetsFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(Color("Gray-LightGray"))
            Spacer()
            Text(teamScoreLeft)
                .font(.system(size: teamScoreFontSize, weight: .heavy, design: .monospaced))
                .frame(width: teamScoreFrameSize)
//            .background(Color.red)
            
            Text(":")
                .font(.system(size: teamScoreFontSize, weight: .heavy , design: .monospaced))
            
            Text(teamScoreRight)
                .font(.system(size: teamScoreFontSize, weight: .heavy , design: .monospaced))
                .frame(width: teamScoreFrameSize)
//            .background(Color.red)
            
            Spacer()
            Text("(\(gainedSetsTeamRight))")
                .font(.system(size: teamGainedSetsFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(Color("Gray-LightGray"))
            Spacer()
        }
        //        .background(Color.brown)
        .onAppear(perform: calculateCurrentScores)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave)) { _ in calculateCurrentScores()  }
        .onChange(of: appProperties.currentSet, perform: { _ in calculateCurrentScores() })
    }
    
    private func calculateCurrentScores() {
        
        let coreDataOperations = CoreDataOperations(moc: managedObjectContext)
        let score = coreDataOperations.getScore(of: appProperties.currentSet, with: Date())
        
        currentScoreForTeamA = score.teamA
        currentScoreForTeamB = score.teamB
        print("A: \(currentScoreForTeamA), B: \(currentScoreForTeamB)")
    }
}



