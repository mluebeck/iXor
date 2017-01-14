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

    let factorX = CGFloat(Playground.Constants.groesseX-Playground.Constants.sichtbareGroesseX)*CGFloat(-1.0)
    let factorY = CGFloat(Playground.Constants.groesseY-Playground.Constants.sichtbareGroesseY)

    var playground : Playground?
    let worldNode : SKNode = SKNode()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, playground:Playground) {
        super.init(size:size)
        
        segmentX = self.size.width / CGFloat(Playground.Constants.sichtbareGroesseX)
        segmentY = self.size.height / CGFloat(Playground.Constants.sichtbareGroesseY)
        
        addChild(worldNode)
        self.playground = playground
        drawWholePlayground() //position:PlaygroundPosition(positionX: 0,positionY: 0))
    }
    
    func drawWholePlayground() {
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
                if let sprite = spriteNode(position: PlaygroundPosition(positionX: y, positionY: x)) {
                    worldNode.addChild(sprite)
                    sprite.xScale = segmentX! / CGFloat(40.0)
                    sprite.yScale = segmentY! / CGFloat(40.0)
                    
                    drawSprite(sprite:sprite,position:PlaygroundPosition(positionX:x,positionY:y))
                    
                    //)sprite.position = CGPoint(x: CGFloat(x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(y)*segmentY!-segmentY!/2.0)
                }
            }
        }
        moveCameraToPlaygroundCoordinates(coordinate:PlaygroundPosition(positionX:0,positionY:0))

        //switchToPlayerOne()
    }
    
    func drawSprite(sprite:SKSpriteNode ,position:PlaygroundPosition) {
        sprite.position = CGPoint(x: CGFloat(position.positionX)*segmentX!+segmentX!/2.0,
                                  y: self.size.height - CGFloat(position.positionY)*segmentY!-segmentY!/2.0)
    }
    
    func spriteNode(position:PlaygroundPosition) -> SKSpriteNode?
    {
        let mazeElement = playground?.playgroundArray[position.positionX][position.positionY]
        return mazeElement?.sprite
    }
    
    
    
    
    func switchToPlayerOne() {
        let coordinate = PlaygroundPosition(positionX:(playground?.positionPlayerOne.positionX)!-4,
                                            positionY:(playground?.positionPlayerOne.positionY)!-4)
        
        moveCameraToPlaygroundCoordinates(coordinate:coordinate)
    }
    
    func switchToPlayerTwo() {
        let coordinate = PlaygroundPosition(positionX:(playground?.positionPlayerTwo.positionX)!-4,
                                            positionY:(playground?.positionPlayerTwo.positionY)!-4)
        
        moveCameraToPlaygroundCoordinates(coordinate:coordinate)
    }
    
    func movePlayerDown() {
        movePlayer(direction: PlayerMoveDirection.DOWN)
        //let position = playground?.playerOneSprite?.position
        //playground?.playerOneSprite?.position = CGPoint(x:(position?.x)!,y:(position?.y)!-segmentY!)
    }
    
    func movePlayerUp() {
        movePlayer(direction: PlayerMoveDirection.UP)

        //let position = playground?.playerOneSprite?.position
        //playground?.playerOneSprite?.position = CGPoint(x:(position?.x)!,y:(position?.y)!+segmentY!)
    }
    
    func movePlayerRight() {
        movePlayer(direction: PlayerMoveDirection.RIGHT)

        //let position = playground?.playerOneSprite?.position
        //playground?.playerOneSprite?.position = CGPoint(x:(position?.x)!+segmentX!,y:(position?.y)!)
    }
    
    func movePlayerLeft(){
        movePlayer(direction: PlayerMoveDirection.LEFT)

        //let position = playground?.playerOneSprite?.position
        //let newPosition = CGPoint(x:(position?.x)!-segmentX!,y:(position?.y)!)
        //playground?.playerOneSprite?.position = newPosition
    }
    

    
    
    func moveCameraUp() {
        
        if (worldNode.position.y==0){
            return
        }
        worldNode.position = CGPoint(x:worldNode.position.x,y:worldNode.position.y-segmentY!)
        print("world: \(worldNode.position)")
    }
    
    func moveCameraDown() {
        
        if (worldNode.position.y>=(segmentY!*factorY)){
            return
        }
        worldNode.position = CGPoint(x:worldNode.position.x,y:worldNode.position.y+segmentY!)
        print("world: \(worldNode.position)")

    }
    func moveCameraLeft() {
        if (worldNode.position.x==0){
            return
        }
        worldNode.position = CGPoint(x:worldNode.position.x+segmentX!,y:worldNode.position.y)
        print("world: \(worldNode.position)")

    }
    func moveCameraRight() {
        
        if (worldNode.position.x<=(segmentX!*factorX)){
            return
        }
        
        worldNode.position = CGPoint(x:worldNode.position.x-segmentX!,y:worldNode.position.y)
        print("world: \(worldNode.position)")

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
        
        print("camera position: \(coord)")
        let xCoord = (CGFloat(coord.positionX)*CGFloat(segmentX!))*CGFloat(-1)
        let yCoord = CGFloat(coord.positionY)*segmentY!
        worldNode.position = CGPoint(x:xCoord,y:yCoord)
        self.playground?.cameraPosition = coord
    }
    
    
    func canMoveToDirection(coordinate:PlaygroundPosition, direction:PlayerMoveDirection) -> Bool {
        switch(direction) {
            case PlayerMoveDirection.UP:
                if coordinate.positionY == 0 {
                    return false
                }
                let mazeType = playground?.playgroundArray[coordinate.positionY-1][coordinate.positionX].mazeElementType
                if mazeType == MazeElementType.player_1 || mazeType == MazeElementType.player_2 || mazeType == MazeElementType.wall {
                    print("ein Hindernis at \(coordinate.positionX),\(coordinate.positionY-1): \(mazeType)")
                    print("Line:\(playground?.playgroundArray[coordinate.positionX])")
                    return false
                }
                break
            case PlayerMoveDirection.DOWN:
                if coordinate.positionY == Playground.Constants.groesseY-1 {
                    return false
                }
                let mazeType = playground?.playgroundArray[coordinate.positionY+1][coordinate.positionX].mazeElementType
                if mazeType == MazeElementType.player_1 || mazeType == MazeElementType.player_2 || mazeType == MazeElementType.wall {
                    print("ein Hindernis at \(coordinate.positionX),\(coordinate.positionY+1): \(mazeType)")
                    print("Line:\(playground?.playgroundArray[coordinate.positionX])")

                    return false
                }
                break
            case PlayerMoveDirection.LEFT:
                if coordinate.positionX == 0 {
                    return false
                }
                let mazeType = playground?.playgroundArray[coordinate.positionY][coordinate.positionX-1].mazeElementType
                if mazeType == MazeElementType.player_1 || mazeType == MazeElementType.player_2 || mazeType == MazeElementType.wall {
                    print("ein Hindernis at \(coordinate.positionX-1),\(coordinate.positionY): \(mazeType)")
                    print("Line:\(playground?.playgroundArray[coordinate.positionX-1])")

                    return false
                }
                break
            case PlayerMoveDirection.RIGHT:
                if coordinate.positionX == Playground.Constants.groesseX-1 {
                    return false
                }
                let mazeType = playground?.playgroundArray[coordinate.positionY][coordinate.positionX+1].mazeElementType
                if mazeType == MazeElementType.player_1 || mazeType == MazeElementType.player_2 || mazeType == MazeElementType.wall {
                    print("ein Hindernis at \(coordinate.positionX+1),\(coordinate.positionY): \(mazeType)")
                    print("Line:\(playground?.playgroundArray[coordinate.positionX+1])")

                    return false
                }
                break
        }
        return true
        
    }
    
    func movePlayer(direction:PlayerMoveDirection) {
        var coordinate = (self.playground?.positionPlayerTwo)!
        var playerOne = false
        if playground?.akt_spieler_ist_playerOne == true {
            playerOne = true
            coordinate = (self.playground?.positionPlayerOne)!
        }

        if canMoveToDirection(coordinate: coordinate, direction: direction) {
            let mazeType = playground?.playgroundArray[coordinate.positionY][coordinate.positionX];
            let mazeSpace = MazeType(mazeElementType: nil, sprite:nil)
            playground?.playgroundArray[coordinate.positionY][coordinate.positionX] = mazeSpace

            switch (direction) {
            case PlayerMoveDirection.DOWN:
                coordinate.positionY = coordinate.positionY + 1
                break
            case PlayerMoveDirection.UP:
                coordinate.positionY = coordinate.positionY - 1
                break
            case PlayerMoveDirection.LEFT:
                coordinate.positionX = coordinate.positionX - 1
                break
            case PlayerMoveDirection.RIGHT:
                coordinate.positionX = coordinate.positionX + 1
                break
            }
            playground?.playgroundArray[coordinate.positionY][coordinate.positionX] = mazeType!

            if playerOne==true {
                playground?.positionPlayerOne = coordinate
                drawSprite(sprite:(playground?.playerOneSprite)!,position:coordinate)
            }
            else
            {
                playground?.positionPlayerTwo = coordinate
                drawSprite(sprite:(playground?.playerTwoSprite)!,position:coordinate)
            }
        }
    }
}
