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
    
    var spritesToRemove = Array<SKSpriteNode?>()
    
    let worldNode : SKNode = SKNode()
    let mapMode : SKNode = SKNode()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, playground:Playground) {
        self.playground = playground
        super.init(size:size)
        self.playground.scene = self
        segmentX = self.size.width / CGFloat(Playground.Constants.sichtbareGroesseX)
        segmentY = self.size.height / CGFloat(Playground.Constants.sichtbareGroesseY)
        
        let sceneShallChange : (SceneNotification,PlaygroundPosition?,MazeType?,Bool) -> Void =
        {
            sceneNotification, playgroundposition, mazetype,player in
            if sceneNotification==SceneNotification.UPDATE_VIEWCONTROLLER {
                self.updateViewController!((mazetype?.mazeElementType)!)
            } else
            if sceneNotification==SceneNotification.DRAW_PLAYER {
                self.drawPlayer(position: playgroundposition!, player: player)
            }
            else
            if sceneNotification==SceneNotification.MOVE_CAMERA {
                self.moveCameraToPlaygroundCoordinates(position:playgroundposition!)
            } else
            if sceneNotification==SceneNotification.SPRITE_TO_REMOVE {
                print("sceneShallChange : remove old position\n")
                let mazeType = self.playground.element(position: playgroundposition!)
                self.spritesToRemove.append(mazeType?.sprite)
                self.playground.createEmptySpaceOnPlayground(position: playgroundposition!)
                print("sceneShallChange : remove old position finished\n")

            }
            else
            if sceneNotification==SceneNotification.SPRITE_OVERWRITE {
                self.spritesToRemove.append(mazetype?.sprite)
            }
            
        }

        self.playground.sceneShallChange = sceneShallChange
        
        
        addChild(worldNode)
        drawWholePlayground() //position:PlaygroundPosition(positionX: 0,positionY: 0))
    }
    
    func drawWholePlayground() {
        worldNode.removeAllChildren()
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
                if let sprite = spriteNode(position: PlaygroundPosition(x: y, y: x)) {
                    sprite.removeFromParent()
                    worldNode.addChild(sprite)
                    sprite.xScale = segmentX! / CGFloat(40.0)
                    sprite.yScale = segmentY! / CGFloat(40.0)
                    drawSprite(sprite:sprite,position:PlaygroundPosition(x:x,y:y))
                }
            }
        }
        switchToPlayerOne()
    }
    
    func drawSprite(sprite:SKSpriteNode ,position:PlaygroundPosition) {
        if self.spritesToRemove.count == 0 {
            print("sprite to remove ist leer!")
        }
        let point = CGPoint(x: CGFloat(position.x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(position.y)*segmentY!-segmentY!/2.0)
        let moveAction = SKAction.move(to: point, duration: 0.25)
        sprite.run(moveAction, completion: {
            
            for sprite in self.spritesToRemove
            {
                sprite?.removeFromParent()
            }
            self.spritesToRemove.removeAll()
            if self.playground.justFinished == true {
                self.updateViewController!(MazeElementType.exit)
            }
        })
        
    }
    
    func spriteNode(position:PlaygroundPosition) -> SKSpriteNode?
    {
        let mazeElement = playground.playgroundArray[position.x][position.y]
        return mazeElement.sprite
    }
    
    func switchToPlayerOne() {
        let position = PlaygroundPosition(x:playground.positionPlayerOne.x-4,
                                          y:playground.positionPlayerOne.y-4)
        self.playground.playerPosition = self.playground.positionPlayerOne
        self.playground.oldPlayerPosition = self.playground.positionPlayerOne
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func switchToPlayerTwo() {
        let position = PlaygroundPosition(x:playground.positionPlayerTwo.x-4,
                                          y:playground.positionPlayerTwo.y-4)
        self.playground.playerPosition = self.playground.positionPlayerTwo
        self.playground.oldPlayerPosition = self.playground.positionPlayerTwo
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition){
        var coord = position
        if coord.x<0 {
            coord.x = 0
        }
        if coord.y<0 {
            coord.y = 0
        }
        if coord.x>(Playground.Constants.groesseX-Playground.Constants.sichtbareGroesseX)
        {
            coord.x = Playground.Constants.groesseX - Playground.Constants.sichtbareGroesseX
        }
        if coord.y>(Playground.Constants.groesseY-Playground.Constants.sichtbareGroesseY)
        {
            coord.y = Playground.Constants.groesseY - Playground.Constants.sichtbareGroesseY
        }
        let xCoord = (CGFloat(coord.x)*CGFloat(segmentX!))*CGFloat(-1)
        let yCoord = CGFloat(coord.y)*segmentY!
        worldNode.position = CGPoint(x:xCoord,y:yCoord)
        self.playground.cameraPosition = coord
    }
    
    func drawPlayer(position:PlaygroundPosition,player:Bool) {
        print("zeichne player an position \(position)")
        if player==true {
            playground.positionPlayerOne = position
            drawSprite(sprite:(playground.playerOneSprite)!,position:position)
        }
        else
        {
            playground.positionPlayerTwo = position
            drawSprite(sprite:(playground.playerTwoSprite)!,position:position)
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
