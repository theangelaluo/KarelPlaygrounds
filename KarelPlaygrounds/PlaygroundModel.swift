//
//  PlaygroundModel.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/23/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI


//Model for a Karel playground. Handles the logic of adding/removing beepers/obstacles, and keeping track of the world's dimensions.
struct PlaygroundModel: Codable {
    private(set) var beepers: Array<Beeper>
    private(set) var numRows: Int
    private(set) var numCols: Int
    private(set) var beeperCountDict: [Cell: Int] //stores how many beepers are at each location
    private(set) var obstaclePositions: [Cell: Int] //stores whether or not an obstacle is at each location (either 0 or 1 obstacles per location)
    private(set) var obstacles: Array<Obstacle>
    
    //When a Karel playground is created, it starts with 0 beepers and 0 obstacles by default
    init(numRows: Int, numCols: Int, beepers: Array<Beeper>, obstacles: Array<Obstacle>) {
        self.beeperCountDict = [Cell: Int]()
        self.obstacles = obstacles
        self.numRows = numRows
        self.numCols = numCols
        self.beepers = beepers
        for row in 0..<self.numRows {
            for col in 0..<self.numCols {
                let cell = Cell(row: row, col: col)
                self.beeperCountDict[cell] = 0
            }
        }
        self.obstaclePositions = [Cell: Int]()
        for row in 0..<self.numRows {
            for col in 0..<self.numCols {
                let cell = Cell(row: row, col: col)
                self.obstaclePositions[cell] = 0
            }
        }
    }
    
    init?(json: Data?) {
        if json != nil, let newPlayground = try? JSONDecoder().decode(PlaygroundModel.self, from: json!) {
            self = newPlayground
        } else {
            return nil
        }
    }
    
    mutating func addBeeper(row: Int, column: Int) {
        removeObstacles(row: row, column: column)
        let newBeeper = Beeper(id: UUID(), row: row, column: column)
        beepers.append(newBeeper)
        let cell = Cell(row: row, col: column)
        self.beeperCountDict[cell]! += 1
        
    }
    
    mutating func removeBeeper(row: Int, column: Int) {
        for index in 0..<self.beepers.count {
            if self.beepers[index].row == row && self.beepers[index].column == column {
                self.beepers.remove(at: index)
                let cell = Cell(row: row, col: column)
                self.beeperCountDict[cell]! -= 1
                return
            }
        }
    }
    
    mutating func addObstacle(row: Int, column: Int) {
        if let _ = beeperCountDict[Cell(row: row, col: column)] {
            beeperCountDict[Cell(row: row, col: column)] = 0
        }
        let newObstacle = Obstacle(id: UUID(), row: row, column: column)
        obstacles.append(newObstacle)
        let cell = Cell(row: row, col: column)
        self.obstaclePositions[cell]! = 1
        
    }
    
    
    mutating func removeObstacles(row: Int, column: Int) {
        for index in 0..<self.obstacles.count {
            if self.obstacles[index].row == row && self.obstacles[index].column == column {
                self.obstacles.remove(at: index)
                let cell = Cell(row: row, col: column)
                self.obstaclePositions[cell]! = 0
                return
            }
        }
    }
    
    //removes all beepers by setting each location in the world to have 0 beepers,
    //and setting the beeper array to an empty array
    mutating func removeAllBeepers() {
        self.beepers = []
        self.beeperCountDict = [Cell: Int]()
        for row in 0..<self.numRows {
            for col in 0..<self.numCols {
                let cell = Cell(row: row, col: col)
                self.beeperCountDict[cell] = 0
            }
        }
    }
    
    //removes all obstacles by setting each location in the world to have 0 obstacles,
    //and setting the obstacle array to an empty array
    mutating func removeAllObstacles() {
        self.obstacles = []
        self.obstaclePositions = [Cell: Int]()
        for row in 0..<self.numRows {
            for col in 0..<self.numCols {
                let cell = Cell(row: row, col: col)
                self.obstaclePositions[cell] = 0
            }
        }
    }
    
    mutating func changeNumRows(to number: Int) {
        self.numRows = number
    }
    
    mutating func changeNumCols(to number: Int) {
        self.numCols = number
    }
    
    //This function is called when either the number of rows or columns is changed
    //Resets the beeper array and dictionary such that the world has 0 beepers in it
    mutating func updateBeeperCountDict(rows: Int, cols: Int) {
        var newBeeperDict = [Cell: Int]()
        for row in 0..<rows {
            for col in 0..<cols {
                let cell = Cell(row: row, col: col)
                newBeeperDict[cell] = 0
            }
        }
        self.beeperCountDict = newBeeperDict
        self.beepers = []
    }
    
    //This function is called when either the number of rows or columns is changed
    //Resets the obstacle array and dictionary such that the world has 0 obstacles in it
    mutating func updateObstaclePositions(rows: Int, cols: Int) {
        var newObstaclePositions = [Cell: Int]()
        for row in 0..<rows {
            for col in 0..<cols {
                let cell = Cell(row: row, col: col)
                newObstaclePositions[cell] = 0
            }
        }
        self.obstaclePositions = newObstaclePositions
        self.obstacles = []
    }
    
    struct Cell: Hashable, Codable {
        var row: Int
        var col: Int
    }
    
    struct Obstacle: Identifiable, Hashable, Codable {
        var id: UUID
        var row: Int
        var column: Int
    }
    
    
    struct Beeper: Identifiable, Hashable, Codable {
        var id: UUID
        var row: Int
        var column: Int
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
}
