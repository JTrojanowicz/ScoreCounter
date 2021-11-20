//
//  ContentView.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI

struct ContentView: View {
    let historyHeightRatio = 0.33
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 0) {
                    CurrentScoreAndButtons()
                        .frame(width: geo.size.width, height: geo.size.height*(1-historyHeightRatio), alignment: .center)
                    ScoreHistoryList()
                        .frame(width: geo.size.width,
                               height: geo.size.height*historyHeightRatio,
                               alignment: .center)
                        .background(Color.red)
                }
            }
            .toolbar {
                Toolbar()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
//        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portrait)
    }
}
