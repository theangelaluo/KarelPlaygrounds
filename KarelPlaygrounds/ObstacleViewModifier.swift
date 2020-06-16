//
//  ObstacleViewModifier.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/26/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//Custom View Modifier to take any given content and turn it into an "obstacle" by putting the content
//inside a prohibition sign (which is red circle outline with a diagonal slash through it)
struct ObstacleMaker: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            content.cornerRadius(100)
            Circle().stroke(lineWidth: 4)
            DiagonalLine().stroke(lineWidth: 4)
        }
        .foregroundColor(Color.red)
        .aspectRatio(1, contentMode: .fit)
    }
    
}

//Custom shape to create the diagonal line for the prohibition sign
struct DiagonalLine: Shape {
    func path(in rect: CGRect) -> Path {
        let topRightCorner = CGPoint(x: rect.width * 0.9, y: rect.height * 0.1)
        let bottomLeftCorner = CGPoint(x: rect.width * 0.1, y: rect.height * 0.9)
        var p = Path()
        p.move(to: topRightCorner)
        p.addLine(to: bottomLeftCorner)
        return p
    }
}

extension View {
    func makeObstacle() -> some View {
        self.modifier(ObstacleMaker())
    }
}
