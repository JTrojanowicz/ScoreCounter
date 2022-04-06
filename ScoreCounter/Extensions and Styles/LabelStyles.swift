//
//  LabelStyles.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 06/04/2022.
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack() {
            configuration.icon
                .foregroundColor(.blue)
                .frame(width: 30)
            configuration.title
                .foregroundColor(Color("BlackWhite"))
            Spacer()
        }
    }
}
