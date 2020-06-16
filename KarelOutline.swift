//
//  KarelShape.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/18/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//Draws Karel the Robot, which is a custom shape.
struct KarelOutline: Shape {
    
    func path(in rect: CGRect) -> Path {
        let startingLeftCorner = CGPoint(x: rect.width * 0.17, y: rect.minY)
        let bottomLeftCorner1 = CGPoint(x: rect.width * 0.17, y: rect.height * 0.8)
        let bottomLeftCorner2 = CGPoint(x: rect.width * 0.3, y: rect.height * 0.9)
        let bottomRightCorner = CGPoint(x: rect.maxX, y: rect.height * 0.9)
        let topRightCorner1 = CGPoint(x: rect.maxX, y: rect.height * 0.1)
        let topRightCorner2 = CGPoint(x: rect.width * 0.85, y: rect.minY)
        
        var p = Path()
        
        //draws outer body of Karel
        p.move(to: startingLeftCorner)
        p.addLine(to: bottomLeftCorner1)
        p.addLine(to: bottomLeftCorner2)
        p.addLine(to: bottomRightCorner)
        p.addLine(to: topRightCorner1)
        p.addLine(to: topRightCorner2)
        p.addLine(to: startingLeftCorner)
        
        
        //draws the leg on the left side
        let leftLegStart = CGPoint(x: rect.width * 0.17, y: rect.height * 0.6)
        p.move(to: leftLegStart)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.6))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.8))
        
        //draws the bottom leg
        let bottomLegStart = CGPoint(x: rect.width * 0.6, y: rect.height * 0.9)
        p.move(to: bottomLegStart)
        p.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.maxY))
        
        //draws the inner rectangle
        let innerLeftCorner = CGPoint(x: rect.width * 0.35, y: rect.height * 0.1)
        p.move(to: innerLeftCorner)
        p.addLine(to: CGPoint(x: rect.width * 0.35, y: innerLeftCorner.y + rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.width * 0.72, y: innerLeftCorner.y + rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.height * 0.1))
        p.addLine(to: innerLeftCorner)
        
        //draws the inner line
        p.move(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.75))
        p.addLine(to: CGPoint(x: rect.width * 0.83, y: rect.height * 0.75))
        
        return p
    }
}

