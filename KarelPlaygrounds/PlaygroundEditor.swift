//
//  PlaygroundEditor.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/25/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//View for editing a playground, using a Form
//Users are able to edit the title, number of rows, and number of columns in the playground
struct PlaygroundEditor: View {
    @EnvironmentObject var store: PlaygroundStore
    @Binding var playground: PlaygroundViewModel
    @Binding var isShowing: Bool

    @State private var playgroundName: String = ""
    @State private var numRows: Int = 0
    @State private var numCols: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            self.showEditorTitle()
            Divider()
            Form {
                Section(header: Text("Playground Name")) {
                    TextField("Playground Name", text: $playgroundName, onEditingChanged: { began in
                        if !began {
                            if self.playgroundName == "" {
                                self.playgroundName = "Untitled"
                            }
                            self.store.setName(self.playgroundName, for: self.playground)
                        }
                    })
                }
                Section {
                    //restricts the number of rows of the world to be between 1 and 20
                    Stepper("Number of Rows: \(self.numRows)", value: $numRows, in: 1...10, onEditingChanged: { began in
                        if !began {
                            self.playground.changeNumRows(to: self.numRows)
                            self.playground.updateBeeperDict(rows: self.numRows, cols: self.numCols)
                            self.playground.updateObstaclePositions(rows: self.numRows, cols: self.numCols)
                        }
                    })
                }
                Section {
                    //restricts the number of columns of the world to be between 1 and 20
                    Stepper("Number of Columns: \(self.numCols)", value: $numCols, in: 1...10, onEditingChanged: { began in
                        if !began {
                            self.playground.changeNumCols(to: self.numCols)
                            self.playground.updateBeeperDict(rows: self.numRows, cols: self.numCols)
                            self.playground.updateObstaclePositions(rows: self.numRows, cols: self.numCols)
                        }
                    })
                }
            }
        }
        .onAppear {
            self.playgroundName = self.store.name(for: self.playground) ?? ""
            self.numRows = self.playground.numRows
            self.numCols = self.playground.numCols
        }
        .onDisappear { //work around for non-responsive "Done" button
            self.store.updatePlayground(self.playground, name: self.playgroundName)
        }
    }
  
    private func showEditorTitle() -> some View {
        ZStack {
            Text("Playground Editor").font(.headline).padding()
            HStack {
                Spacer()
                Button(action: {
                    self.isShowing = false
                }, label: {Text("Done")}).padding()
            }
        }
    }
}

