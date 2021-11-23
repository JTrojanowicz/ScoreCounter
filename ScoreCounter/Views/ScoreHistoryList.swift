//
//  ScoreHistoryList.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct ScoreHistoryList: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timeStamp, order: .reverse)]) var gainedPoints: FetchedResults<OneGainedPoint>
    
    var body: some View {
        List {
            Section(header: Text("SCORE HISTORY")) {
                ForEach(gainedPoints, id: \.self) { oneGainedPoint in
                    ScoreHistoryRow(oneGainedPoint: oneGainedPoint, allGainedPoints: gainedPoints.reversed())
                }
            }
        }
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        
    }
}

struct ScoreHistoryList_Previews: PreviewProvider {
    static var previews: some View {
        ScoreHistoryList()
    }
}
