//
//  Playground.swift
//  iXor
//
//  Created by Mario Rotz on 08.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

enum PlayerMoveDirection  : Int {
    case
    UP = 0,
    DOWN,
    LEFT,
    RIGHT
}


struct PlaygroundPosition {
    var x : Int
    var y : Int
}

struct Beamer {
    var from : PlaygroundPosition
    var to : PlaygroundPosition
}



class Playground: NSObject {
    
    static func up(position:PlaygroundPosition)->PlaygroundPosition
    {
        return PlaygroundPosition(x:position.x,y:position.y-1)
    }
    
    static func down(position:PlaygroundPosition)->PlaygroundPosition
    {
        return PlaygroundPosition(x:position.x,y:position.y+1)
    }
    
    static func left(position:PlaygroundPosition)->PlaygroundPosition
    {
        return PlaygroundPosition(x:position.x-1,y:position.y)
    }
    static func right(position:PlaygroundPosition)->PlaygroundPosition
    {
        return PlaygroundPosition(x:position.x+1,y:position.y)
    }
    
    static func Null() -> PlaygroundPosition
    {
        return PlaygroundPosition(x: 0, y: 0)
    }
    
    static func newPosition(position:PlaygroundPosition,direction:PlayerMoveDirection)->PlaygroundPosition
    {
        switch(direction)
        {
        case PlayerMoveDirection.UP:
            return up(position: position)
        case PlayerMoveDirection.DOWN:
            return down(position: position)
        case PlayerMoveDirection.LEFT:
            return left(position: position)
        case PlayerMoveDirection.RIGHT:
            return right(position: position)
        }
    }

    static let chickenDuration = 0.1
    static let fishDuration = 0.1
    static let puppetMove = 0.1
    
    static var replay = Array<Playground>()

    var playgroundArray : Array<Array<MazeElement>> = Array()  // Das spielfeld
    var beamerArray = Array<Beamer>() // transporter start co-ordinates
    var playerOneMazeElement : MazeElement?
    var playerTwoMazeElement : MazeElement?
    var scene : GameScene?
    var contentAsString = ""
    var akt_spieler_ist_playerOne = true;          // =0:player 1,  1:player 2
    var ende_erreicht = false;        // =0: start
    var anzahl_spielzuege = 0                    // How many moves have you done ?
    var masken_gesamtanzahl = 0             // Number of masks available in a level
    var masken_gesammelt    = 0 //
    var invisible = false             // have you collected a 'bad mask' all walls becomes invisible
    var numberOfKilledPlayer = 0
    var next_step = 0                 // number of moves ( max. 1000)
    var level_name: String?           // the 'official' level name (e.g. "The Decoder")
    var level_geschafft = 0           // how many level have you completed ??
    var level_number : Int = 0
    var justFinished = false
    var finished = false
    var numberOfMoves = 0
    var mapsFound = Array<MazeElementType>()
    var eventCounter = 0
    
    var sceneExecution : ((Playground,PlaygroundPosition,MazeElement,SceneEvent,MazeEvent)->Void)?
    
    // screen co-ordinates of the current player
    var playerPosition : PlaygroundPosition
    
    // old screen co-ordinates
    var oldPlayerPosition : PlaygroundPosition
    var cameraLeftTopPosition : PlaygroundPosition  // the part of the playground, which should be shown: clipper
    var positionPlayerOne : PlaygroundPosition // current and startposition of Player One
    var positionPlayerTwo : PlaygroundPosition // current and startposition of Player Two
    
    override func copy() -> Any
    {
        let playground = Playground()
        playground.playgroundArray = self.playgroundArray.map{$0}
        for i in playgroundArray
        {
            for var j in i
            {
                j.sprite=nil
            }
        }
        playground.beamerArray = self.beamerArray
        playground.playerOneMazeElement = nil
        playground.playerTwoMazeElement = nil
        playground.scene = self.scene
        playground.akt_spieler_ist_playerOne = self.akt_spieler_ist_playerOne
        playground.ende_erreicht = self.ende_erreicht
        playground.anzahl_spielzuege = self.anzahl_spielzuege
        playground.masken_gesammelt = self.masken_gesammelt
        playground.masken_gesamtanzahl = self.masken_gesamtanzahl
        playground.invisible = self.invisible
        playground.numberOfKilledPlayer = self.numberOfKilledPlayer
        playground.next_step = self.next_step
        playground.level_name = self.level_name
        playground.level_geschafft = self.level_geschafft
        playground.level_number = self.level_number
        playground.justFinished = self.justFinished
        playground.numberOfMoves = self.numberOfMoves
        playground.mapsFound = self.mapsFound
        playground.playerPosition = self.playerPosition
        playground.oldPlayerPosition = self.oldPlayerPosition
        playground.cameraLeftTopPosition = self.cameraLeftTopPosition
        playground.positionPlayerOne = self.positionPlayerOne
        playground.positionPlayerTwo = self.positionPlayerTwo
        playground.playerOneMazeElement = self.playerOneMazeElement
        playground.playerTwoMazeElement = self.playerTwoMazeElement
    
        return playground
    }
    
    
    
