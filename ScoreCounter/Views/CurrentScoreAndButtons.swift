//
//  CurrentScore.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import AVFoundation

struct CurrentScore: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var currentScoreForTeamA = 0
    @State private var currentScoreForTeamB = 0
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing) {
                Text("Team A")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text("\(currentScoreForTeamA)")
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
                Text("\(currentScoreForTeamB)")
                    .font(.system(size: 90, weight: .heavy , design: .monospaced))
            }
        }
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

                let systemSoundID: SystemSoundID = 1010
                AudioServicesPlaySystemSound(systemSoundID)
                
                print("isIcrementingTeamA - systemSoundID = \(systemSoundID)")
            case .teamB:
                onePoint.isIcrementingTeamB = true

                let systemSoundID: SystemSoundID = 1021
                AudioServicesPlaySystemSound(systemSoundID)
                
                print("isIcrementingTeamB - systemSoundID = \(systemSoundID)")
            }
            
            PersistenceController.shared.save()
        }
    }
}

struct CurrentScoreAndButtons: View {
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if (geometry.size.height / geometry.size.width > 1.1) { // portrait
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
                    .onAppear {
                        print("geometry.size.height = \(geometry.size.height)")
                        print("geometry.size.width = \(geometry.size.width)")
                        print("geometry.size.height / geometry.size.width = \(geometry.size.height / geometry.size.width)")
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
                    .onAppear {
                        print("geometry.size.height = \(geometry.size.height)")
                        print("geometry.size.width = \(geometry.size.width)")
                        print("geometry.size.height / geometry.size.width = \(geometry.size.height / geometry.size.width)")
                    }
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
