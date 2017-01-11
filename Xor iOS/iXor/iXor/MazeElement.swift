//
//  MazeElement.swift
//  iXor
//
//  Created by Mario Rotz on 08.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//


import SpriteKit



class MazeElement {
    var column: Int
    var row: Int
    let mazeElementType: MazeElementType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, cookieType: MazeElementType) {
        self.column = column
        self.row = row
        self.mazeElementType = cookieType
    }
}