    override init()
    {
        self.positionPlayerOne = Playground.Null()
        self.positionPlayerTwo = Playground.Null()
        self.cameraLeftTopPosition    = Playground.Null()
        self.playerPosition    = PlaygroundPosition(x: -1, y: -1)
        self.oldPlayerPosition = PlaygroundPosition(x: -1, y: -1)
        super.init()
    }
    
    func badMaskOperation()
    {
        print("invisible:\(invisible)")
        for x in 0..<PlaygroundBuilder.Constants.groesseX
        {
            for y in 0..<PlaygroundBuilder.Constants.groesseY
            {
                let mazetype = self.playgroundArray[y][x]
                if mazetype.mazeElementType==MazeElementType.wall
                {
                    if invisible == false
                    {
                        mazetype.sprite?.alpha = 1.0
                    }
                    else
                    {
                        mazetype.sprite?.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func testChickenAcidFishBomb()
    {
        var x=0
        var y=0
        for _ in 0..<PlaygroundBuilder.Constants.groesseX
        {
            for _ in 0..<PlaygroundBuilder.Constants.groesseY
            {
                print("testing \(x), \(y)....")
                let currentPosition = PlaygroundPosition(x:x,y:y)
                let mazetype = element(position:currentPosition)
                if mazetype?.mazeElementType==MazeElementType.chicken || mazetype?.mazeElementType==MazeElementType.acid
                {
                    let leftPosition = Playground.left(position: currentPosition)
                    let leftElement = element(position:leftPosition)
                    if leftElement?.mazeElementType == MazeElementType.space
                    {
                        x += 1
                        chickenRun(position: currentPosition,juststarted: true)
                    }
                }
                else
                if mazetype?.mazeElementType==MazeElementType.fish || mazetype?.mazeElementType==MazeElementType.bomb
                {
                    let downPosition = Playground.down(position: currentPosition)
                    let downElement = element(position:downPosition)
                    if downElement?.mazeElementType == MazeElementType.space
                    {
                        y += 1
                        fishFall(position: currentPosition,juststarted:true)
                    }
                }
                y=y+1
                if y == PlaygroundBuilder.Constants.groesseY
                {
                    break
                }
            }
            x=x+1
            y=0
            if x==PlaygroundBuilder.Constants.groesseX
            {
                break
            }
        }
    }
    
    
        
    func allMasksCollected() -> Bool
    {
        return self.masken_gesamtanzahl == self.masken_gesammelt
    }
    // fish, bombe fällt runter von selbst
    // chicken, acid fliegen nach links von selbst
    // puppet in jede richtung, aber nur wenn sie angeschubst werden
    
    func leftOrRightIsFishBombPuppet(position:PlaygroundPosition,direction:PlayerMoveDirection) -> Bool
    {
        var lposition : PlaygroundPosition?
        if direction == PlayerMoveDirection.LEFT
        {
            lposition = PlaygroundPosition(x: position.x-1, y: position.y)
        }
        else
        if direction == PlayerMoveDirection.RIGHT
        {
            lposition = PlaygroundPosition(x: position.x+1, y: position.y)
        }
        else
        {
            return false
        }
        let element = self.element(position: lposition!)
        if element?.mazeElementType == MazeElementType.fish
        {
            return true
        }
        return false
    }
    
    func upOrDownIsChickenAcidPuppet(position:PlaygroundPosition,direction:PlayerMoveDirection) -> Bool
    {
        var lposition : PlaygroundPosition?
        if direction == PlayerMoveDirection.UP
        {
            lposition = PlaygroundPosition(x: position.x, y: position.y+1)
        }
        else
        if direction == PlayerMoveDirection.DOWN
        {
            lposition = PlaygroundPosition(x: position.x, y: position.y-1)
        }
        else
        {
            return false
        }
        let element = self.element(position: lposition!)
        if element?.mazeElementType == MazeElementType.fish
        {
            return true
        }
        return false
    }
    
    func numberOfMovesNotExceeded() -> Bool
    {
        return anzahl_spielzuege <= PlaygroundBuilder.Constants.maximumMoves
    }
    
    func levelFinishedAndExitReached(item:MazeElementType?) -> Bool
    {
        if let mazeitem = item {
            if numberOfMovesNotExceeded() && allMasksCollected() && mazeitem  == MazeElementType.exit
            {
                justFinished=true
                finished = true
                return true
            }
        }
        return false
    }
    
    func movePlayer(direction:PlayerMoveDirection)
    {
        //beamMeUp()

        let previousPlayground = self.copy() as! Playground
        Playground.replay.append(previousPlayground)
        print("playground history:\(Playground.replay)")
        var canMove = true
        var mazeElementType : MazeElementType?
        var newPosition : PlaygroundPosition?
        var canMoveFish = false
        var canMoveChicken = false
        var beamed = false
        animationCompleted(function: nil)
        if direction == PlayerMoveDirection.UP  || direction == PlayerMoveDirection.DOWN
        {
            
            if direction == PlayerMoveDirection.UP && playerPosition.y > 0
            {
                newPosition = Playground.up(position: playerPosition)
            }
            else
            if direction == PlayerMoveDirection.DOWN && playerPosition.y < PlaygroundBuilder.Constants.groesseY-1
            {
                newPosition = Playground.down(position: playerPosition)
            }
            
            mazeElementType = element(position: newPosition!)?.mazeElementType
            print("Can move: \(mazeElementType)")
            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                if mazeElementType == MazeElementType.transporter
                {
                    newPosition = beamMeUp(position:playerPosition)
                    beamed = true
                    anzahl_spielzuege += 1
                }
                else
                {
                    canMoveChicken = canMoveChickenAcidPuppetUpDown(direction:direction)
                    if MazeElement.canMoveUpDown(item: mazeElementType) == true || canMoveChicken
                    {
                        anzahl_spielzuege += 1
                        // Alte position löschen und den View Controller updaten.
                        removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    else
                    {
                        canMove = false
                    }
                    if canMove == true
                    {
                        animationCompleted(function:
                            {
                                element, position in
                                if canMoveChicken == true {
                                    canMoveChicken = false
                                    if mazeElementType == MazeElementType.puppet
                                    {
                                        self.puppetMove(position: position, direction: direction)
                                    }
                                    else
                                    {
                                        self.chickenRun(position: Playground.newPosition(position: newPosition!, direction: direction),juststarted: true)
                                    }
                                }
                            })
                    }
                }
            }
        }
        else
        if direction == PlayerMoveDirection.LEFT || direction == PlayerMoveDirection.RIGHT
        {
            // calculate new position
            if direction == PlayerMoveDirection.LEFT && playerPosition.x > 0
            {
                newPosition = Playground.left(position: playerPosition)
            }
            else
            if direction == PlayerMoveDirection.RIGHT && playerPosition.x < PlaygroundBuilder.Constants.groesseX-1
            {
                newPosition = Playground.right(position: playerPosition)
            }
            
            // fetch element at new position
            mazeElementType = element(position: newPosition!)?.mazeElementType
            print("Can move: \(mazeElementType)")

            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                if mazeElementType == MazeElementType.transporter
                {
                    beamed=true
                    newPosition = beamMeUp(position:playerPosition)
                    anzahl_spielzuege += 1
                }
                else
                {
                    canMoveFish = canMoveFishBombPuppetLeftOrRight(direction:direction)
                    if  MazeElement.canMoveLeftRight(item: mazeElementType) == true || canMoveFish == true
                    {
                        anzahl_spielzuege += 1
                        removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    }
                    else
                    {
                        canMove = false
                    }
                }
                if canMove == true
                {
                    animationCompleted(function:
                        {
                            element, position in
                            if canMoveFish == true
                            {
                                canMoveFish = false
                                if mazeElementType==MazeElementType.puppet
                                {
                                    self.puppetMove(position:position,direction: direction)
                                }
                                else
                                {
                                    self.fishFall(position: Playground.newPosition(position:newPosition!,direction: direction),juststarted:true)
                                }
                            }
                        })
                }
            }
        }
        if canMove == true
        {
            movePlayerToNewPositionAndUpdateScene(direction:direction,currentPosition:playerPosition,newPosition:newPosition,beamed:beamed)
        }
        else
        {
            Playground.replay.removeLast(1)

        }
    }

    func canMoveFishBombPuppetLeftOrRight(direction:PlayerMoveDirection) -> Bool
    {
        if direction==PlayerMoveDirection.LEFT
        {
            let leftPosition = Playground.left(position: self.playerPosition)
            let leftElement = element(position: leftPosition)
            let item = leftElement?.mazeElementType
            if item == MazeElementType.fish || item == MazeElementType.bomb || item == MazeElementType.puppet
            {
                let leftleftPosition = Playground.left(position:leftPosition)
                let leftleftElement = element(position: leftleftPosition)
                if leftleftElement?.mazeElementType == MazeElementType.space || leftleftElement?.mazeElementType == MazeElementType.v_wave
                {
                    leftleftElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:leftPosition)
                    changeElementAndDrawSprite(position: leftleftPosition, element: leftElement!, duration: 0.25, completition: nil)
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        else
        if direction==PlayerMoveDirection.RIGHT
        {
            let rightPosition = Playground.right(position: self.playerPosition)
            let rightElement = element(position: rightPosition)
            let item = rightElement?.mazeElementType
            if item == MazeElementType.fish || item == MazeElementType.bomb || item == MazeElementType.puppet
            {
                let rightrightPosition = Playground.right(position:rightPosition)
                let rightrightElement = element(position: rightrightPosition)
                if rightrightElement?.mazeElementType == MazeElementType.space || rightrightElement?.mazeElementType == MazeElementType.h_wave {
                    rightrightElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:rightPosition)
                    
                    changeElementAndDrawSprite(position: rightrightPosition,
                                               element: rightElement!,
                                               duration: 0.25,
                                               completition: nil)
                    
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        return true
    }
    
    func canMoveChickenAcidPuppetUpDown(direction:PlayerMoveDirection) -> Bool {
        if direction==PlayerMoveDirection.UP {
            let upPosition = Playground.up(position: self.playerPosition)
            let upElement = element(position: upPosition)
            let item = upElement?.mazeElementType
            if item == MazeElementType.chicken || item == MazeElementType.acid || item == MazeElementType.puppet {
                let upupPosition = Playground.up(position:upPosition)
                let upupElement = element(position: upupPosition)
                if upupElement?.mazeElementType == MazeElementType.space || upupElement?.mazeElementType == MazeElementType.h_wave{
                    upupElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:upPosition)
                    
                    changeElementAndDrawSprite(position: upupPosition,
                                               element: upElement!,
                                               duration: 0.25,
                                               completition: nil)
                    
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        } else
        if direction==PlayerMoveDirection.DOWN {
            let downPosition = Playground.down(position: self.playerPosition)
            let downElement = element(position: downPosition)
            let item = downElement?.mazeElementType
            if item == MazeElementType.chicken || item == MazeElementType.acid || item == MazeElementType.puppet {
                let downdownPosition = Playground.down(position:downPosition)
                let downdownElement = element(position: downdownPosition)
                if downdownElement?.mazeElementType == MazeElementType.space || downdownElement?.mazeElementType == MazeElementType.h_wave {
                    downdownElement?.removeSprite()
                    
                    createEmptySpaceOnPlayground(position:downPosition)
                    
                    changeElementAndDrawSprite(position: downdownPosition,
                                               element: downElement!,
                                               duration: 0.25,
                                               completition: nil)
                    
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        return true
    }
    
    
    
    func movePlayerToNewPositionAndUpdateScene(direction:PlayerMoveDirection,currentPosition:PlaygroundPosition,newPosition:PlaygroundPosition?,beamed:Bool)
    {
        print("\n\n update scene\n\n")
        
        
        self.oldPlayerPosition = self.playerPosition
        
        // beamer ?
        
         // WE CAN MOVE - do the GameScene Drawing
        // old position : draw a space
        let mazeType = element(position: playerPosition)
        
        createEmptySpaceOnPlayground(position:playerPosition)
        
        if let position = newPosition
        {
            playerPosition = position
        }
        else
        {
            switch (direction)
            {
            case PlayerMoveDirection.DOWN:
                playerPosition.y = oldPlayerPosition.y + 1
                break
            case PlayerMoveDirection.UP:
                playerPosition.y = oldPlayerPosition.y - 1
                break
            case PlayerMoveDirection.LEFT:
                playerPosition.x = oldPlayerPosition.x - 1
                break
            case PlayerMoveDirection.RIGHT:
                playerPosition.x = oldPlayerPosition.x + 1
                break
            }
            // move player 1 to new position in the playground array
        }
        
        changeElement(position: playerPosition, element: mazeType!)
        
        drawPlayer(position: playerPosition, previousPosition: oldPlayerPosition, player: self.akt_spieler_ist_playerOne, beamed:beamed, completition:
            {
                self.doTheFishChickenMoving(position: self.oldPlayerPosition)

            }
        )
        
        updateViewController(event:MazeEvent.step_done)
        if beamed==true
        {
            moveCameraToPlaygroundCoordinates(position:PlaygroundPosition(x:playerPosition.x-3,y:playerPosition.y-3))
        }
        else
        {
            self.updateCameraPosition(direction)
        }
    }
    
    func updateCameraPosition(_ direction:PlayerMoveDirection)
    {
        // CAMERA
        // we moved the player, now check if we have to move the camera
        var newCameraPosition = cameraLeftTopPosition
        
        if (cameraLeftTopPosition.x == playerPosition.x && direction==PlayerMoveDirection.LEFT) ||
            (cameraLeftTopPosition.x == (oldPlayerPosition.x - 7) && direction==PlayerMoveDirection.RIGHT)
        {
            newCameraPosition.x = oldPlayerPosition.x - 3
        }
        else
        if (cameraLeftTopPosition.y == (playerPosition.y) && direction==PlayerMoveDirection.UP) ||
            (cameraLeftTopPosition.y == (playerPosition.y - 7) && direction==PlayerMoveDirection.DOWN)
        {
                newCameraPosition.y = playerPosition.y - 3
        }
        moveCameraToPlaygroundCoordinates(position: newCameraPosition)
        cameraLeftTopPosition = newCameraPosition
        print("\n\n update scene ende \n\n")
        
    }
    
    func removeItemFromPlayground(mazeElementType:MazeElementType?,position:PlaygroundPosition)
    {
        if let mazeelementtype = mazeElementType
        {
            if MazeElement.isMap(mazeelementtype)
            {
                mapsFound.append(mazeelementtype)
                if mazeelementtype==MazeElementType.map_1
                {
                    updateViewController(event:MazeEvent.map1_found)
                }
                else
                if mazeelementtype==MazeElementType.map_2
                {
                    updateViewController(event:MazeEvent.map2_found)
                }
                else
                if mazeelementtype==MazeElementType.map_3
                {
                    updateViewController(event:MazeEvent.map3_found)
                }
                else
                if mazeelementtype==MazeElementType.map_4
                {
                    updateViewController(event:MazeEvent.map4_found)
                }
                
                
            }
            else
            if mazeelementtype == MazeElementType.mask
            {
                masken_gesammelt += 1
            }
            else
            if mazeElementType == MazeElementType.bad_mask
            {
                if invisible==true
                {
                    invisible = false
                }
                else
                {
                    invisible = true
                }
                updateViewController(event:MazeEvent.bad_mask_found)
            }
            let mazeType = element(position:position)
            spritesToRemove(mazeType!)
            createEmptySpaceOnPlayground(position:position)
            updateViewController(event:MazeEvent.redraw)
        }
    }
    
    func doTheFishChickenMoving(position:PlaygroundPosition)
    {
        let upFromPosition = Playground.up(position: position)
        let upElement = element(position: upFromPosition)
        if let element = upElement?.mazeElementType
        {
            if element == MazeElementType.fish || element == MazeElementType.bomb
            {
                self.fishFall(position: upFromPosition,juststarted: true)
            }
        }
        
        let rightFromPosition = Playground.right(position: position)
        let rightElement = element(position: rightFromPosition)
        if let element = rightElement?.mazeElementType {
            if element == MazeElementType.chicken || element == MazeElementType.acid {
                self.chickenRun(position: rightFromPosition,juststarted: true)
            }
        }
    }
    
    func createEmptySpaceOnPlaygroundAndRemoveSprite(position:PlaygroundPosition,duration:TimeInterval)
    {
        
        //print("createEmptySpaceOnPlayground Element at position: \(position)")
        //print("createEmptySpaceOnPlayground maze Element type:\(element(position:position))")
        if (element(position: position)?.mazeElementType==MazeElementType.bomb) {
            print("removed bomb")
        }
        changeElementAndRemoveSprite(position: position, element: MazeElement(mazeElementType: MazeElementType.space, sprite:nil),duration:duration)
    }
    
    
    func createEmptySpaceOnPlayground(position:PlaygroundPosition)
    {
        
        //print("createEmptySpaceOnPlayground Element at position: \(position)")
        //print("createEmptySpaceOnPlayground maze Element type:\(element(position:position))")
        changeElement(position: position, element: MazeElement(mazeElementType: MazeElementType.space, sprite:nil))
    }
    
    func testForChickenOrFishAction(position:PlaygroundPosition)
    {
        if let mazeType = elementAboveFrom(position: position)?.mazeElementType
        {
            // ist über dem leeren Feld ein Fish/Bombe?
            // fish, bombe fällt runter von selbst
            if mazeType==MazeElementType.fish || mazeType == MazeElementType.bomb
            {
                fishFall(position:Playground.up(position: position),juststarted: false)
            }
        }
        
        if let mazeType = elementRightFrom(position: position)?.mazeElementType
        {
            // chicken, acid fliegen nach links von selbst
            // puppet in jede richtung, aber nur wenn sie angeschubst werden
            if mazeType==MazeElementType.chicken || mazeType == MazeElementType.acid
            {
                chickenRun(position:Playground.right(position: position),juststarted: false)
            }
        }
    }
    
    // MARK: fetch Element Methods
    
    func element(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y][position.x]
        //print("element Element:\(a) at position : \(position)")
        return a
    }
    
    func elementLeftFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y][position.x-1]
        print("elementLeftFrom Element:\(a)")
        return a
    }
    func elementRightFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y][position.x+1]
        print("elementRightFrom Element:\(a)")
        return a
    }
    func elementAboveFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y-1][position.x]
        print("elementAboveFrom Element:\(a)")
        return a
    }
    func elementDownFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y+1][position.x]
        print("elementDownFrom Element:\(a)")
        return a
    }
    
    // MARK: Change Element 
    
    
    func changeElementAndRemoveSprite(position:PlaygroundPosition,element:MazeElement,duration:TimeInterval) {
        let oldValue = self.element(position:position)
        if oldValue?.mazeElementType == element.mazeElementType
        {
            return
        }
        oldValue?.removeSprite()
        playgroundArray[position.y][position.x]=element
    }
    
    
    func changeElement(position:PlaygroundPosition,element:MazeElement)
    {
        let oldValue = self.element(position:position)
        if oldValue?.mazeElementType == element.mazeElementType
        {
            return
        }
        playgroundArray[position.y][position.x]=element
    }
    
    func changeElementAndDrawSprite(position:PlaygroundPosition,
                                    element:MazeElement,duration:TimeInterval,
                                    completition:(()->Void)?)
    {
        // remove sprite at old position
        if let sprite = self.element(position:position)
        {
            sprite.removeSprite()
        }
        changeElement(position: position, element: element)
        
        drawSprite(element:element,
                          position:position,
                          duration:Playground.chickenDuration,
                          completed:completition)

    }
    
 
    // MARK: chicken run and fish fall methods
    
    func chickenRun(position:PlaygroundPosition,juststarted:Bool)
    {  // position = chicken
        
        increaseEventCounter(comment: "chickenRun",element:MazeElementType.chicken)
        
        // lasse das chicken so lange rennen, bis ein Hindernis da ist
        let leftposition = Playground.left(position: position)
        let chickenElement = self.element(position: position)
        let leftElement = self.element(position:leftposition)                                  // space ?
        var elementType = MazeElementType.space
        if let elementtype = leftElement?.mazeElementType
        {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.v_wave,MazeElementType.space:
            // Lösche alte Position des Huhns
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            
            changeElementAndDrawSprite(position: leftposition,
                                       element: chickenElement!,
                                       duration: Playground.chickenDuration,
                                       completition: {
                    self.chickenRun(position:leftposition,juststarted: false)
                    self.testForChickenOrFishAction(position:position)
                    self.decreaseEventCounter(comment: "chicken run exit", element: MazeElementType.chicken)
            })
            
            
            
            //self.sceneShallChange!(SceneNotification.DRAW_SPRITE,leftposition,chickenElement,self.akt_spieler_ist_playerOne)

            // weitermachen !
            //chickenRun(position:leftposition)
            //testForChickenOrFishAction(position:position)
            return
        case MazeElementType.player_1, MazeElementType.player_2:
            if juststarted==false
            {
                killCurrentPlayer(elementType)
                createEmptySpaceOnPlayground(position: position)
                // Bewege Huhn um eins nach links
                leftElement?.sprite?.removeFromParent()
                changeElement(position: leftposition, element: chickenElement!)
                drawSprite(element:chickenElement!,position:leftposition,duration:Playground.chickenDuration,completed:{
                    // weitermachen !
                    self.chickenRun(position:leftposition,juststarted: false)
                    self.testForChickenOrFishAction(position:position)
                })
            }
            else
            {
                createEmptySpaceOnPlayground(position: position)
                changeElementAndDrawSprite(position: position, element: chickenElement!, duration: Playground.chickenDuration, completition: {
                    self.decreaseEventCounter(comment:"chicken run player killed",element: MazeElementType.chicken)
                })
                
            }
            break
        case MazeElementType.acid:
            if juststarted==false {
                acidCorrosive(element:leftElement!,position:position,causedBy: MazeElementType.chicken)
            }
            break
        case MazeElementType.bomb:
            if juststarted==false {
                bombExplode(element:leftElement!,position:position,causedBy: MazeElementType.chicken)
            }
            break
        case MazeElementType.wall,MazeElementType.h_wave,MazeElementType.fish,MazeElementType.chicken,MazeElementType.puppet:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: position, element: chickenElement!, duration: Playground.chickenDuration, completition: {
                self.decreaseEventCounter(comment: "chicken run another element",element: MazeElementType.chicken)
            })
            return
        default:
            self.decreaseEventCounter(comment:"chicken run exit",element: MazeElementType.chicken)
            return
        }
        
    }
    
    func increaseEventCounter(comment:String,element:MazeElementType)
    {
        self.eventCounter = self.eventCounter + 1
        print(" events up at \(comment): \(self.eventCounter)")
    }
    
    func decreaseEventCounter(comment:String,element:MazeElementType)
    {
        self.eventCounter = self.eventCounter - 1
        if self.eventCounter==0
        {
            print("All  Events done!")
            return
        }
        assert(self.eventCounter>=0,"event counter must be nonnegative ")
        print(" events down at \(comment): \(self.eventCounter)")
    }
    
    
    func fishFall(position:PlaygroundPosition,juststarted:Bool)
    {
        increaseEventCounter(comment: "fishFall",element: MazeElementType.fish)
        let bottomposition = Playground.down(position: position)
        let fishOrBombElement = self.element(position: position)
        
        
        print("\n\nfish element:\(fishOrBombElement?.mazeElementType) at position \(position)")
        
        let bottomElement = self.element(position:bottomposition)                                  // space ?
        
        print("\n\nbottom element:\(bottomElement?.mazeElementType) at position \(bottomposition)")
        
        var elementType = MazeElementType.space
        if let elementtype = bottomElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.h_wave,MazeElementType.space, MazeElementType.player_1, MazeElementType.player_2:
            if juststarted==true && (elementType==MazeElementType.player_1 || elementType == MazeElementType.player_2) {
                createEmptySpaceOnPlayground(position: position)
                changeElementAndDrawSprite(position: position, element: fishOrBombElement!, duration: Playground.fishDuration, completition: nil)
            }
            else
            {
                // Lösche alte Position des Fishes
                createEmptySpaceOnPlayground(position: position)
                bottomElement?.removeSprite()
                // Bewege Fish um eins nach unten
            
                changeElementAndDrawSprite(position: bottomposition,
                                           element: fishOrBombElement!,
                                           duration: Playground.fishDuration,
                                           completition: {
                                                // weitermachen !
                                            

                                                print("\n\nfish element:\(fishOrBombElement?.mazeElementType) at position \(position)")
                                            
                                            
                                                print("\n\nbottom element:\(bottomElement?.mazeElementType) at position \(bottomposition)")
                                            
                                            
                                            
                                                self.fishFall(position:bottomposition,juststarted: false)
                                                self.testForChickenOrFishAction(position:position)
                                                if elementType==MazeElementType.player_1 || elementType==MazeElementType.player_2 {
                                                    self.killCurrentPlayer(elementType)
                                                }
                                                self.decreaseEventCounter(comment:"move fish down",element: MazeElementType.fish)
                })
            }
            return
            
        case MazeElementType.acid:
            acidCorrosive(element:bottomElement!,position:position,causedBy:MazeElementType.fish)
            return
        
        case MazeElementType.bomb:
            bombExplode(element:bottomElement!,position:position,causedBy:MazeElementType.fish)
            return
            
        case MazeElementType.wall,
             MazeElementType.v_wave,
             MazeElementType.fish,
             MazeElementType.chicken,
             MazeElementType.puppet,
             MazeElementType.bad_mask,
             MazeElementType.mask:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: position, element: fishOrBombElement!, duration: Playground.fishDuration, completition: {
                self.decreaseEventCounter(comment: "fish fall continue falling",element: MazeElementType.fish)
            })
            return
        default:
            decreaseEventCounter(comment: "fish fall done",element: MazeElementType.fish)
            return
        }
    }
    
