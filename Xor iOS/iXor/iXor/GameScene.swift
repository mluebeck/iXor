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
    let worldNode : SKNode = SKNode()

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
                    
                    //)sprite.position = CGPoint(x: CGFloat(x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(y)*segmentY!-segmentY!/2.0)
                }
            }
        }
        //moveCameraToPlaygroundCoordinates(coordinate:(playground.positionPlayerOne))

        switchToPlayerOne()
    }
    
    func drawSprite(sprite:SKSpriteNode ,position:PlaygroundPosition) {
        sprite.position = CGPoint(x: CGFloat(position.positionX)*segmentX!+segmentX!/2.0,
                                  y: self.size.height - CGFloat(position.positionY)*segmentY!-segmentY!/2.0)
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
        //let position = playground.playerOneSprite?.position
        //playground.playerOneSprite?.position = CGPoint(x:(position?.x)!,y:(position?.y)!-segmentY!)
    }
    
    func movePlayerUp() {
        movePlayer(direction: PlayerMoveDirection.UP)

        //let position = playground.playerOneSprite?.position
        //playground.playerOneSprite?.position = CGPoint(x:(position?.x)!,y:(position?.y)!+segmentY!)
    }
    
    func movePlayerRight() {
        movePlayer(direction: PlayerMoveDirection.RIGHT)

        //let position = playground.playerOneSprite?.position
        //playground.playerOneSprite?.position = CGPoint(x:(position?.x)!+segmentX!,y:(position?.y)!)
    }
    
    func movePlayerLeft(){
        movePlayer(direction: PlayerMoveDirection.LEFT)

        //let position = playground.playerOneSprite?.position
        //let newPosition = CGPoint(x:(position?.x)!-segmentX!,y:(position?.y)!)
        //playground.playerOneSprite?.position = newPosition
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
            mazeType?.sprite?.removeFromParent()
            playground.changeElement(position: position,element: MazeType(mazeElementType: nil, sprite:nil))
            //TODO update Maze View
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
            mazeType?.sprite?.removeFromParent()
            
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            //TODO update Maze View
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
            mazeType?.sprite?.removeFromParent()
            
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            //TODO update Maze View
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
            mazeType?.sprite?.removeFromParent()
            playground.changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            //TODO update Maze View
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
    
}
