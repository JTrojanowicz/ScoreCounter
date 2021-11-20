//
//  Toolbar.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI

struct Toolbar: ToolbarContent {
    var appVersion: String {
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Text("Reset")
        }
        
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Score Counter")
                    .font(.custom("Noteworthy-Bold", size: 30))
                Text("ver. \(appVersion)")
                    .font(.system(size: 10, weight: .medium, design:.default))
                
            }
        }
        
        ToolbarItemGroup {
            HStack {
                Text("Icon")
            }
        }
        
//        ToolbarItemGroup(placement: .bottomBar) {
//            Text("ver. \(appVersion)")
//                .font(.system(size: 10, weight: .medium, design:.default))
//
//        }
        
    }
}

