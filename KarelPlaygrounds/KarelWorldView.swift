//
//  KarelWorldView.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/18/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//The main view of a Karel playground. At the top, there are six "Karel function" buttons. Pressing these buttons will either change Karel's
//location or direction or have Karel pick up or drop beepers. Below that is the Karel world, the main grid in which all the Karel actions
//happen. Below the grid are four "world builder" buttons that allow users to change the number and placement of beepers and obstacles on
//the grid. Finally, below the "world builder" buttons are several smaller miscellaneous buttons that can change the image used for obstacles,
//change the color of the beepers, or delete all the beepers and obstacles in the world.
struct KarelWorldView: View {
    @Environment(\.colorScheme) var colorScheme //keeps track of whether the phone is in dark mode or light mode
    
    @EnvironmentObject var orientation: DeviceOrientation
    @ObservedObject var viewModel: PlaygroundViewModel
    
    @State private var allColors: [Color] = [.gray, .blue, .red, .purple, .orange] //all possible beeper colors
    @State private var prevColor = Color.gray
    @State private var color = Color.gray //current color of the beepers
    @State private var progress: CGFloat = 0.0 //animatable data for when beepers change color
    @State var index: Int = 0 //keeps track of current index in the colors array in order to set the current color
    
    @State private var rotation = 0.0 //Karel's rotation
    @State private var degreesForAnimation = 0.0 //degrees for Karel's 3D rotation animation
    @State private var karelRow = 0 //the row that Karel is currently at
    @State private var karelColumn = 0 //the column that Karel is currently at
    @State private var showCrashAlert = false
    @State private var addBeeperToWorld = false //whether user has toggled the "Add Beeper" button on or off
    @State private var removeBeeperFromWorld = false //whether user has toggled the "Remove Beeper" button on or off
    @State private var addObstacleToWorld = false //whether user has toggled the "Add Obstacle" button on or off
    @State private var removeObstacleFromWorld = false //whether user has toggled the "Remove Obstacle" button on or off
    @State private var showInvalidObstacleLocationAlert = false
    @State private var showNoObjectAlert = false
    
    @State private var showImagePicker = false
    @State private var obstacleImage = Image("obstacle") //keeps track of the image used for obstacles
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var lineWidth: CGFloat = 0 //border for the trash icon, is unhighlighted by default
    
