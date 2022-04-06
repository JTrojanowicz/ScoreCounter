//
//  GeometryGetter.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 26/11/2021.
//

import SwiftUI

// GeometryGetter helps to determine what size would be given to particular View
// How to use it, see: https://stackoverflow.com/questions/56729619/what-is-geometry-reader-in-swiftui

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }
    
    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}

