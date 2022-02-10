//
//  ScoresPanel.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 10/02/2022.
//

import SwiftUI

struct ScoresPanel: View {
    @EnvironmentObject var appProperties: AppProperties
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Set no.")
                    .font(.system(size: 20, weight: .bold , design: .rounded))
                    .foregroundColor(Color("Gray-LightGray"))
                Text("\(appProperties.currentSet)")
                    .font(.system(size: 26, weight: .heavy , design: .monospaced))
                    .foregroundColor(Color("Gray-LightGray"))
            }
            .padding(.top)
            
            Spacer()
            TeamsLabelsView()
//                .background(Color.yellow)
            Spacer()
            CurrentScore()
            Spacer()
            BigButtons()
                .padding(.bottom)
//                .background(Color.yellow)
            Spacer()
        }
    }
}

struct ScoresPanel_Previews: PreviewProvider {
    static var previews: some View {
        ScoresPanel()
    }
}