    func puppetMove(position:PlaygroundPosition,direction:PlayerMoveDirection)
    {
        self.increaseEventCounter(comment: "puppet moving", element:MazeElementType.puppet)
        let newPosition  = Playground.newPosition(position: position, direction: direction)
        let puppetElement     = self.element(position: position)
        let newElement   = self.element(position:newPosition)                                  // space ?
        var elementType     = MazeElementType.space
        if let elementtype  = newElement?.mazeElementType
        {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.space:
            // Lösche alte Position des Fishes
            createEmptySpaceOnPlayground(position: position)
            newElement?.removeSprite()
            // Bewege Fish um eins nach unten
            changeElementAndDrawSprite(position: newPosition,
                                       element: puppetElement!,
                                       duration: Playground.puppetMove,
                                       completition: nil)
            
            puppetMove(position: newPosition, direction: direction)
            return
            
        default:
            createEmptySpaceOnPlayground(position: position)
            
            changeElementAndDrawSprite(position: position, element: puppetElement!, duration: Playground.puppetMove, completition: {
            self.decreaseEventCounter(comment: "puppet done", element: MazeElementType.puppet)})
            return
        }
    }
    
    func killCurrentPlayer(_ elementType:MazeElementType)
    {
        if numberOfKilledPlayer==0
        {
            numberOfKilledPlayer=1
            if elementType==MazeElementType.player_1
            {
                updateViewController(event:MazeEvent.death_player1)
            }
            else
            {
                updateViewController(event:MazeEvent.death_player2)
            }
            
        }
        else
        {
            numberOfKilledPlayer=2
            updateViewController(event:MazeEvent.death_both)
        }
    }
    
