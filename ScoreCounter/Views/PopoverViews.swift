//
//  PopoverViews.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 09/02/2022.
//

import SwiftUI

//======================================================================================
struct NewSetPopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing this set and starting a new one within the same game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Moving to a new set will result in gaining a set for one of the teams and also swapping the playing courts")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: confirmAction) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.red)
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 340)
    }
}

//======================================================================================
struct UndoScorePopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("It will undo the last gained point")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Button(action: confirmAction) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.red)
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 340)
    }
}
//======================================================================================
struct TrashButtonPopover: View {
    let confirmAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Finishing the game")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 16, weight: .bold))
            Text("Finishing the game will result in erasing all the scores (both the points and the sets).\n\nYou cannot undo this action")
                .foregroundColor(Color("BlackWhite"))
                .font(.system(size: 14))
            Button(action: confirmAction) {
                Text("CONFIRM")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color("WhiteBlack"))
                    .background(RoundedRectangle(cornerRadius: 8).frame(width: 250, height: 50).foregroundColor(.red).shadow(radius: 8))
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .frame(width: 340)
    }
}