    //Main view of the Karel playground, including all the buttons and the grid view.
    var body: some View {
        GeometryReader { geometry in
            VStack {
                self.karelFunctionButtons(for: geometry.size) //six Karel function buttons on top of the grid
                ZStack {
                    GridView(viewModel: self.viewModel, prevColor: self.$prevColor, color: self.$color, progress: self.$progress,
                             rotation: self.$rotation, degreesForAnimation: self.$degreesForAnimation,
                             karelRow: self.$karelRow, karelColumn: self.$karelColumn,
                             addBeeperToWorld: self.$addBeeperToWorld, removeBeeperFromWorld: self.$removeBeeperFromWorld,
                             addObstacleToWorld: self.$addObstacleToWorld, removeObstacleFromWorld: self.$removeObstacleFromWorld,
                             obstacleImage: self.$obstacleImage, showInvalidObstacleLocationAlert: self.$showInvalidObstacleLocationAlert,
                             showNoObstacleAlert: self.$showNoObjectAlert,
                             size: geometry.size, geometry: geometry, trashLocation: self.trashLocation, lineWidth: self.$lineWidth)
                    RoundedRectangle(cornerRadius: 0).stroke(lineWidth: 1).foregroundColor(Color.gray)
                }
                .aspectRatio(CGSize(width: self.viewModel.numCols * 85, height: self.viewModel.numRows * 100), contentMode: .fit)
                VStack(alignment: .trailing) {
                    self.worldBuilderButtons(for: geometry.size) //four world builder buttons underneath the grid
                    self.obstacleSelectors() //other beeper/obstacle changer buttons
                }
            }
            .padding(5)
        }
        .sheet(isPresented: $showImagePicker) { //sheet for showing either the photo library or camera for users to customize the obstacle image.
            ImagePicker(sourceType: self.imagePickerSourceType) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        self.obstacleImage = Image(uiImage: image!)
                    }
                }
                self.showImagePicker = false
            }
        }
        .onAppear {
            self.karelRow = self.viewModel.numRows - 1
            self.obstacleImage = self.colorScheme == .dark ? Image("obstacle-white") : Image("obstacle")
        }
    }
    
    //The four "world builder" buttons which appear right underneath the grid. These buttons allow for addition/removal of beepers and obstacles.
    private func worldBuilderButtons(for size: CGSize) -> some View {
        HStack {
            addBeeperButton()
            removeBeeperButton()
            addObstacleButton()
            removeObstacleButton()
        }
        .frame(maxWidth: size.width)
        .aspectRatio(22, contentMode: .fit)
    }
    
    //When this button is pressed on, its state is toggled. All the other world builder buttons are toggled off.
    //The user can then select a cell on the grid to remove an obstacle from.
    private func removeObstacleButton() -> some View {
        Button(action: {
            self.removeObstacleFromWorld.toggle()
            self.removeBeeperFromWorld = false
            self.addObstacleToWorld = false
            self.addBeeperToWorld = false
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("Remove Obstacle").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? (self.removeObstacleFromWorld ? Color.red : Color.white) : self.removeObstacleFromWorld ? Color.red : Color.black)
        }
    }
    
    //When this button is pressed on, its state is toggled. All the other world builder buttons are toggled off.
    //The user can then select a cell on the grid to add an obstacle to.
    //An alert will appear if the user tries to add an obstacle to the cell that Karel is currently on.
    private func addObstacleButton() -> some View {
        Button(action: {
            self.addObstacleToWorld.toggle()
            self.removeBeeperFromWorld = false
            self.addBeeperToWorld = false
            self.removeObstacleFromWorld = false
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("Add Obstacle").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? (self.addObstacleToWorld ? Color.red : Color.white) : self.addObstacleToWorld ? Color.red : Color.black)
        }
        .alert(isPresented: self.$showInvalidObstacleLocationAlert) { //put this here as a workaround for having multiple alerts on the same view
            return Alert(
                title: Text("Sorry!"),
                message: Text("Karel cannot be at the same location as an obstacle."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    
    //When this button is pressed on, its state is toggled. All the other world builder buttons are toggled off.
    //The user can then select a cell on the grid to add a beeper to.
    private func addBeeperButton() -> some View {
        Button(action: {
            self.addBeeperToWorld.toggle()
            self.removeBeeperFromWorld = false
            self.addObstacleToWorld = false
            self.removeObstacleFromWorld = false
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("Add Beeper").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? (self.addBeeperToWorld ? Color.red : Color.white) : self.addBeeperToWorld ? Color.red : Color.black)
        }
    }
    
    
    //When this button is pressed on, its state is toggled. All the other world builder buttons are toggled off.
    //The user can then select a cell on the grid to remove a beeper from.
    //An alert will appear if the user tries to remove a beeper from a cell that has no beepers.
    private func removeBeeperButton() -> some View {
        Button(action: {
            self.removeBeeperFromWorld.toggle()
            self.addBeeperToWorld = false
            self.addObstacleToWorld = false
            self.removeObstacleFromWorld = false
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("Remove Beeper").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? (self.removeBeeperFromWorld ? Color.red : Color.white) : self.removeBeeperFromWorld ? Color.red : Color.black)
        }
        .alert(isPresented: self.$showNoObjectAlert) { //put this here as a workaround for having multiple alerts on the same view
            return Alert(
                title: Text("Whoops!"),
                message: Text("There are no objects at this location."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    
    @State private var trashLocation: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    //Row of blue buttons that allow changes to the look of the obstacles and the color of the beepers.
    //Includes a trash icon to delete all beepers and obstacles from the grid, and a color palette icon to change the beeper color.
    //The next three buttons change the image used for the obstacles. The photo icon allows users to choose from their
    //photo library, the camera icon allows users to use their camera to take a photo to use for the obstacles,
    //and the last button uses a default obstacle image when tapped on.
    private func obstacleSelectors() -> some View {
        HStack {
            trashIcon()
            colorChangerButton()
            Button(action: {
                self.imagePickerSourceType = .photoLibrary
                self.showImagePicker = true
            }) {
                Image(systemName: "photo").imageScale(.large).frame(width: 40, height: 40)
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) { //only show camera icon if device has a camera available
                Button(action: {
                    self.imagePickerSourceType = .camera
                    self.showImagePicker = true
                }) {
                    Image(systemName: "camera").imageScale(.large).frame(width: 40, height: 40)
                }
            }
            Button(action: { //default obstacle button. When pressed, a default image is used for the obstacles.
                self.obstacleImage = self.colorScheme == .dark ? Image("obstacle-white") : Image("obstacle")
            }) {
                Image("obstacle").resizable().frame(width: 40, height: 40)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    //Button for changing the color of the beepers. Uses a "color palette" image as its icon.
    //When pressed, the color of the beepers changes to the next color in the array of available colors, and this change is animated
    private func colorChangerButton() -> some View {
        Button(action: {
            self.index = (self.index + 1) % self.allColors.count
            self.progress = 0
            withAnimation(.linear(duration: 0.5)) {
                self.progress = 1
            }
            self.prevColor = self.color
            self.color = self.allColors[self.index]
        }) {
            Image("colorPalette").resizable().frame(width: 40, height: 40)
        }
    }
    
    //Button for the trash icon. Tapping the button will remove all the beepers and obstacles from the world.
    //Users can also drag either all the beepers or all the obstacles into the trash icon's frame to delete them.
    //The trash icon's border will be highlighted in green if the user's dragging motion is hovering over the trash icon.
    //When device is rotated, the trash icon's location changes, so it listens to changes in the device's orientation to update its
    //location (in terms of global coordinates).
    private func trashIcon() -> some View {
        Button(action: {
            self.viewModel.removeAllBeepers()
            self.viewModel.removeAllObstacles()
        }) {
            GeometryReader { geometry in
                Image(systemName: "trash").imageScale(.large).position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: self.lineWidth).foregroundColor(Color.green)
                .onAppear {
                    self.trashLocation = geometry.frame(in: .global)
                }
                .onReceive(self.orientation.$isLandscape) { _ in
                    self.trashLocation = geometry.frame(in: .global)
                }
            }
            .frame(width: 40, height: 40)
        }
    }
    
    //The six "Karel function" buttons which cause Karel to perform some action.
    //They are layed out in two rows of three buttons each.
    private func karelFunctionButtons(for size: CGSize) -> some View {
        VStack {
            HStack {
                turnLeftButton()
                turnRightButton()
                turnAroundButton()
            }
            .aspectRatio(22, contentMode: .fit)
            HStack {
                moveButton()
                pickBeeperButton()
                putBeeperButton()
            }
            .aspectRatio(22, contentMode: .fit)
        }
        .frame(maxWidth: size.width)
    }
    
    
    //This button will cause Karel to "put a beeper" down at its current location.
    //(aka, a beeper gets added to the cell that Karel is currently on)
    private func putBeeperButton() -> some View {
        Button(action: {
            self.viewModel.addBeeper(row: self.karelRow, col: self.karelColumn)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("put_beeper()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    
    //This button will cause Karel to "pick a beeper" up from its current location.
    //(aka, a beeper gets removed from the cell that Karel is currently on)
    //If there is no beeper to pick up at the current location, an alert will be shown.
    private func pickBeeperButton() -> some View {
        Button(action: {
            if self.beeperAtLocation(row: self.karelRow, col: self.karelColumn) {
                self.viewModel.removeBeeper(row: self.karelRow, col: self.karelColumn)
            } else {
                self.showNoObjectAlert = true
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("pick_beeper()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    //This button causes Karel to move one cell over in the direction that it is facing.
    //An alert appears if Karel crashes into a wall or an obstacle
    private func moveButton() -> some View {
        Button(action: {
            self.moveKarel()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("move()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
        .alert(isPresented: self.$showCrashAlert) {
            return Alert(
                title: Text("Crash!"),
                message: Text("Karel hit an obstacle."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    //This button rotates Karel 180 degrees in order to turn around. This rotation is animated implicitly.
    private func turnAroundButton() -> some View {
        Button(action: {
            self.rotation += 180
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("turn_around()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    //This button rotates Karel -90 degrees in order to turn left. This rotation is animated implicitly.
    private func turnLeftButton() -> some View {
        Button(action: {
            self.rotation -= 90
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("turn_left()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    //This button rotates Karel 90 degrees in order to turn right. This rotation is animated implicitly.
    private func turnRightButton() -> some View {
        Button(action: {
            self.rotation += 90
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                Text("turn_right()").minimumScaleFactor(0.5).padding(2)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    
    //Moves Karel forward by one cell in the direction that it is currently facing.
    //If Karel cannot move forward due to it being at the edge of the grid or facing an obstacle, then toggle an alert to be shown.
    private func moveKarel() {
        if abs(Int(self.rotation) % 360) == 0 && self.karelColumn < self.viewModel.numCols - 1
            && !obstacleAtLocation(row: self.karelRow, col: self.karelColumn + 1) { //facing east and no obstacle is blocking Karel
            self.karelColumn += 1
        } else if (Int(self.rotation) % 360 == 180 || Int(self.rotation) % 360 == -180) && self.karelColumn > 0
            && !obstacleAtLocation(row: self.karelRow, col: self.karelColumn - 1) { //facing west and no obstacle is blocking Karel
            self.karelColumn -= 1
        } else if (Int(self.rotation) % 360 == 90 || Int(self.rotation) % 360 == -270) && self.karelRow < self.viewModel.numRows - 1
            && !obstacleAtLocation(row: self.karelRow + 1, col: self.karelColumn) { //facing south and no obstacle is blocking Karel
            self.karelRow += 1
        } else if (Int(self.rotation) % 360 == 270 || Int(self.rotation) % 360 == -90) && self.karelRow > 0
            && !obstacleAtLocation(row: self.karelRow - 1, col: self.karelColumn) { //facing north and no obstacle is blocking Karel
            self.karelRow -= 1
        } else {
            self.showCrashAlert = true
            playCrashSound(sound: "crash", fileExtension: "mp3")
        }
    }
    
    //Checks whether there is an obstacle at the given row, column location
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
    
}


//Keeps track of whether the device is in portrait or landscape mode.
//Needed to update the trash icon's location when the device's orientation changes.
class DeviceOrientation: ObservableObject {
    @Published var isLandscape: Bool = false
}




