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
    death_both,
    skull
}

enum MazeEvent : Int {
    case step_done = 0,
    map1_found,
    map2_found,
    map3_found,
    map4_found,
    exit_found,
    transporter_found,
    mask_found,
    bad_mask_found,
    death_player1,
    death_player2,
    death_both,
    redraw
}

struct MazeElement {
    var mazeElementType : MazeElementType?
    var sprite : SKSpriteNode?
    
    func removeSprite(duration:TimeInterval) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        sprite?.run(fadeOut, completion: {
            self.sprite?.removeFromParent()
        })
    }
    
    func removeSprite() {
        removeSprite(duration: 0.25)
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
