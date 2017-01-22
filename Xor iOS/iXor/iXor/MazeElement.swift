//
//  MazeElement.swift
//  iXor
//
//  Created by Mario Rotz on 08.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//


import SpriteKit


enum MazeElementType: Int {
    case space = 0,
    fish,
    chicken,
    map_1,
    map_2,
    map_3,
    map_4,
    mask,
    bad_mask,
    h_wave,
    v_wave,
    puppet,
    bomb,
    acid,
    transporter,
    player_1,
    player_2,
    exit,
    wall,
    step,
    death,
    death_both
}

class MazeElement {
    var column: Int
    var row: Int
    let theMazeElementType: MazeElementType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, mazeElementType: MazeElementType) {
        self.column = column
        self.row = row
        self.theMazeElementType = mazeElementType
    }
    
    static func isMap(_ item:MazeElementType) -> Bool {
        return item==MazeElementType.map_1 || item==MazeElementType.map_2  || item==MazeElementType.map_3 || item==MazeElementType.map_4
    }
    
    static func canMoveUpDown(item:MazeElementType?) -> Bool {
        if let mazeitem = item  {
            let canMove = isMap(mazeitem) || mazeitem == MazeElementType.h_wave || mazeitem == MazeElementType.space || mazeitem == MazeElementType.mask || mazeitem == MazeElementType.bad_mask
            return canMove
        } else {
            return true
        }
    }
    
    static func canMoveLeftRight(item:MazeElementType?) -> Bool {
        if let mazeitem = item  {
            let canMove = isMap(mazeitem) || mazeitem == MazeElementType.v_wave || mazeitem == MazeElementType.space || mazeitem == MazeElementType.mask || mazeitem == MazeElementType.bad_mask
            return canMove
            
        } else {
            return true
        }
    }
    
    

}