    func beamMeUp(position:PlaygroundPosition?) -> PlaygroundPosition?
    {
        //let i=0,q=0
        if let thePosition = position
        {
            for x in 0..<beamerArray.count
            {
                let beampos = beamerArray[x]
                if beampos.from.x == thePosition.x && beampos.from.y == thePosition.y
                {
                    return beampos.to
                }
            }
        }
        return nil
    }
    
    func bombExplode(element:MazeElement,position:PlaygroundPosition,causedBy:MazeElementType)
    {
        if let _ = element.sprite
        {
            if causedBy==MazeElementType.fish || causedBy == MazeElementType.bomb
            {
                let positionDown = Playground.down(position: position) // here is the bomb!
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // fish
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.left(position: positionDown),duration:0.9) //  fish left
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.right(position: positionDown),duration:0.9) // fish right
                self.testForChickenOrFishAction(position: Playground.left(position: positionDown))
                self.testForChickenOrFishAction(position: Playground.right(position: positionDown))
                self.createEmptySpaceOnPlayground(position: positionDown)
                
                playSoundBomb()
                doBombAnimation(element: element,block:{
                    element.removeSprite(duration: 0.0)
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: positionDown,duration:0.0) // bomb
                    self.decreaseEventCounter(comment:"bomb exploded",element: causedBy)
                    self.testForChickenOrFishAction(position: positionDown)
                    
                } )
            }
            else
            {   // chicken or acid 
                let positionLeft = Playground.left(position: position) // position bomb
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // bomb
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.left(position: positionLeft),duration:0.9) //  bomb left
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.right(position: positionLeft),duration:0.9) // bomb right
                self.testForChickenOrFishAction(position: Playground.left(position: positionLeft))
                self.testForChickenOrFishAction(position: Playground.right(position: positionLeft))
                self.createEmptySpaceOnPlayground(position: positionLeft)
                playSoundBomb()
                doBombAnimation(element:element,block:{
                    element.sprite?.removeFromParent()
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: positionLeft,duration:0.0) // bomb
                    self.decreaseEventCounter(comment:"bomb exploded",element: causedBy)
                    self.testForChickenOrFishAction(position: positionLeft)
                    
                } )
                
            }
        }
    }

    func acidCorrosive(element:MazeElement,position:PlaygroundPosition,causedBy:MazeElementType)
    {
        if let _ = element.sprite
        {
            if causedBy==MazeElementType.chicken || causedBy == MazeElementType.acid
            {
                let elementLeft = Playground.left(position: position)
                playSoundAcid()
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // chicken/acid
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.up(position: elementLeft),duration:0.9) //  acid up
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.down(position: elementLeft),duration:0.9) // acid down
                doAcidAnimation(element: element,block:{
                    element.removeSprite(duration: 0.0)
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementLeft,duration:0.0) // acid
                    self.decreaseEventCounter(comment:"acid corrosive",element: causedBy)
                    self.testForChickenOrFishAction(position: Playground.up(position: elementLeft))
                    self.testForChickenOrFishAction(position: position)
                    self.testForChickenOrFishAction(position: Playground.down(position: elementLeft))
                    
                })
            }
            else
            {
                let elementFishAboveAcid = Playground.up(position: position)
                let elementDownFromAcid = Playground.down(position: Playground.down(position: position))
                playSoundAcid()
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // fish/bomb
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementDownFromAcid,duration:0.9) //  acid down
                self.testForChickenOrFishAction(position: position)
                self.testForChickenOrFishAction(position: elementDownFromAcid)

                doAcidAnimation(element: element,block:{
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.down(position: position),duration:0.0)
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementFishAboveAcid,duration:0.0) // acid
                    self.decreaseEventCounter(comment:"acid corrosive",element:causedBy)
                    self.testForChickenOrFishAction(position: Playground.down(position: position))
                    self.testForChickenOrFishAction(position: elementFishAboveAcid)
                })
                
            }
        }
    }
    
    // MARK: Scenes
    
    func updateViewController(event:MazeEvent)
    {
        scene?.updateViewController!(event)
    }
    
    func playSoundAcid() {
        scene?.run(SKAction.playSoundFileNamed("acid.wav" ,waitForCompletion:false))

    }
    
    func playSoundBomb() {
        scene?.run(SKAction.playSoundFileNamed("bomb.caf" ,waitForCompletion:false))

    }
    
    func doAcidAnimation(element:MazeElement,block:@escaping ()->())
    {
        if let sprite = element.sprite
        {
            scene?.doAcidAnimation(sprite: sprite,block:block)
        }
    }
    func doBombAnimation(element:MazeElement,block:@escaping ()->())
    {
        if let sprite = element.sprite
        {
            scene?.doBombAnimation(sprite: sprite,block:block)
        }
    }
    
    func drawPlayer(position: PlaygroundPosition, previousPosition:PlaygroundPosition, player: Bool, beamed:Bool,completition:@escaping ()->())
    {
        scene?.drawPlayer(position: playerPosition, previousPosition:previousPosition, beamed:beamed, completition:completition)
    }
    
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition)
    {
        scene?.moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func drawSprite(element:MazeElement,
                         position:PlaygroundPosition,
                         duration:TimeInterval,
                         completed:(()->Void)?)
    {
        scene?.drawSprite(element:element,
                     position:position,
                     duration:duration,
                     completed:completed)
    }
    
    func spritesToRemove(_ element:MazeElement)
    {
        scene?.spritesToRemove.append(element.sprite)
    }
    
    func animationCompleted(function: ((MazeElement,PlaygroundPosition)->Void)?)
    {
        scene?.animationCompleted=function
    }

}
