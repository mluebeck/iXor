//
//  GameScene.swift
//  iXor
//
//  Created by Mario Rotz on 04.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    static let MazeElementToFilename : [MazeElementType:String] = [
                                                                    MazeElementType.space:      "space_gelb",
                                                                    MazeElementType.fish:       "fisch",
                                                                    MazeElementType.chicken:    "huhn",
                                                                    MazeElementType.map_1:      "karte",
                                                                    MazeElementType.map_2:      "karte",
                                                                    MazeElementType.map_3:      "karte",
                                                                    MazeElementType.map_4:      "karte",
                                                                    MazeElementType.mask:       "maske",
                                                                    MazeElementType.bad_mask:   "maske_trauer",
                                                                    MazeElementType.h_wave:     "wellen",
                                                                    MazeElementType.v_wave:     "wellen_vertikal",
                                                                    MazeElementType.puppet:     "puppe",
                                                                    MazeElementType.bomb:       "bombe",
                                                                    MazeElementType.acid:       "saeure",
                                                                    MazeElementType.transporter:"kompass",
                                                                    MazeElementType.player_1:   "spieler1",
                                                                    MazeElementType.player_2:   "spieler2",
                                                                    MazeElementType.exit:       "ausgang",
                                                                    MazeElementType.wall:       "wand"
    ]
    var playground : Playground?
    let worldNode : SKNode = SKNode()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, playground:Playground) {
        super.init(size:size)
        addChild(worldNode)
        self.playground = playground
        drawWholePlayground() //position:PlaygroundPosition(positionX: 0,positionY: 0))
    }
    
    func drawWholePlayground() {
        let segmentX = Float(self.size.width) / Float(Playground.Constants.sichtbareGroesseX)
        let segmentY = Float(self.size.height) / Float(Playground.Constants.sichtbareGroesseY)
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
                if let sprite = spriteNode(position: PlaygroundPosition(positionX: y, positionY: x)) {
                    worldNode.addChild(sprite)
                    sprite.xScale = CGFloat(segmentX) / CGFloat(40.0)
                    sprite.yScale = CGFloat(segmentY) / CGFloat(40.0)
                    sprite.position = CGPoint(x: CGFloat(x)*CGFloat(segmentX)+CGFloat(segmentX)/2.0,
                                            y: self.size.height - CGFloat(y)*CGFloat(segmentY)-CGFloat(segmentY)/2.0)
                }
            }
        }
        worldNode.position = CGPoint(x:0,y:0)
    }
    
    func spriteNode(position:PlaygroundPosition) -> SKSpriteNode?
    {
        let mazeElement = playground?.playgroundArray[position.positionX][position.positionY]
        return mazeElement?.sprite
    }
}
