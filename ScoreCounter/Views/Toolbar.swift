//
//  Toolbar.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData

struct Toolbar<ResetButtonView: View>: ToolbarContent {
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    @ViewBuilder let resetButtonView: ResetButtonView
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            resetButtonView
        }
        
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Score Counter")
                    .font(.custom("Noteworthy-Bold", size: 30))
                Text("ver. \(appVersion)")
                    .font(.system(size: 10, weight: .medium, design:.default))
                
            }
        }
    }
}

