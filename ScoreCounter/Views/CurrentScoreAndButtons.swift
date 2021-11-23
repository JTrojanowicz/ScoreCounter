//
//  CurrentScore.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct CurrentScore: View {
    @EnvironmentObject var appInfo: AppInfo
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing) {
                Text("Team A")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text("\(appInfo.currentScoreForTeamA)")
                    .font(.system(size: 90, weight: .heavy , design: .monospaced))
            }
            VStack {
                Text(" ")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text(":")
                    .font(.system(size: 90, weight: .heavy , design: .monospaced))
            }
            VStack(alignment: .leading) {
                Text("Team B")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text("\(appInfo.currentScoreForTeamB)")
                    .font(.system(size: 90, weight: .heavy , design: .monospaced))
            }
        }
    }
}

enum ButtonSide {
    case teamA, teamB
}

struct BigButton: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var side: ButtonSide
    var body: some View {
        Button(action: scoreIcrement) {
            Image(systemName: "plus.app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        .padding()
    }
    
    private func scoreIcrement() {
        managedObjectContext.performAndWait {
            let onePoint = OneGainedPoint(context: managedObjectContext)
            
            onePoint.timeStamp = Date()
            
            switch(side) {
            case .teamA:
                onePoint.isIcrementingTeamA = true
                print("isIcrementingTeamA")
            case .teamB:
                onePoint.isIcrementingTeamB = true
                print("isIcrementingTeamB")
            }
            
            PersistenceController.shared.save()
        }
    }
}

struct CurrentScoreAndButtons: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.height > geometry.size.width { // portrait
                VStack(spacing: 0) {
                    Spacer()
                    CurrentScore()
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        BigButton(side: .teamA)
                        Spacer()
                        BigButton(side: .teamB)
                        Spacer()
                    }
                    Spacer()
                }
            } else { // landscape
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BigButton(side: .teamA)
                        Spacer()
                        CurrentScore()
                        Spacer()
                        BigButton(side: .teamB)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CurrentScore_Previews: PreviewProvider {
    static var previews: some View {
        CurrentScoreAndButtons()
            .previewInterfaceOrientation(.portrait)
    }
}
