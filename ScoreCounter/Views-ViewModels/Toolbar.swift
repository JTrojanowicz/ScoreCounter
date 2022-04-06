//
//  Toolbar.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct Toolbar<PreviousSetView: View, UndoButtonView: View, NewSetView: View, TitleView: View, TrashButtonView: View, MoreButtonView: View>: ToolbarContent {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var appProperties: AppProperties
    
    @ViewBuilder var previousSetView: PreviousSetView
    @ViewBuilder var undoButtonView: UndoButtonView
    @ViewBuilder var newSetView: NewSetView
    @ViewBuilder var titleView: TitleView
    @ViewBuilder var trashButtonView: TrashButtonView
    @ViewBuilder var moreButtonView: MoreButtonView
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                previousSetView
                undoButtonView
                newSetView
            }
        }
        
        ToolbarItem(placement: .principal) {
            titleView
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                trashButtonView
                moreButtonView
            }
        }
    }
}

