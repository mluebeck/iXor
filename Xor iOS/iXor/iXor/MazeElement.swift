//
//  MazeElement.swift
//  iXor
//
//  Created by Mario Rotz on 08.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//


import SpriteKit


enum MazeElementType: Int
{
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
    skull,
    redCorner
    
    func isMap()->Bool {
        return self==MazeElementType.map_1 || self==MazeElementType.map_2  || self==MazeElementType.map_3 || self==MazeElementType.map_4

    }
    
    func canMoveUpDown() -> Bool
    {
        let canMove = self.isMap() || self == MazeElementType.h_wave || self == MazeElementType.space || self == MazeElementType.mask || self == MazeElementType.bad_mask
        return canMove
    }
    
    func canMoveLeftRight() -> Bool
    {
        let canMove = self.isMap() || self == MazeElementType.v_wave || self == MazeElementType.space || self == MazeElementType.mask || self == MazeElementType.bad_mask
        return canMove
    }
}

enum MazeEvent : Int
{
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
    redraw,
    switchPlayer,
    movesExceeded,
    reloadAll,
    none
}

class MazeElement:NSObject
{
    var mazeElementType : MazeElementType?
    var sprite : SKSpriteNode?
    
    init(mazeElementType: MazeElementType?, sprite: SKSpriteNode?)
    {
        self.mazeElementType = mazeElementType
        self.sprite = sprite
    }
      
    func removeSprite(duration:TimeInterval)
    {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        sprite?.run(fadeOut, completion: {
            self.sprite?.removeFromParent()
        })
    }
    
    func removeSprite() {
        removeSprite(duration: 0.25)
    }
    
}
