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
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
                if let sprite = spriteNode(position: PlaygroundPosition(positionX: y, positionY: x)) {
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
    
    func movePlayerDown() {
        movePlayer(direction: PlayerMoveDirection.DOWN)
    }
    
    func movePlayerUp() {
        movePlayer(direction: PlayerMoveDirection.UP)
   }
    
    func movePlayerRight() {
        movePlayer(direction: PlayerMoveDirection.RIGHT)
    }
    
    func movePlayerLeft(){
        movePlayer(direction: PlayerMoveDirection.LEFT)
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
    
    func mapFound(mazeElementType:MazeElementType,position:PlaygroundPosition) -> Bool {
        if mazeElementType == MazeElementType.map_1 ||
            mazeElementType == MazeElementType.map_2 ||
            mazeElementType == MazeElementType.map_3 ||
            mazeElementType == MazeElementType.map_4
        {
            self.playground.mapsFound.append(mazeElementType)
            let mazeType = playground.element(position: position)
            
            spriteToRemove = mazeType?.sprite //.removeFromParent()
            
            playground.changeElement(position: position,element: MazeType(mazeElementType: nil, sprite:nil))
            self.updateViewController!(mazeElementType)
            return true
        }
        else
        {
            return false
        }
    }
    
    func happyMaskFound(mazeElementType:MazeElementType,position:PlaygroundPosition) -> Bool {
        if mazeElementType == MazeElementType.mask
        {
            self.playground.anzahl_gesammelter_masken += 1
            updateViewController!(MazeElementType.step)
            let mazeType = playground.element(position: position)
            spriteToRemove = mazeType?.sprite //.removeFromParent()
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            updateViewController!(mazeElementType)
            return true
        }
        else
        {
            return false
        }
    }
    
    func badMaskFound(mazeElementType:MazeElementType,position:PlaygroundPosition) -> Bool {
        if mazeElementType == MazeElementType.bad_mask
        {
            if self.playground.invisible==true {
                self.playground.invisible = false
            }
            else {
                self.playground.invisible = false
            }
            let mazeType = playground.element(position: position)
            spriteToRemove = mazeType?.sprite //.removeFromParent()
            
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            return true
        }
        else
        {
            return false
        }
    }
    
    func checkIfWaveFound(mazeElementType:MazeElementType?,position:PlaygroundPosition) -> Bool {
        if !(mazeElementType==nil) && (mazeElementType == MazeElementType.v_wave || mazeElementType == MazeElementType.h_wave)
        {
            let mazeType = playground.element(position: position)
            spriteToRemove = mazeType?.sprite //.removeFromParent()
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            return true
        }
        else
        {
            return false
        }
    }
    
    func checkIfMapOrMaskFound(mazeElementType:MazeElementType?, position:PlaygroundPosition)
    {
        if !(mazeElementType==nil) {
            if mapFound(mazeElementType: mazeElementType!, position: position) == false
            {
                if happyMaskFound(mazeElementType: mazeElementType!, position: position) == false
                {
                    if badMaskFound(mazeElementType :mazeElementType!,position:position) == false
                    {
                    }
                }
            }
            
        }
    }
    
    
    func canMoveToDirection(coordinate:PlaygroundPosition, direction:PlayerMoveDirection) -> Bool {
        var mazeElementType : MazeElementType?
        var newPosition : PlaygroundPosition?
        
        switch(direction) {
            
            case PlayerMoveDirection.UP:
                if coordinate.positionY == 0 {
                    return false
                }
                newPosition = PlaygroundPosition(positionX:coordinate.positionX , positionY: coordinate.positionY-1)
                mazeElementType = playground.element(position: newPosition!)?.mazeElementType
                
                if mazeElementType == MazeElementType.player_1 ||
                    mazeElementType == MazeElementType.player_2 ||
                    mazeElementType == MazeElementType.wall ||
                    mazeElementType == MazeElementType.v_wave
                {
                    print("ein Hindernis at \(newPosition)")
                    return false
                }
                else
                {
                    playground.anzahl_spielzuege += 1
                    if checkIfWaveFound(mazeElementType:mazeElementType, position:newPosition!) == false {
                        checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    updateViewController!(MazeElementType.step)

                }
                break
            case PlayerMoveDirection.DOWN:
                if coordinate.positionY == Playground.Constants.groesseY-1 {
                    return false
                }
                newPosition = PlaygroundPosition(positionX:coordinate.positionX , positionY: coordinate.positionY+1)
                mazeElementType = playground.element(position: newPosition!)?.mazeElementType
                if mazeElementType == MazeElementType.player_1 ||
                    mazeElementType == MazeElementType.player_2 ||
                    mazeElementType == MazeElementType.wall ||
                    mazeElementType == MazeElementType.v_wave
                {
                    print("ein Hindernis at \(newPosition)")
                    return false
                }
                else
                {
                    playground.anzahl_spielzuege += 1

                    if checkIfWaveFound(mazeElementType: mazeElementType, position: newPosition!) == false {
                        checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    updateViewController!(MazeElementType.step)

                }
                break
            case PlayerMoveDirection.LEFT:
                if coordinate.positionX == 0 {
                    return false
                }
                newPosition = PlaygroundPosition(positionX:coordinate.positionX-1 , positionY: coordinate.positionY)
                mazeElementType = playground.element(position: newPosition!)?.mazeElementType
                
                if mazeElementType == MazeElementType.player_1 ||
                    mazeElementType == MazeElementType.player_2 ||
                    mazeElementType == MazeElementType.wall ||
                    mazeElementType == MazeElementType.h_wave
                {
                    print("ein Hindernis at \(newPosition)")

                    return false
                }
                else
                {
                    playground.anzahl_spielzuege += 1

                    if checkIfWaveFound(mazeElementType: mazeElementType, position: newPosition!) == false {
                        checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    updateViewController!(MazeElementType.step)

                }
                break
            case PlayerMoveDirection.RIGHT:
                if coordinate.positionX == Playground.Constants.groesseX-1 {
                    return false
                }
                newPosition = PlaygroundPosition(positionX:coordinate.positionX+1 , positionY: coordinate.positionY)
                mazeElementType = playground.element(position: newPosition!)?.mazeElementType
                if mazeElementType == MazeElementType.player_1 ||
                    mazeElementType == MazeElementType.player_2 ||
                    mazeElementType == MazeElementType.wall ||
                    mazeElementType == MazeElementType.h_wave
                {
                    print("ein Hindernis at \(newPosition)")
                    return false
                }
                else
                {
                    playground.anzahl_spielzuege += 1

                    if checkIfWaveFound(mazeElementType: mazeElementType, position: newPosition!) == false {
                        checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    updateViewController!(MazeElementType.step)

                }
            break
        }
        return true
        
    }
    
    
    
    func movePlayer(direction:PlayerMoveDirection) {
        let cameraCoordinate = playground.cameraPosition
        var playerCoordinate = self.playground.positionPlayerTwo
        var playerOne = false
        if playground.akt_spieler_ist_playerOne == true {
            playerOne = true
            playerCoordinate = self.playground.positionPlayerOne
        }

        if canMoveToDirection(coordinate: playerCoordinate, direction: direction) {
            // old position : draw a space
            let mazeType = playground.playgroundArray[playerCoordinate.positionY][playerCoordinate.positionX];
            let mazeSpace = MazeType(mazeElementType: nil, sprite:nil)
            playground.playgroundArray[playerCoordinate.positionY][playerCoordinate.positionX] = mazeSpace

            switch (direction) {
            case PlayerMoveDirection.DOWN:
                playerCoordinate.positionY = playerCoordinate.positionY + 1
                break
            case PlayerMoveDirection.UP:
                playerCoordinate.positionY = playerCoordinate.positionY - 1
                break
            case PlayerMoveDirection.LEFT:
                playerCoordinate.positionX = playerCoordinate.positionX - 1
                break
            case PlayerMoveDirection.RIGHT:
                playerCoordinate.positionX = playerCoordinate.positionX + 1
                break
            }
            // move player 1 to new position in the playground array
            playground.playgroundArray[playerCoordinate.positionY][playerCoordinate.positionX] = mazeType

            if playerOne==true {
                playground.positionPlayerOne = playerCoordinate
                drawSprite(sprite:(playground.playerOneSprite)!,position:playerCoordinate)

            }
            else
            {
                playground.positionPlayerTwo = playerCoordinate
                drawSprite(sprite:(playground.playerTwoSprite)!,position:playerCoordinate)
            }
            // we moved the player, now check if we have to move the camera
            var newCameraPosition = cameraCoordinate
            print("player position:\(playerCoordinate)")
            print("camera position:\(cameraCoordinate)")
            
            if (cameraCoordinate.positionX == (playerCoordinate.positionX) && direction==PlayerMoveDirection.LEFT) || (cameraCoordinate.positionX == (playerCoordinate.positionX - 7) && direction==PlayerMoveDirection.RIGHT) {
                newCameraPosition.positionX = playerCoordinate.positionX - 3
            }
            else
            if (cameraCoordinate.positionY == (playerCoordinate.positionY) && direction==PlayerMoveDirection.UP) || (cameraCoordinate.positionY == (playerCoordinate.positionY - 7) && direction==PlayerMoveDirection.DOWN) {
                newCameraPosition.positionY = playerCoordinate.positionY - 3
            }
            
            moveCameraToPlaygroundCoordinates(coordinate: newCameraPosition)
        }
    } // func movePlayer
    
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
