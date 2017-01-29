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
    case UP = 0,
    DOWN,
    LEFT,
    RIGHT
}

struct PlaygroundPosition {
    var x : Int
    var y : Int
    
}

class Playground: NSObject {
    
    static func up(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(x:position.x,y:position.y-1)
    }
    
    static func down(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(x:position.x,y:position.y+1)
    }
    
    static func left(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(x:position.x-1,y:position.y)
    }
    static func right(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(x:position.x+1,y:position.y)
    }
    
    static func Null() -> PlaygroundPosition {
        return PlaygroundPosition(x: 0, y: 0)
    }
    
    static func newPosition(position:PlaygroundPosition,direction:PlayerMoveDirection)->PlaygroundPosition {
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

    

    var playgroundArray : Array<Array<MazeType>> = Array()  // Das spielfeld
    var beam_from = Array<Array<Int>>() // transporter start co-ordinates
    var beam_to =   Array<Array<Int>>() // transporter target co-ordinates
    var playerOneSprite : SKSpriteNode?
    var playerTwoSprite : SKSpriteNode?
    var scene : GameScene?
    var contentAsString = ""
    var akt_spieler_ist_playerOne = true;          // =0:player 1,  1:player 2
    var ende_erreicht = false;        // =0: start
    var anzahl_spielzuege = 0                    // How many moves have you done ?
    var masken_gesamtanzahl = 0             // Number of masks available in a level
    var masken_gesammelt    = 0 //
    var invisible = false             // have you collected a 'bad mask' all walls becomes invisible
    var karten_gesammelt = 0                    // how many map parts have you collected ?
    var numberOfKilledPlayer = 0
    var next_step = 0                 // number of moves ( max. 1000)
    var names  = Array<String>()      //new String[25];                    // Die file names of the bitmaps
    var level_name: String?           // the 'official' level name (e.g. "The Decoder")
    var level_geschafft = 0           // how many level have you completed ??
    var level_number : Int = 0
    var justFinished = false
    var finished = false
    var numberOfMoves = 0
    var mapsFound = Array<MazeElementType>()
   
    
    // screen co-ordinates of the current player
    var playerPosition : PlaygroundPosition
    
    // old screen co-ordinates
    var oldPlayerPosition : PlaygroundPosition
    
    var cameraPosition : PlaygroundPosition  // the part of the playground, which should be shown: clipper 
    var positionPlayerOne : PlaygroundPosition // current and startposition of Player One
    var positionPlayerTwo : PlaygroundPosition // current and startposition of Player Two
    var replay = Array<PlaygroundPosition>()         // stores all moves to enable replay. (-1,-1) means: change Player !
    
   override func copy() -> Any {
        let playground = Playground()
        playground.playgroundArray = self.playgroundArray.map{$0}
        playground.beam_to = self.beam_to
        playground.beam_from = self.beam_from
        playground.playerOneSprite = nil
        playground.playerTwoSprite = nil
        playground.scene = self.scene
        playground.akt_spieler_ist_playerOne = self.akt_spieler_ist_playerOne
        playground.ende_erreicht = self.ende_erreicht
        playground.anzahl_spielzuege = self.anzahl_spielzuege
        playground.masken_gesammelt = self.masken_gesammelt
        playground.masken_gesamtanzahl = self.masken_gesamtanzahl
        playground.invisible = self.invisible
        playground.numberOfKilledPlayer = self.numberOfKilledPlayer
        playground.next_step = self.next_step
        playground.names = self.names
        playground.level_name = self.level_name
        playground.level_geschafft = self.level_geschafft
        playground.level_number = self.level_number
        playground.justFinished = self.justFinished
        playground.numberOfMoves = self.numberOfMoves
        playground.mapsFound = self.mapsFound
        playground.playerPosition = self.playerPosition
        playground.oldPlayerPosition = self.oldPlayerPosition
        playground.cameraPosition = self.cameraPosition
        playground.positionPlayerOne = self.positionPlayerOne
        playground.positionPlayerTwo = self.positionPlayerTwo
        playground.replay = self.replay
        playground.playerOneSprite = self.playerOneSprite
        playground.playerTwoSprite = self.playerTwoSprite
    
        return playground
    }
    
    
    
    override init() {
        self.positionPlayerOne = PlaygroundPosition(x: 0, y: 0)
        self.positionPlayerTwo = PlaygroundPosition(x: 0, y: 0)
        self.cameraPosition    = PlaygroundPosition(x: 0, y: 0)
        self.playerPosition    = PlaygroundPosition(x: -1, y: -1)
        self.oldPlayerPosition = PlaygroundPosition(x: -1, y: -1)

        super.init()

        for _ in 0..<20 {
            beam_from.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
            beam_to.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
        }
    }
    
    func changePlayer()
    {
        if numberOfKilledPlayer==0 {
            if akt_spieler_ist_playerOne {
                positionPlayerTwo = playerPosition
                playerPosition = positionPlayerOne
                akt_spieler_ist_playerOne = false
            }
            else
            {
                positionPlayerOne = playerPosition
                playerPosition = positionPlayerTwo
                akt_spieler_ist_playerOne = true
            }
            oldPlayerPosition = playerPosition
        }
    }
    
    func badMaskOperation(){
        print("invisible:\(invisible)")
        for x in 0..<PlaygroundBuilder.Constants.groesseX {
            for y in 0..<PlaygroundBuilder.Constants.groesseY {
                let mazetype = self.playgroundArray[y][x]
                if mazetype.mazeElementType==MazeElementType.wall {
                    if invisible == false {
                        mazetype.sprite?.alpha = 1.0
                    } else {
                        mazetype.sprite?.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func testChickenAcidFishBomb(){
        for x in 0..<PlaygroundBuilder.Constants.groesseX {
            for y in 0..<PlaygroundBuilder.Constants.groesseY {
                let currentPosition = PlaygroundPosition(x:x,y:y)
                let mazetype = element(position:currentPosition)
                if mazetype?.mazeElementType==MazeElementType.chicken || mazetype?.mazeElementType==MazeElementType.acid  {
                    let leftPosition = Playground.left(position: currentPosition)
                    let leftElement = element(position:leftPosition)
                    if leftElement?.mazeElementType == MazeElementType.space
                    {
                        chickenRun(position: currentPosition)
                    }
                } else
                if mazetype?.mazeElementType==MazeElementType.fish || mazetype?.mazeElementType==MazeElementType.bomb  {
                    let downPosition = Playground.down(position: currentPosition)
                    let downElement = element(position:downPosition)
                    if downElement?.mazeElementType == MazeElementType.space
                    {
                        fishFall(position: currentPosition)
                    }
                }
                
            }
        }
    }
    
    
        
    func allMasksCollected() -> Bool {
        return true ;//anzahl_masken == anzahl_gesammelter_masken
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
    
    func numberOfMovesNotExceeded() -> Bool {
        return anzahl_spielzuege <= PlaygroundBuilder.Constants.maximumMoves
    }
    
    func levelFinishedAndExitReached(item:MazeElementType?) -> Bool{
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
    
    func movePlayer(direction:PlayerMoveDirection) {
        var mazeElementType : MazeElementType?
        var newPosition : PlaygroundPosition?
        var canMoveFish = false
        var canMoveChicken = false
        scene?.animationCompleted = nil
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
            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                canMoveChicken = canMoveChickenAcidPuppetUpDown(direction:direction)
                if MazeType.canMoveUpDown(item: mazeElementType) == true || canMoveChicken
                {
                    anzahl_spielzuege += 1
                    // Alte position löschen und den View Controller updaten.
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        scene?.updateViewController!(MazeEvent.step_done)
                    }
                }
                else
                {
                    return
                }
                scene?.animationCompleted =
                {
                    element, position in
                    if canMoveChicken == true {
                        canMoveChicken = false
                        if mazeElementType == MazeElementType.puppet {
                            self.puppetMove(position: position, direction: direction)
                        }
                        else
                        {
                            self.chickenRun(position: Playground.newPosition(position: newPosition!, direction: direction))
                        }
                    
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
            
            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                canMoveFish = canMoveFishBombPuppetLeftOrRight(direction:direction)
                if  MazeType.canMoveLeftRight(item: mazeElementType) == true || canMoveFish == true
                {
                    anzahl_spielzuege += 1
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        scene?.updateViewController!(MazeEvent.step_done)
                    }
                }
                else
                {
                    return
                }
                scene?.animationCompleted =
                {
                    element, position in
                    if canMoveFish == true {
                        canMoveFish = false
                        if mazeElementType==MazeElementType.puppet {
                            self.puppetMove(position:position,direction: direction)
                        } else
                        {
                            self.fishFall(position: Playground.newPosition(position:newPosition!,direction: direction))
                        }
                    }
                }
            }
        }
        updateScene(direction:direction)
    }

    func canMoveFishBombPuppetLeftOrRight(direction:PlayerMoveDirection) -> Bool {
        if direction==PlayerMoveDirection.LEFT {
            let leftPosition = Playground.left(position: self.playerPosition)
            let leftElement = element(position: leftPosition)
            let item = leftElement?.mazeElementType
            if item == MazeElementType.fish || item == MazeElementType.bomb || item == MazeElementType.puppet {
                let leftleftPosition = Playground.left(position:leftPosition)
                let leftleftElement = element(position: leftleftPosition)
                if leftleftElement?.mazeElementType == MazeElementType.space || leftleftElement?.mazeElementType == MazeElementType.v_wave{
                    changeElement(position:leftleftPosition , element: leftElement!)
                    leftleftElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:leftPosition)
                    scene?.drawSprite(element:leftElement!, position: leftleftPosition)
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
        if direction==PlayerMoveDirection.RIGHT {
            let rightPosition = Playground.right(position: self.playerPosition)
            let rightElement = element(position: rightPosition)
            let item = rightElement?.mazeElementType
            if item == MazeElementType.fish || item == MazeElementType.bomb || item == MazeElementType.puppet {
                let rightrightPosition = Playground.right(position:rightPosition)
                let rightrightElement = element(position: rightrightPosition)
                if rightrightElement?.mazeElementType == MazeElementType.space || rightrightElement?.mazeElementType == MazeElementType.h_wave {
                    changeElement(position:rightrightPosition , element: rightElement!)
                    rightrightElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:rightPosition)
                    scene?.drawSprite(element:rightElement!, position: rightrightPosition)
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
                if upupElement?.mazeElementType == MazeElementType.space || upupElement?.mazeElementType == MazeElementType.v_wave{
                    changeElement(position:upupPosition , element: upElement!)
                    upupElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:upPosition)
                    scene?.drawSprite(element:upElement!, position: upupPosition)
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
                if downdownElement?.mazeElementType == MazeElementType.space || downdownElement?.mazeElementType == MazeElementType.v_wave {
                    changeElement(position:downdownPosition , element: downElement!)
                    downdownElement?.removeSprite()
                    createEmptySpaceOnPlayground(position:downPosition)
                    scene?.drawSprite(element:downElement!, position: downdownPosition)
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
    
    
    
    func updateScene(direction:PlayerMoveDirection){
        print("\n\n update scene\n\n")
        self.oldPlayerPosition = self.playerPosition
        // WE CAN MOVE - do the GameScene Drawing
        // old position : draw a space
        let mazeType = element(position: playerPosition)
        
        createEmptySpaceOnPlayground(position:playerPosition)
        //self.sceneShallChange!(SceneNotification.SPRITE_TO_REMOVE,position,nil,player)
        
        switch (direction) {
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
        changeElement(position: playerPosition, element: mazeType!)
        scene?.drawPlayer(position: playerPosition, player: self.akt_spieler_ist_playerOne)
        scene?.updateViewController!(MazeEvent.step_done)
        
        // CAMERA
        // we moved the player, now check if we have to move the camera
        var newCameraPosition = cameraPosition
        
        if (cameraPosition.x == (playerPosition.x) && direction==PlayerMoveDirection.LEFT) ||
            (cameraPosition.x == (oldPlayerPosition.x - 7) && direction==PlayerMoveDirection.RIGHT) {
            newCameraPosition.x = oldPlayerPosition.x - 3
        }
        else
        if (cameraPosition.y == (playerPosition.y) && direction==PlayerMoveDirection.UP) ||
            (cameraPosition.y == (playerPosition.y - 7) && direction==PlayerMoveDirection.DOWN) {
            newCameraPosition.y = playerPosition.y - 3
        }
        scene?.moveCameraToPlaygroundCoordinates(position: newCameraPosition)
        cameraPosition = newCameraPosition
        //testForChickenOrFishAction(position:position, player:player)
        print("\n\n update scene ende \n\n")
        doTheFishChickenMoving(position: oldPlayerPosition)
    } 
    
    func removeItemFromPlayground(mazeElementType:MazeElementType?,position:PlaygroundPosition) -> Bool
    {
        if let mazeelementtype = mazeElementType
        {
            if MazeType.isMap(mazeelementtype)
            {
                mapsFound.append(mazeelementtype)
                if mazeelementtype==MazeElementType.map_1 {
                    scene?.updateViewController!(MazeEvent.map1_found)
                }
                else
                if mazeelementtype==MazeElementType.map_2 {
                    scene?.updateViewController!(MazeEvent.map2_found)
                }
                else
                if mazeelementtype==MazeElementType.map_3 {
                    scene?.updateViewController!(MazeEvent.map3_found)
                }
                else
                if mazeelementtype==MazeElementType.map_4 {
                    scene?.updateViewController!(MazeEvent.map4_found)
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
                if invisible==true {
                    invisible = false
                }
                else {
                    invisible = true
                }
            }
            let mazeType = element(position:position)
            scene?.spritesToRemove.append(mazeType?.sprite)
            createEmptySpaceOnPlayground(position:position)
            scene?.updateViewController!(MazeEvent.redraw)
        }
        return false
    }
    
    func doTheFishChickenMoving(position:PlaygroundPosition)
    {
        let upFromPosition = Playground.up(position: position)
        let upElement = element(position: upFromPosition)
        if let element = upElement?.mazeElementType {
            if element == MazeElementType.fish || element == MazeElementType.bomb {
                self.fishFall(position: upFromPosition)
            }
        }
        //        if let element = downElement?.mazeElementType {
        //            if element == MazeElementType.fish || element == MazeElementType.bomb {
        //                self.fishFall(position: upFromPosition)
        //            }
        //        }
        
        let rightFromPosition = Playground.right(position: position)
        let rightElement = element(position: rightFromPosition)
        if let element = rightElement?.mazeElementType {
            if element == MazeElementType.chicken || element == MazeElementType.acid {
                self.chickenRun(position: rightFromPosition)
            }
        }
        //        if let element = leftElement?.mazeElementType {
        //            if element == MazeElementType.chicken || element == MazeElementType.acid {
        //                self.chickenRun(position: leftFromPosition)
        //            }
        //        }
    }
    
    func createEmptySpaceOnPlaygroundAndRemoveSprite(position:PlaygroundPosition)
    {
        
        print("createEmptySpaceOnPlayground Element at position: \(position)")
        print("createEmptySpaceOnPlayground maze Element type:\(element(position:position))")
        changeElementAndRemoveSprite(position: position, element: MazeType(mazeElementType: MazeElementType.space, sprite:nil))
    }
    
    
    func createEmptySpaceOnPlayground(position:PlaygroundPosition)
    {
        
        print("createEmptySpaceOnPlayground Element at position: \(position)")
        print("createEmptySpaceOnPlayground maze Element type:\(element(position:position))")
        changeElement(position: position, element: MazeType(mazeElementType: MazeElementType.space, sprite:nil))
    }
    
    func testForChickenOrFishAction(position:PlaygroundPosition)
    {
        if let mazeType = elementAboveFrom(position: position)?.mazeElementType
        {
            // ist über dem leeren Feld ein Fish/Bombe?
            // fish, bombe fällt runter von selbst
            if mazeType==MazeElementType.fish || mazeType == MazeElementType.bomb {
                fishFall(position:Playground.up(position: position))
            }
        }
        
        if let mazeType = elementRightFrom(position: position)?.mazeElementType
        {
            // chicken, acid fliegen nach links von selbst
            // puppet in jede richtung, aber nur wenn sie angeschubst werden
            if mazeType==MazeElementType.chicken || mazeType == MazeElementType.acid {
                chickenRun(position:Playground.right(position: position))
            }
        }
    }
    
    // MARK: fetch Element Methods
    
    func element(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.y][position.x]
        //print("element Element:\(a) at position : \(position)")
        return a
    }
    
    func elementLeftFrom(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.y][position.x-1]
        print("elementLeftFrom Element:\(a)")
        return a
    }
    func elementRightFrom(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.y][position.x+1]
        print("elementRightFrom Element:\(a)")
        return a
    }
    func elementAboveFrom(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.y-1][position.x]
        print("elementAboveFrom Element:\(a)")
        return a
    }
    func elementDownFrom(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.y+1][position.x]
        print("elementDownFrom Element:\(a)")
        return a
    }
    
    func changeElementAndRemoveSprite(position:PlaygroundPosition,element:MazeType) {
        let oldValue = self.element(position:position)
        if oldValue?.mazeElementType == element.mazeElementType {
            return
        }
        oldValue?.sprite?.removeFromParent()
        playgroundArray[position.y][position.x]=element
    }

    
    func changeElement(position:PlaygroundPosition,element:MazeType) {
        let oldValue = self.element(position:position)
        if oldValue?.mazeElementType == element.mazeElementType {
            return
        }
        playgroundArray[position.y][position.x]=element
    }
 
    // MARK: chicken run and fish fall methods 
    
    func chickenRun(position:PlaygroundPosition) {  // position = chicken
        // lasse das chicken so lange rennen, bis ein Hindernis da ist
        let leftposition = Playground.left(position: position)
        let chickenElement = self.element(position: position)
        let leftElement = self.element(position:leftposition)                                  // space ?
        var elementType = MazeElementType.space
        if let elementtype = leftElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.v_wave,MazeElementType.space:
            // Lösche alte Position des Huhns
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            changeElement(position: leftposition, element: chickenElement!)
            scene?.drawSprite(element:chickenElement!,position:leftposition)

            //self.sceneShallChange!(SceneNotification.DRAW_SPRITE,leftposition,chickenElement,self.akt_spieler_ist_playerOne)

            // weitermachen !
            chickenRun(position:leftposition)
            testForChickenOrFishAction(position:position)

            break
        case MazeElementType.player_1, MazeElementType.player_2:
            killCurrentPlayer(elementType)
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            leftElement?.sprite?.removeFromParent()
            changeElement(position: leftposition, element: chickenElement!)
            scene?.drawSprite(element:chickenElement!,position:leftposition)
            
            // weitermachen !
            chickenRun(position:leftposition)
            testForChickenOrFishAction(position:position)

            break
        case MazeElementType.acid:
            acidCorrosive(element:leftElement!,position:position)
            break
        case MazeElementType.bomb:
            bombExplode(element:leftElement!,position:position)
            break
        case MazeElementType.wall,MazeElementType.h_wave,MazeElementType.fish,MazeElementType.chicken,MazeElementType.puppet:
            createEmptySpaceOnPlayground(position: position)
            changeElement(position: position, element: chickenElement!)
            scene?.drawSprite(element:chickenElement!,position:position)
            
            break
        default:
            break
        }
        
    }
    
    func fishFall(position:PlaygroundPosition) {
        let bottomposition = Playground.down(position: position)
        let fishElement = self.element(position: position)
        let bottomElement = self.element(position:bottomposition)                                  // space ?
        var elementType = MazeElementType.space
        if let elementtype = bottomElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.h_wave,MazeElementType.space, MazeElementType.player_1, MazeElementType.player_2:
            // Lösche alte Position des Fishes
            createEmptySpaceOnPlayground(position: position)
            bottomElement?.removeSprite()
            // Bewege Fish um eins nach unten
            changeElement(position: bottomposition, element: fishElement!)
            scene?.drawSprite(element:fishElement!,position:bottomposition)

            //self.sceneShallChange!(SceneNotification.DRAW_PLAYER,bottomposition,nil,self.akt_spieler_ist_playerOne)

            // weitermachen !
            fishFall(position:bottomposition)
            testForChickenOrFishAction(position:position)
            if elementType==MazeElementType.player_1 || elementType==MazeElementType.player_2 {
                killCurrentPlayer(elementType)
            }
            break
        case MazeElementType.acid:
            acidCorrosive(element:bottomElement!,position:position)
            break
        case MazeElementType.bomb:
            bombExplode(element:bottomElement!,position:position)
            break
        case MazeElementType.wall,MazeElementType.v_wave,MazeElementType.fish,MazeElementType.chicken,MazeElementType.puppet:
            createEmptySpaceOnPlayground(position: position)
            changeElement(position: position, element: fishElement!)
            scene?.drawSprite(element:fishElement!,position:position)
            //self.sceneShallChange!(SceneNotification.DRAW_PLAYER,position,nil,self.akt_spieler_ist_playerOne)

            break
        default:
            break
        }
    }
    
    func puppetMove(position:PlaygroundPosition,direction:PlayerMoveDirection) {
        let newPosition  = Playground.newPosition(position: position, direction: direction)
        let puppetElement     = self.element(position: position)
        let newElement   = self.element(position:newPosition)                                  // space ?
        var elementType     = MazeElementType.space
        if let elementtype  = newElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.space:
            // Lösche alte Position des Fishes
            createEmptySpaceOnPlayground(position: position)
            newElement?.removeSprite()
            // Bewege Fish um eins nach unten
            changeElement(position: newPosition, element: puppetElement!)
            scene?.drawSprite(element:puppetElement!,position:newPosition)
            
            //self.sceneShallChange!(SceneNotification.DRAW_PLAYER,bottomposition,nil,self.akt_spieler_ist_playerOne)
            
            // weitermachen !
            puppetMove(position: newPosition, direction: direction)
            break
            
        default:
            createEmptySpaceOnPlayground(position: position)
            changeElement(position: position, element: puppetElement!)
            scene?.drawSprite(element:puppetElement!,position:position)
            //self.sceneShallChange!(SceneNotification.DRAW_PLAYER,position,nil,self.akt_spieler_ist_playerOne)
            
            break
        }
    }

    
    
    
    func killCurrentPlayer(_ elementType:MazeElementType) {
        if numberOfKilledPlayer==0 {
            numberOfKilledPlayer=1
            if elementType==MazeElementType.player_1
            {
                scene?.updateViewController!(MazeEvent.death_player1)
            }
            else
            {
                scene?.updateViewController!(MazeEvent.death_player2)
            }
            
        }
        else
        {
            numberOfKilledPlayer=2
            scene?.updateViewController!(MazeEvent.death_both)
        }
    }
    
    func bombExplode(element:MazeType,position:PlaygroundPosition) {
        if let sprite = element.sprite
        {
            
            scene?.doBombAnimation(sprite: sprite,block:{
                element.sprite?.removeFromParent()
                //                let elementAtPosition = self.element(position: position)
                //                elementAtPosition?.sprite?.removeFromParent()
                let elementDown = Playground.down(position: position)
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position) // fish
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.left(position: elementDown)) //  fish left
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.right(position: elementDown)) // fish right
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementDown) // acid
                
                
            } )
        }
    }

    
    func acidCorrosive(element:MazeType,position:PlaygroundPosition) {
        if let sprite = element.sprite
        {
            
            scene?.doAcidAnimation(sprite: sprite,block:{
                element.sprite?.removeFromParent()
//                let elementAtPosition = self.element(position: position)
//                elementAtPosition?.sprite?.removeFromParent()
                let elementLeft = Playground.left(position: position)
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position) // chicken
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.up(position: elementLeft)) //  acid up
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.down(position: elementLeft)) // acid down
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementLeft) // acid
                
                
            } )
        }
    }
    
}
