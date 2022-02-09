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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var currentScoreForTeamA = 0
    @State private var currentScoreForTeamB = 0
    @State private var isLeftPopoverPresent = false
    @State private var isRightPopoverPresent = false
    
    var teamLabelFontSize: CGFloat { return horizontalSizeClass == .compact ? 25 : 30 }
    
    var scoreFontSize: CGFloat { return horizontalSizeClass == .compact ? 70 : 90 }
    
    var gainedSetsScoreFontSize: CGFloat { return horizontalSizeClass == .compact ? 30 : 50 }
    
    var scoreSize: CGFloat { return horizontalSizeClass == .compact ? 110 : 150 }
    
    var teamNameLeft: String { return appProperties.isTeamAonTheLeft ? appProperties.nameOfTeamA : appProperties.nameOfTeamB }
    var teamNameRight: String { return appProperties.isTeamAonTheLeft ? appProperties.nameOfTeamB : appProperties.nameOfTeamA }
    
    var teamScoreLeft: String { return appProperties.isTeamAonTheLeft ? String(currentScoreForTeamA) : String(currentScoreForTeamB) }
    var teamScoreRight: String { return appProperties.isTeamAonTheLeft ? String(currentScoreForTeamB) : String(currentScoreForTeamA) }
    
    var gainedSetsTeamLeft: String { return appProperties.isTeamAonTheLeft ? String(appProperties.gainedSetsOfTeamA) : String(appProperties.gainedSetsOfTeamB) }
    var gainedSetsTeamRight: String { return appProperties.isTeamAonTheLeft ? String(appProperties.gainedSetsOfTeamB) : String(appProperties.gainedSetsOfTeamA) }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Spacer()
            Text("(\(gainedSetsTeamLeft))")
                .font(.system(size: gainedSetsScoreFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .padding()
            Spacer()
            VStack {
                Text(teamNameLeft)
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                    .multilineTextAlignment(.center)
                    .onTapGesture { isLeftPopoverPresent = true }
                    .popover(isPresented: $isLeftPopoverPresent) { NameChangerView(isItLeftSide: true, popoverPresent: $isLeftPopoverPresent) }
                HStack {
                    Spacer()
                    Text(teamScoreLeft)
                        .font(.system(size: scoreFontSize, weight: .heavy, design: .monospaced))
                        .frame(width: scoreSize)
                    Spacer()
                }
            }
            VStack {
                Text(" ")
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                Text(":")
                    .font(.system(size: scoreFontSize, weight: .heavy , design: .monospaced))
            }
            VStack {
                Text(teamNameRight)
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                    .multilineTextAlignment(.center)
                    .onTapGesture { isRightPopoverPresent = true }
                    .popover(isPresented: $isRightPopoverPresent) { NameChangerView(isItLeftSide: false, popoverPresent: $isRightPopoverPresent) }
                HStack {
                    Spacer()
                    Text(teamScoreRight)
                        .font(.system(size: scoreFontSize, weight: .heavy , design: .monospaced))
                        .frame(width: scoreSize)
                    Spacer()
                }
            }
            Spacer()
            Text("(\(gainedSetsTeamRight))")
                .font(.system(size: gainedSetsScoreFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
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

struct NameChangerView: View {
    @EnvironmentObject var appProperties: AppProperties
    
    var isItLeftSide: Bool
    @Binding var popoverPresent: Bool
    
    @State private var newName: String = ""
    
    var body: some View {
        TextField("Click to set a new name", text: $newName).labelsHidden()
            .padding()
            .onSubmit { popoverPresent = false }
            .onChange(of: newName, perform: onChange_NewName)
    }
    
    private func onChange_NewName(newNameString: String) {
        guard newNameString.isEmpty == false, newNameString != appProperties.nameOfTeamA, newNameString != appProperties.nameOfTeamB else { return }
        
        if isItLeftSide == appProperties.isTeamAonTheLeft {
            appProperties.nameOfTeamA = newNameString
        } else {
            appProperties.nameOfTeamB = newNameString
        }
    }
}

