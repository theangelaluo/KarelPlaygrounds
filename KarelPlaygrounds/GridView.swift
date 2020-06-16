//
//  GridView.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/22/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var viewModel: PlaygroundViewModel
    @Environment(\.colorScheme) var colorScheme //whether the phone is in dark mode or light mode

    @Binding var prevColor: Color //previous color of the beepers
    @Binding var color: Color //current color of the beepers
    @Binding var progress: CGFloat //animatable data for the beeper's color change animation
    
    @Binding var rotation: Double //Karel's current rotation, represented in degrees
    @Binding var degreesForAnimation: Double //degrees for Karel's 3D rotation when Karel is tapped on (via explicit animation)
    @Binding var karelRow: Int //the row that Karel is currently on
    @Binding var karelColumn: Int //the column that Karel is currently on
    @Binding var addBeeperToWorld: Bool //keeps track of whether add beeper button is clicked on or off
    @Binding var removeBeeperFromWorld: Bool //keeps track of whether remove beeper button is clicked on or off
    @Binding var addObstacleToWorld: Bool //keeps track of whether add obstacle button is clicked on or off
    @Binding var removeObstacleFromWorld: Bool //keeps track of whether remove obstacle button is clicked on or off
    @Binding var obstacleImage: Image //keeps track of the image used for obstacles in the world
    
    //toggles alert when trying to move Karel on top of an obstacle or trying to add an obstacle on top of Karel's current location
    @Binding var showInvalidObstacleLocationAlert: Bool
    @Binding var showNoObstacleAlert: Bool //toggles alert when trying to remove a beeper/obstacle that isn't there

    let size: CGSize
    let geometry: GeometryProxy
    
    let trashLocation: CGRect //keeps track of trash icon's location on the screen
    @Binding var lineWidth: CGFloat //border width for the trash icon, is toggled when user drags objects into the trash icon's location
    
    //Draws the main grid which represents the Karel world, including its beepers, obstacles, and Karel itself
    //Source: https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid
    var body: some View {
        VStack {
            ForEach(0..<self.viewModel.numRows, id: \.self) { row in
                HStack {
                    ForEach(0..<self.viewModel.numCols, id: \.self) { column in
                        ZStack {
                            self.cell()
                            self.placeBeeper(row: row, col: column)
                            self.placeObstacle(row: row, col: column)
                            if self.karelRow == row && self.karelColumn == column {
                                self.Karel
                            }
                        }
                        .onTapGesture {
                            //tapping on a cell will change the world depending on the state of the "world builder" buttons
                            //(i.e. add beeper, remove obstacle, etc)
                            self.changeWorld(row: row, column: column)
                        }
                        .frame(maxWidth: self.size.width / CGFloat(self.viewModel.numCols))
                        .aspectRatio(0.85, contentMode: .fit)
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    }
                }
            }
        }
    }
    
    //This function changes the Karel world depending on which (if any) of the "world builder" buttons are toggled on.
    //For example, if the "Add Beeper" button is pressed on (i.e. addBeeperToWorld is true), then a beeper will be added at the given row, column location
    //The same goes for removing beepers, adding obstacles, and removing obstacles
    //If none of the four buttons are pressed and there is no obstacle at the location that was clicked on, then Karel will move to that location
    //If the user is trying to add an obstacle where Karel is currently at, or move Karel to a location that has an obstacle,
    //an alert will show letting the user know that the action is not allowed.
    //If the user is trying to remove a beeper or obstacle at a location where there is none, an alert will show as well
    private func changeWorld(row: Int, column: Int) {
        if self.addBeeperToWorld {
            self.viewModel.addBeeper(row: row, col: column)
        } else if self.removeBeeperFromWorld {
            if self.beeperAtLocation(row: row, col: column) {
                self.viewModel.removeBeeper(row: row, col: column)
            } else { //there is no beeper at that location to remove
                self.showNoObstacleAlert = true
            }
        } else if self.addObstacleToWorld && (self.karelRow != row || self.karelColumn != column) {
            self.viewModel.addObstacle(row: row, col: column)
        } else if self.addObstacleToWorld && self.karelRow == row && self.karelColumn == column {
            //don't allow obstacle and Karel to be at the same location, show alert to user to indicate this
            self.showInvalidObstacleLocationAlert = true
        } else if self.removeObstacleFromWorld {
            if self.obstacleAtLocation(row: row, col: column) {
                self.viewModel.removeObstacle(row: row, col: column)
            } else { //there is no obstacle at that location to remove
                self.showNoObstacleAlert = true
            }
        } else if !obstacleAtLocation(row: row, col: column) {
            self.karelRow = row
            self.karelColumn = column
        } else { //means that the user is trying to move Karel to a location that has an obstacle on it
            self.showInvalidObstacleLocationAlert = true
        }
    }
    
    
    //Checks whether an obstacle is at the given row, column location
    private func obstacleAtLocation(row: Int, col: Int) -> Bool {
        if let numObstacle = self.viewModel.obstaclePositions[PlaygroundModel.Cell(row: row, col: col)] {
            if numObstacle != 0 {
                return true
            }
        }
        return false
    }
    
    //Checks whether at least one beeper is at the given row, column location
    private func beeperAtLocation(row: Int, col: Int) -> Bool {
        if let numBeepers = self.viewModel.beeperCountDict[PlaygroundModel.Cell(row: row, col: col)] {
            if numBeepers != 0 {
                return true
            }
        }
        return false
    }
    
    //Places a beeper at the given row, column location (if there is one).
    private func placeBeeper(row: Int, col: Int) -> some View {
        let cell = PlaygroundModel.Cell(row: row, col: col)
        let numberOfBeepers = self.viewModel.beeperCountDict[cell]!
        return Group {
            if numberOfBeepers != 0 {
                GeometryReader { geometry in
                    ZStack {
                        AnimatableBeeper(progress: 1).fill(self.prevColor) //static view of the beeper
                        AnimatableBeeper(progress: self.progress) //animates when the color of the beeper is changed
                            .foregroundColor(self.color)
                        AnimatableBeeper(progress: 1).stroke(lineWidth: 1) //beeper outline
                        Text(numberOfBeepers > 1 ? String(numberOfBeepers) : "")
                    }
                    .offset(self.beeperOffset)
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    .aspectRatio(1, contentMode: .fit)
                    .gesture(self.panGestureForBeepers(in: geometry))
                }
            } else {
                EmptyView()
            }
        }
    }
    
    //Places an obstacle at the given row, column location (if there is one).
    private func placeObstacle(row: Int, col: Int) -> some View {
        let cell = PlaygroundModel.Cell(row: row, col: col)
        let obstacle = self.viewModel.obstaclePositions[cell]!
        return Group {
            if obstacle != 0 {
                GeometryReader { geometry in
                    ZStack {
                        self.obstacleImage.resizable().makeObstacle()
                    }
                    .offset(self.obstacleOffset)
                    .aspectRatio(1, contentMode: .fit)
                    .gesture(self.panGestureForObstacles(in: geometry))
                }
            } else {
                EmptyView()
            }
        }
    }
    
    //View for a single cell in the grid
    private func cell() -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 0).fill(self.colorScheme == .dark ? Color.black : Color.white)
            Image(systemName: "plus").imageScale(.large).foregroundColor(self.colorScheme == .dark ? .white : .gray)
        }
    }

    //View for Karel the Robot. Tapping on Karel will make Karel do a "happy dance" (i.e. an explicit animation using rotation3DEffect)
    private var Karel: some View {
        ZStack {
            KarelOutline()
            .stroke(lineWidth: 3)
        }
        .rotationEffect(.degrees(self.rotation))
        .animation(Animation.easeInOut)
        .rotation3DEffect(.degrees(self.degreesForAnimation), axis: (x: 1, y: 1, z: 1))
        .onTapGesture {
            withAnimation {
                self.degreesForAnimation = 360
            }
            self.degreesForAnimation = 0
        }
    }
    
    
    @GestureState private var gestureBeeperOffset: CGSize = .zero
    @State private var steadyStateBeeperOffset: CGSize = .zero
    
    private var beeperOffset: CGSize {
        (self.steadyStateBeeperOffset + gestureBeeperOffset)
    }
    
    //Dragging gesture for beepers. Dragging one beeper will drag all the beepers that are on the grid. The user can drag the beepers to the trash icon
    //to delete all the beepers on the grid. If the user drags the beepers somewhere else, the beepers will snap back to their original locations.
    private func panGestureForBeepers(in geometry: GeometryProxy) -> some Gesture {
        return DragGesture()
        .updating($gestureBeeperOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation
        }
        .onChanged { value in
            //If true, this means that the user has dragged the beeper into the location of the trash icon
            if (geometry.frame(in: .global).midX + self.gestureBeeperOffset.width > self.trashLocation.minX && geometry.frame(in: .global).midX + self.gestureBeeperOffset.width < self.trashLocation.maxX &&
                geometry.frame(in: .global).midY + self.gestureBeeperOffset.height > self.trashLocation.minY && geometry.frame(in: .global).midY + self.gestureBeeperOffset.height < self.trashLocation.maxY
                ) {
                self.lineWidth = 3 //the border of the trash icon is then highlighted to indicate to the user that they are moving the beepers to the trash
            } else {
                self.lineWidth = 0
            }
        }
        .onEnded { finalDragGestureValue in
            self.steadyStateBeeperOffset = self.steadyStateBeeperOffset + (finalDragGestureValue.translation)
            //If true, this means that the user has dragged the beeper into the location of the trash icon
            if (geometry.frame(in: .global).midX + self.steadyStateBeeperOffset.width > self.trashLocation.minX && geometry.frame(in: .global).midX + self.steadyStateBeeperOffset.width < self.trashLocation.maxX &&
                geometry.frame(in: .global).midY + self.steadyStateBeeperOffset.height > self.trashLocation.minY && geometry.frame(in: .global).midY + self.steadyStateBeeperOffset.height < self.trashLocation.maxY
                ) {
                self.viewModel.removeAllBeepers()
            }
            self.steadyStateBeeperOffset = .zero
            self.lineWidth = 0 //trash icon is no longer highlighted
        }
    }
    
    
    @GestureState private var gestureObstacleOffset: CGSize = .zero
    @State private var steadyStateObstacleOffset: CGSize = .zero
    
    private var obstacleOffset: CGSize {
        (self.steadyStateObstacleOffset + gestureObstacleOffset)
    }
    
    //Dragging gesture for obstacles. Dragging one obstacle will drag all the obstacles that are on the grid. The user can drag the obstacles to the trash
    //icon to delete all the obstacles on the grid. If the user drags the obstacles somewhere else, the obstacles will snap back to their original locations.
    private func panGestureForObstacles(in geometry: GeometryProxy) -> some Gesture {
        return DragGesture()
        .updating($gestureObstacleOffset) { latestDragGestureValue, gestureObstacleOffset, transaction in
                gestureObstacleOffset = latestDragGestureValue.translation            
        }
        .onChanged { value in
            //If true, this means that the user has dragged the beeper into the location of the trash icon
            if (geometry.frame(in: .global).midX + self.gestureObstacleOffset.width > self.trashLocation.minX && geometry.frame(in: .global).midX + self.gestureObstacleOffset.width < self.trashLocation.maxX &&
                geometry.frame(in: .global).midY + self.gestureObstacleOffset.height > self.trashLocation.minY && geometry.frame(in: .global).midY + self.gestureObstacleOffset.height < self.trashLocation.maxY
                ) {
                self.lineWidth = 3
            } else {
                self.lineWidth = 0
            }
        }
        .onEnded { finalDragGestureValue in
            self.steadyStateObstacleOffset = self.steadyStateObstacleOffset + (finalDragGestureValue.translation)
            //If true, this means that the user has dragged the beeper into the location of the trash icon
            if (geometry.frame(in: .global).midX + self.steadyStateObstacleOffset.width > self.trashLocation.minX && geometry.frame(in: .global).midX + self.steadyStateObstacleOffset.width < self.trashLocation.maxX &&
                geometry.frame(in: .global).midY + self.steadyStateObstacleOffset.height > self.trashLocation.minY && geometry.frame(in: .global).midY + self.steadyStateObstacleOffset.height < self.trashLocation.maxY
                ) {
                self.viewModel.removeAllObstacles()
            }
            self.steadyStateObstacleOffset = .zero
            self.lineWidth = 0 //trash icon is no longer highlighted
        }
    }
    
}


//Based on EmojiArt project from lecture
extension CGPoint {
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    static func +(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func -(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

//Based on EmojiArt project from lecture
extension CGSize {
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}
