//
//  TeamsLabelsView.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 10/02/2022.
//

import SwiftUI

struct TeamsLabelsView: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var isLeftPopoverPresent = false
    @State private var isRightPopoverPresent = false
    
    var teamLabelFontSize: CGFloat { return sizeClass == .regular ? 30 : 17 }
    var teamLabelWidth: CGFloat { return sizeClass == .regular ? 300 : 120 }
    var paddingToSemicolon: CGFloat { return sizeClass == .regular ? 30 : 10 }
    
    var teamNameLeft: String { return appProperties.isTeamAonTheLeft ? appProperties.nameOfTeamA : appProperties.nameOfTeamB }
    var teamNameRight: String { return appProperties.isTeamAonTheLeft ? appProperties.nameOfTeamB : appProperties.nameOfTeamA }
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Spacer()
                Text(teamNameLeft)
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .frame(width: teamLabelWidth)
            .padding(.trailing, paddingToSemicolon)
//            .background(Color.red)
            .onTapGesture { isLeftPopoverPresent = true }
            .popover(isPresented: $isLeftPopoverPresent) { NameChangerPopoverView(isItLeftSide: true, popoverPresent: $isLeftPopoverPresent) }
            
            Text(" ")
                .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
            
            HStack {
                Text(teamNameRight)
                    .font(.system(size: teamLabelFontSize, weight: .heavy , design: .rounded))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(width: teamLabelWidth)
            .padding(.leading, paddingToSemicolon)
//            .background(Color.red)
            .onTapGesture { isRightPopoverPresent = true }
            .popover(isPresented: $isRightPopoverPresent) { NameChangerPopoverView(isItLeftSide: false, popoverPresent: $isRightPopoverPresent) }
            Spacer()
        }
    }
}

struct NameChangerPopoverView: View {
    @EnvironmentObject var appProperties: AppProperties
    
    var isItLeftSide: Bool
    @Binding var popoverPresent: Bool
    
    @State private var newName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Click to set a new name", text: $newName).labelsHidden()
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
                    .padding(.leading)
                Button(action: { popoverPresent = false }, label: {
                    Text("Done")
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
                        .padding()
                })
            }
            Spacer()
        }
        .onSubmit { popoverPresent = false }
        .onChange(of: newName, perform: onChange_NewName)
    }
    
    private func onChange_NewName(newNameString: String) {
        guard newNameString.isEmpty == false, newNameString != appProperties.nameOfTeamA, newNameString != appProperties.nameOfTeamB else { return }
        
        if isItLeftSide == appProperties.isTeamAonTheLeft {
            appProperties.nameOfTeamA = newNameString
        } else {
            appProperties.nameOfTeamB = newNameString
        }
    }
}

struct TeamsLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsLabelsView()
    }
}
