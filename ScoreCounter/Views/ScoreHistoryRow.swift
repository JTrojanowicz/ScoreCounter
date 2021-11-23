//
//  ScoreHistoryRow.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 21/11/2021.
//

import SwiftUI

struct ScoreHistoryRow: View {
    var oneGainedPoint: OneGainedPoint
    var allGainedPoints: [OneGainedPoint]
    
    @State private var scoreOfTeamA: Int = 0
    @State private var scoreOfTeamB: Int = 0
    
    private var timeStamp: String {
        return oneGainedPoint.timeStamp?.toString(dateFormat: "HH:mm:ss") ?? "Unknown"
    }
    
    var body: some View {
        Text("Time of gained point: \(timeStamp) -- Team A: \(scoreOfTeamA), Team B: \(scoreOfTeamB)")
            .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        for storedPoint in allGainedPoints {
            if let storedPointTimeStamp = storedPoint.timeStamp, let thisPointTimeStamp = oneGainedPoint.timeStamp {
                if storedPointTimeStamp < thisPointTimeStamp {
                    if storedPoint.isIcrementingTeamA {
                        scoreOfTeamA+=1
                    }
                    if storedPoint.isIcrementingTeamB {
                        scoreOfTeamB += 1
                    }
                }
            }
//            print(storedPoint.timeStamp?.toString(dateFormat: "HH:mm:ss") ?? "Unknown")
        }
//        print("===========")
    }
}

