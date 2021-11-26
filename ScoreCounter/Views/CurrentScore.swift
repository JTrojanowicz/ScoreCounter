//
//  CurrentScore.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct CurrentScore: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var currentScoreForTeamA = 0
    @State private var currentScoreForTeamB = 0
    
    var teamLabelFontSize: CGFloat {
        return horizontalSizeClass == .compact ? 25 : 30
    }
    
    var scoreFontSize: CGFloat {
        return horizontalSizeClass == .compact ? 70 : 90
    }
    
    var scoreSize: CGFloat {
        return horizontalSizeClass == .compact ? 110 : 150
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text("Team A")
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                HStack {
                    Spacer()
                    Text("\(currentScoreForTeamA)")
                        .font(.system(size: scoreFontSize, weight: .heavy, design: .monospaced))
                    Spacer()
                }
                .frame(width: scoreSize)
            }
            VStack {
                Text(" ")
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                Text(":")
                    .font(.system(size: scoreFontSize, weight: .heavy , design: .monospaced))
            }
            VStack {
                Text("Team B")
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                HStack {
                    Spacer()
                    Text("\(currentScoreForTeamB)")
                        .font(.system(size: scoreFontSize, weight: .heavy , design: .monospaced))
                    Spacer()
                }
                .frame(width: scoreSize)
            }
        }
        .padding()
        .onAppear(perform: calculateCurrentScores)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave)) { _ in calculateCurrentScores()  }
    }
    
    private func calculateCurrentScores() {
        
        var scoreOfTeamA: Int = 0
        var scoreOfTeamB: Int = 0
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        do {
            // Execute Fetch Request
            let fetchedGainedPoints = try managedObjectContext.fetch(fetchRequest)
            
            for gainedPoint in fetchedGainedPoints {
                if gainedPoint.isIcrementingTeamA {
                    scoreOfTeamA += 1
                }
                
                if gainedPoint.isIcrementingTeamB {
                    scoreOfTeamB += 1
                }
            }
            
            print("A: \(scoreOfTeamA), B: \(scoreOfTeamB)")
            currentScoreForTeamA = scoreOfTeamA
            currentScoreForTeamB = scoreOfTeamB
            
        } catch {
            let fetchError = error as NSError
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
    }
}


