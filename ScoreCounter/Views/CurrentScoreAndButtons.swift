//
//  CurrentScore.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI

struct CurrentScore: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing) {
                Text("Team A")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text("2")
                    .font(.system(size: 90, weight: .heavy , design: .rounded))
            }
            VStack {
                Text(" ")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text(":")
                    .font(.system(size: 90, weight: .heavy , design: .rounded))
            }
            VStack(alignment: .leading) {
                Text("Team B")
                    .font(.system(size: 30, weight: .heavy , design: .rounded))
                Text("1")
                    .font(.system(size: 90, weight: .heavy , design: .rounded))
            }
        }
//        .background(Color.yellow)
    }
}

enum ButtonSide {
    case left, right
}

struct BigButton: View {
    var side: ButtonSide
    var body: some View {
        Button(action: scoreIcrement) {
            Image(systemName: "plus.app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        .padding()
//        .background(Color.yellow)
    }
    
    private func scoreIcrement() {
        switch(side) {
        case .left:
            print("teamLeftScoreIcrement")
        case .right:
            print("teamRightScoreIcrement")
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
                        BigButton(side: .left)
                        Spacer()
                        BigButton(side: .right)
                        Spacer()
                    }
                    Spacer()
                }
            } else { // landscape
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BigButton(side: .left)
                        Spacer()
                        CurrentScore()
                        Spacer()
                        BigButton(side: .right)
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
