//
//  MorePopover.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 06/04/2022.
//

import SwiftUI

struct MorePopover: View {
    @EnvironmentObject var appProperties: AppProperties
    
    var body: some View {
        VStack {
            if appProperties.isSpeakerON {
                Label("Audio ON", systemImage: "speaker.wave.3.fill")
                    .labelStyle(CustomLabelStyle())
                    .onTapGesture(perform: toggleSpeaker)
            } else {
                Label("Audio OFF", systemImage: "speaker.slash.fill")
                    .labelStyle(CustomLabelStyle())
                    .onTapGesture(perform: toggleSpeaker)
            }
            Divider()
            if appProperties.isTeamAonTheLeft {
                Label("Swap the courts", systemImage: "arrow.left.arrow.right.square")
                    .labelStyle(CustomLabelStyle())
                    .onTapGesture(perform: swapCourts)
            } else {
                Label("Swap the courts", systemImage: "arrow.left.arrow.right.square.fill")
                    .labelStyle(CustomLabelStyle())
                    .onTapGesture(perform: swapCourts)
            }
            Spacer()
        }
        .padding()
    }
    
    private func toggleSpeaker() {
        appProperties.isSpeakerON.toggle()
    }
    
    func swapCourts() {
        appProperties.swapTheCourts()
    }
}

struct MorePopover_Preview: PreviewProvider {
    static var appProperties = AppProperties()
    static var previews: some View {
        Group {
            MorePopover()
                .environmentObject(appProperties)
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewInterfaceOrientation(.landscapeLeft)
                .padding()
                .previewDisplayName("Default preview")
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .regular)
            
            MorePopover()
                .environmentObject(appProperties)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
