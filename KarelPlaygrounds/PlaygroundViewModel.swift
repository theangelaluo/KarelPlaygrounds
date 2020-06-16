//
//  PlaygroundViewModel.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/23/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI
import Combine

//View Model for a Karel playground
class PlaygroundViewModel: ObservableObject, Hashable, Identifiable {
    @Published private var model: PlaygroundModel
    
    static func == (lhs: PlaygroundViewModel, rhs: PlaygroundViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private var autosaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultKey = "KarelPlayground.\(self.id.uuidString)"
        model = PlaygroundModel(json: UserDefaults.standard.data(forKey: defaultKey)) ?? PlaygroundModel(numRows: 5, numCols: 5, beepers: [], obstacles: [])
        autosaveCancellable = $model.sink { model in
            UserDefaults.standard.set(model.json, forKey: defaultKey)
        }
    }
    
    // MARK: - Access to the Model
    
    var numRows: Int { //number of rows in the world
        model.numRows
    }
    
    var numCols: Int { //number of columns in the world
        model.numCols
    }
    
    var beepers: Array<PlaygroundModel.Beeper> { //array of all beepers in the world
        model.beepers
    }
    
    var obstacles: Array<PlaygroundModel.Obstacle> { //array of all obstacles in the world
        model.obstacles
    }
    
    //dictionary mapping each cell in the grid to the number of beepers at that cell
    var beeperCountDict: [PlaygroundModel.Cell:Int] {
        model.beeperCountDict
    }
    
    //dictionary mapping each cell in the grid to the number of obstacles at that cell
    var obstaclePositions: [PlaygroundModel.Cell:Int] {
        model.obstaclePositions
    }
    
    // MARK: - Intents
    func addBeeper(row: Int, col: Int) { //adds beeper to the world
        model.addBeeper(row: row, column: col)
    }
    
    func removeBeeper(row: Int, col: Int) { //removes beeper from the world
        model.removeBeeper(row: row, column: col)
    }
    
    func addObstacle(row: Int, col: Int) { //adds obstacle to the world
        model.addObstacle(row: row, column: col)
    }
    
    func removeObstacle(row: Int, col: Int) { //removes obstacle from the world
        model.removeObstacles(row: row, column: col)
    }
    
    //changes the number of rows in the world to the new given value
    func changeNumRows(to number: Int) {
        model.changeNumRows(to: number)
    }
    
    //changes the number of columns in the world to the new given value
    func changeNumCols(to number: Int) {
        model.changeNumCols(to: number)
    }
    
    //updates the beeper dictionary when the number of rows or columns in the world changes
    //by resetting every location to have 0 beepers
    func updateBeeperDict(rows: Int, cols: Int) {
        model.updateBeeperCountDict(rows: rows, cols: cols)
    }
    
    //updates the obstacle dictionary when the number of rows or columns in the world changes
    //by resetting every location to have 0 obstacles
    func updateObstaclePositions(rows: Int, cols: Int) {
        model.updateObstaclePositions(rows: rows, cols: cols)
    }
    
    //removes all beepers in the world
    func removeAllBeepers() {
        model.removeAllBeepers()
    }
    
    //removes all obstacles in the world
    func removeAllObstacles() {
        model.removeAllObstacles()
    }
}


extension Data {
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}
