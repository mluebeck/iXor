//
//  GameScene.swift
//  iXor
//
//  Created by Mario Rotz on 04.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var segmentX : CGFloat?
    var segmentY : CGFloat?
    var exitDone = false
    var updateViewController : ((MazeElementType)->Void)?
    
    let factorX = CGFloat(Playground.Constants.groesseX-Playground.Constants.sichtbareGroesseX)*CGFloat(-1.0)
    let factorY = CGFloat(Playground.Constants.groesseY-Playground.Constants.sichtbareGroesseY)

    var playground : Playground
    
    var spriteToRemove : SKSpriteNode?
    
    let worldNode : SKNode = SKNode()
    let mapMode : SKNode = SKNode()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, playground:Playground) {
        self.playground = playground
        super.init(size:size)
        segmentX = self.size.width / CGFloat(Playground.Constants.sichtbareGroesseX)
        segmentY = self.size.height / CGFloat(Playground.Constants.sichtbareGroesseY)
        addChild(worldNode)
        drawWholePlayground() //position:PlaygroundPosition(positionX: 0,positionY: 0))
    }
    
    func drawWholePlayground() {
        worldNode.removeAllChildren()
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
                if let sprite = spriteNode(position: PlaygroundPosition(positionX: y, positionY: x)) {
                    sprite.removeFromParent()
                    worldNode.addChild(sprite)
                    sprite.xScale = segmentX! / CGFloat(40.0)
                    sprite.yScale = segmentY! / CGFloat(40.0)
                    drawSprite(sprite:sprite,position:PlaygroundPosition(positionX:x,positionY:y))
                }
            }
        }
        switchToPlayerOne()
    }
    
    func drawSprite(sprite:SKSpriteNode ,position:PlaygroundPosition) {
        let point = CGPoint(x: CGFloat(position.positionX)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(position.positionY)*segmentY!-segmentY!/2.0)
        let moveAction = SKAction.move(to: point, duration: 0.25)
        sprite.run(moveAction, completion: {
            self.spriteToRemove?.removeFromParent()
            if self.playground.justFinished == true {
                self.updateViewController!(MazeElementType.exit)
            }
        })
        
    }
    
    func spriteNode(position:PlaygroundPosition) -> SKSpriteNode?
    {
        let mazeElement = playground.playgroundArray[position.positionX][position.positionY]
        return mazeElement.sprite
    }
    
    func switchToPlayerOne() {
        let coordinate = PlaygroundPosition(positionX:playground.positionPlayerOne.positionX-4,
                                            positionY:playground.positionPlayerOne.positionY-4)
        
        moveCameraToPlaygroundCoordinates(coordinate:coordinate)
    }
    
    func switchToPlayerTwo() {
        let coordinate = PlaygroundPosition(positionX:playground.positionPlayerTwo.positionX-4,
                                            positionY:playground.positionPlayerTwo.positionY-4)
        moveCameraToPlaygroundCoordinates(coordinate:coordinate)
    }
    
    func moveCameraToPlaygroundCoordinates(coordinate:PlaygroundPosition){
        var coord = coordinate
        if coord.positionX<0 {
            coord.positionX = 0
        }
        if coord.positionY<0 {
            coord.positionY = 0
        }
        if coord.positionX>(Playground.Constants.groesseX-Playground.Constants.sichtbareGroesseX)
        {
            coord.positionX = Playground.Constants.groesseX - Playground.Constants.sichtbareGroesseX
        }
        if coord.positionY>(Playground.Constants.groesseY-Playground.Constants.sichtbareGroesseY)
        {
            coord.positionY = Playground.Constants.groesseY - Playground.Constants.sichtbareGroesseY
        }
        let xCoord = (CGFloat(coord.positionX)*CGFloat(segmentX!))*CGFloat(-1)
        let yCoord = CGFloat(coord.positionY)*segmentY!
        worldNode.position = CGPoint(x:xCoord,y:yCoord)
        self.playground.cameraPosition = coord
    }
    
    func drawPlayer(coordinate:PlaygroundPosition,player:Bool) {
        if player==true {
            playground.positionPlayerOne = coordinate
            drawSprite(sprite:(playground.playerOneSprite)!,position:coordinate)
        }
        else
        {
            playground.positionPlayerTwo = coordinate
            drawSprite(sprite:(playground.playerTwoSprite)!,position:coordinate)
        }
    }
    
    func showMap() {
        mapMode.removeAllChildren()
        let tinySegmentX = self.size.width / CGFloat(Playground.Constants.groesseX)
        let tinySegmentY = self.size.height / CGFloat(Playground.Constants.groesseY)
        for x in 0..<Playground.Constants.groesseX
        {
            for y in 0..<Playground.Constants.groesseY
            {
                if (x <= Playground.Constants.groesseX / 2) {
                    
                    if (y <= Playground.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_1) == nil)
                    {
                        continue
                    }
                    if ( y > Playground.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_3) == nil)
                    {
                        continue
                    }
                }
                else
                {
                    if (y <= Playground.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_2) == nil)
                    {
                        continue
                    }
                
                    if (y > Playground.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_4) == nil)
                    {
                        continue
                    }
                }
                
                let mazeElement = playground.playgroundArray[y][x]
                var sprite : SKSpriteNode?
                if let type = mazeElement.mazeElementType {
                    switch(type) {
                    
                    case MazeElementType.player_1:
                        sprite = SKSpriteNode(color: UIColor.darkGray, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.player_2:
                        sprite = SKSpriteNode(color: UIColor.darkGray, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.wall:
                        sprite = SKSpriteNode(color: UIColor.red, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.mask:
                        sprite = SKSpriteNode(color: UIColor.blue, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.bad_mask:
                        sprite = SKSpriteNode(color: UIColor.blue, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.v_wave:
                        sprite = SKSpriteNode(color: UIColor.yellow, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.h_wave:
                        sprite = SKSpriteNode(color: UIColor.white, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.exit:
                        sprite = SKSpriteNode(color: UIColor.green, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.bomb:
                        sprite = SKSpriteNode(color: UIColor.black, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.chicken:
                        sprite = SKSpriteNode(color: UIColor.purple, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.fish:
                        sprite = SKSpriteNode(color: UIColor.brown, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.puppet:
                        sprite = SKSpriteNode(color: UIColor.orange, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.transporter:
                        sprite = SKSpriteNode(color: UIColor.magenta, size:CGSize(width:10.0,height:10.0))
                        break
                    default:
                        break
                    }
                }
                if !(sprite == nil) {
                    mapMode.addChild(sprite!)
                    sprite?.xScale = tinySegmentX / CGFloat(10.0)
                    sprite?.yScale = tinySegmentY / CGFloat(10.0)
                    let point = CGPoint(x: CGFloat(x)*tinySegmentX+tinySegmentX/2.0,y: self.size.height - CGFloat(y)*tinySegmentY-tinySegmentY/2.0)
                    let moveAction = SKAction.move(to: point, duration: 0.0)
                    sprite?.run(moveAction)
                }
                
            }
        }
        removeAllChildren()
        addChild(mapMode)
    }
    
    func hideMap() {
        removeAllChildren()
        addChild(worldNode)
    }
}
