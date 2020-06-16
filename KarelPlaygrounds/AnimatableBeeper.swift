//
//  AnimatableBeeper.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/28/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//Inspired by: https://trailingclosure.com/swiftui-animating-color-changes/
struct AnimatableBeeper: Shape {
    var progress: CGFloat

    //Allows for "expanding" diamond animation
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    //Draws a diamond shape to represent a beeper. This shape uses an Animatable. Each of the four corners/points of the
    //diamond start in the center and then expand out to the outer edges of the bounding rectangle
    func path(in rect: CGRect) -> Path {
        let startingTopPoint = CGPoint(x: rect.width / 2, y: rect.minY + (rect.height / 2 - rect.height / 2 * progress))
        let leftCorner = CGPoint(x: rect.minX + (rect.width / 2 - rect.width / 2 * progress), y: rect.height / 2)
        let bottomCorner = CGPoint(x: rect.width / 2, y: rect.maxY - (rect.height / 2 - rect.height / 2 * progress))
        let rightCorner = CGPoint(x: rect.maxX - (rect.width / 2 - rect.width / 2 * progress), y: rect.height / 2)
    
        var p = Path()
        p.move(to: startingTopPoint)
        p.addLine(to: leftCorner)
        p.addLine(to: bottomCorner)
        p.addLine(to: rightCorner)
        p.addLine(to: startingTopPoint)
        return p
    }
}

