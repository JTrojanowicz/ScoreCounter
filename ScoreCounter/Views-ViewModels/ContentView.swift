//
//  ContentView.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 20/11/2021.
//

import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    @EnvironmentObject var appProperties: AppProperties
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { geo in // it looks like using GeometryReader also somewhere else (in a nested view) mess up the views... (also it is better to use it on the top of the view)
            NavigationView {
                VStack {
                    ScoresPanel()
                        .frame(height: geo.size.height*3/5)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("White-DarkGray")).shadow(radius: 8))
                        .padding()
                    
                    HistoryOfSets() //List view behaves like a Spacer() --> it fills possible space in the container (or even with greater force it pushes other view... I don't understand it.., eg. replacing it with Spacer will NOT get the same results - it is stronger.)
                        .padding()
                }
                .toolbar {
                    Toolbar(appProperties: appProperties,
                            previousSetView: {
                        if viewModel.isGoToPreviousSetButtonShown {
                            Button(action: { appProperties.goToPreviousSet(with: managedObjectContext) }) {
                                Image(systemName: "chevron.backward.square")
                            }
                        }
                    }, undoButtonView: {
                        if viewModel.isUndoLastScoreButtonShown {
                            Button(action: { viewModel.isUndoButtonPopoverShown = true }) {
                                Image(systemName: "arrow.uturn.backward.square")
                                    .popover(isPresented: $viewModel.isUndoButtonPopoverShown) {
                                        UndoScorePopover(isUndoButtonPopoverShown: $viewModel.isUndoButtonPopoverShown)
                                    }
                            }
                        }
                    }, newSetView: {
                        if viewModel.isNewSetButtonShown {
                            Button(action: { viewModel.isNewSetButtonPopoverShown = true }) {
                                if geo.size.width > 400 {
                                    Text("New set")
                                        .popover(isPresented: $viewModel.isNewSetButtonPopoverShown) {
                                            NewSetPopover(isNewSetButtonPopoverShown: $viewModel.isNewSetButtonPopoverShown)
                                        }
                                } else { // .compact
                                    VStack(spacing: 0) {
                                        Text("New")
                                        Text("set")
                                    }
                                    .popover(isPresented: $viewModel.isNewSetButtonPopoverShown) {
                                        NewSetPopover(isNewSetButtonPopoverShown: $viewModel.isNewSetButtonPopoverShown)
                                    }
                                }
                            }
                        }
                    }, titleView: {
                        VStack(spacing: 0) {
                            Text("Score Counter")
                                .font(.custom("Noteworthy-Bold", size: /*geo.size.width > 400 ? 22 :*/ 18))
                            Text("ver. \(viewModel.appVersion)")
                                .font(.system(size: 10, weight: .medium, design:.default))
                        }
                    }, trashButtonView: {
                        if viewModel.isTrashButtonShown {
                            Button(action: { viewModel.isTrashButtonPopoverShown = true }) {
                                Image(systemName: "trash")
                                    .popover(isPresented: $viewModel.isTrashButtonPopoverShown) {
                                        TrashButtonPopover(isTrashButtonPopoverShown: $viewModel.isTrashButtonPopoverShown)
                                    }
                            }
                        }
                    }, moreButtonView: {
                        Button(action: { viewModel.isMorePopoverShown = true }) {
                            Label("More", systemImage: "ellipsis")
                                .popover(isPresented: $viewModel.isMorePopoverShown) {
                                    MorePopover()
                                }
                        }
                    })
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear { viewModel.showOrRemoveToolbarButtons(with: appProperties.currentSet, and: managedObjectContext) }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextDidSave)) { _ in viewModel.showOrRemoveToolbarButtons(with: appProperties.currentSet, and: managedObjectContext)  }
            .onChange(of: appProperties.currentSet) { _ in viewModel.showOrRemoveToolbarButtons(with: appProperties.currentSet, and: managedObjectContext) }
        }
    }
}


struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            Text("Hello World")
                .previewLayout(PreviewLayout.sizeThatFits)
            //                .previewLayout(PreviewLayout.fixed(width: <#width#>, height: <#height#>))
                .previewInterfaceOrientation(.landscapeLeft)
                .padding()
                .previewDisplayName("Default preview")
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .regular)
            
            Text("Text - row 2")
                .previewLayout(PreviewLayout.sizeThatFits)
            //                .previewLayout(PreviewLayout.fixed(width: <#width#>, height: <#height#>))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
