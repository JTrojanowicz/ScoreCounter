//
//  ScoreHistoryList.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import AVFoundation

struct HistoryOfSets: View {
    @EnvironmentObject var appProperties: AppProperties
    
    var body: some View {
        TabView(selection: $appProperties.setSelectedAtTabView) {
            ForEach(1...appProperties.currentSet, id: \.self) { setNumber in
                ScoreHistoryList(setNumber: setNumber)
                    .tabItem {
                        Image(systemName: "\(setNumber).square.fill")
                    }
                    .tag(setNumber)
            }
        }
    }
}

struct ScoreHistoryList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appProperties: AppProperties
    
    @FetchRequest var gainedPoints: FetchedResults<OneGainedPoint>
               
    init(setNumber: Int) {
        let fetchRequest: NSFetchRequest<OneGainedPoint>  = OneGainedPoint.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \OneGainedPoint.timeStamp, ascending: false)]
        _gainedPoints = FetchRequest(fetchRequest: fetchRequest, animation: .easeInOut(duration: 20))
    }
    
    var body: some View {
        List {
            ForEach(gainedPoints, id: \.self) { oneGainedPoint in
                ScoreHistoryRow(pointForTheRow: oneGainedPoint)
            }
        }
        .listStyle(.plain) 
    }
}

struct ScoreHistoryList_Previews: PreviewProvider {
    static var previews: some View {
        ScoreHistoryList(setNumber: 1)
    }
}
