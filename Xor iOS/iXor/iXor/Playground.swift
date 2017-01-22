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

struct MazeType {
    var mazeElementType : MazeElementType?
    var sprite : SKSpriteNode?
    
    func removeSprite() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        sprite?.run(fadeOut, completion: {
            self.sprite?.removeFromParent()
        })
     }
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
    
 
    
    static var currentPlaygroundLevel = 1

    var playgroundArray : Array<Array<MazeType>> = Array()  // Das spielfeld
    
    var beam_from = Array<Array<Int>>() // transporter start co-ordinates
    var beam_to =   Array<Array<Int>>() // transporter target co-ordinates
    
    var playerOneSprite : SKSpriteNode?
    var playerTwoSprite : SKSpriteNode?
    
    var scene : GameScene?
    
    var nothing_loaded = true         // =1:show start level, else greeting screen
    var karten_flag = false;          // =1: a map has been collected, so update the status display
    var akt_spieler_ist_playerOne = true;          // =0:player 1,  1:player 2
    var ende_erreicht = false;        // =0: start
    // =1: all masks collected !
    // =99: one player is dead and one has just been killed
    //      OR >1000 moves: You failed !
    // =98: one player is dead and the other alive
    var anzahl_spielzuege = 0                    // How many moves have you done ?
    var anzahl_masken = 0             // Number of masks available in a level
    var anzahl_gesammelter_masken = 0 //
    var invisible = false             // have you collected a 'bad mask' all walls becomes invisible
    var karten = 0                    // how many map parts have you collected ?
    var map_flag = false              // =1: show map and not the playground
    var masken_gefunden = false       // you have found a mask
    var playerKilled = false         // false: 2 Spieler übrig, true : 1 Spieler übrig
    var next_step = 0                 // number of moves ( max. 1000)
    //var spieler = Array<Array<Int>>() //new byte[2][2];                // spieler[0][0]: 1. player, Pos. X, spieler[0][1] : Y
    //playgroundArray : var spielfeld = Array<Array<Int>>() //= new byte[32][32];              // the playground
    var names  = Array<String>()      //new String[25];                    // Die file names of the bitmaps
    //var level = ""                  // the level file name(e.g. level01.xor)

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

/*
    Image sprites[]  = new Image[25];                  // all images
    Image bomben[][] = new Image[8][3];                // bomb explosion animation
    Image acid[][]   = new Image[8][3];                // acid corrosion animation
    public Image play_buffer;                          // the playground image
    public Graphics graph_offline,graph_online;        // these objects connects the playground with the window
    Frame frame;                                       // the frame where the playground will be shown
    MediaTracker mtracker;                             // Observer for all loaded images
*/
    
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
        if !playerKilled {
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
                if MazeElement.canMoveUpDown(item: mazeElementType) == true || canMoveChicken
                {
                    anzahl_spielzuege += 1
                    // Alte position löschen und den View Controller updaten.
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        scene?.updateViewController!(MazeElementType.step)
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
                        if direction == PlayerMoveDirection.UP {
                            self.chickenRun(position: Playground.up(position:newPosition!))
                        }
                        else
                        if direction == PlayerMoveDirection.DOWN {
                            self.chickenRun(position: Playground.down(position:newPosition!))
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
                if  MazeElement.canMoveLeftRight(item: mazeElementType) == true || canMoveFish == true
                {
                    anzahl_spielzuege += 1
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        scene?.updateViewController!(MazeElementType.step)
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
                        if direction == PlayerMoveDirection.LEFT {
                            self.fishFall(position: Playground.left(position:newPosition!))
                        }
                        else
                            if direction == PlayerMoveDirection.RIGHT {
                                self.fishFall(position: Playground.right(position:newPosition!))
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
        scene?.updateViewController!(MazeElementType.step)
        
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
            if MazeElement.isMap(mazeelementtype)
            {
                mapsFound.append(mazeelementtype)
            }
            else
            if mazeelementtype == MazeElementType.mask
            {
                anzahl_gesammelter_masken += 1
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
            scene?.updateViewController!(mazeElementType!)
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
            killCurrentPlayer()
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            changeElement(position: leftposition, element: leftElement!)
            scene?.drawSprite(element:leftElement!,position:leftposition)
            
            // weitermachen !
            chickenRun(position:leftposition)
            testForChickenOrFishAction(position:position)

            break
        case MazeElementType.acid:
            acidCorrosive()
            break
        case MazeElementType.bomb:
            bombExplode()
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
                killCurrentPlayer()
            }
            break
        case MazeElementType.acid:
            acidCorrosive()
            break
        case MazeElementType.bomb:
            bombExplode()
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
    
    func killCurrentPlayer() {
        if playerKilled==false {
            playerKilled=true
            scene?.updateViewController!(MazeElementType.death)
        }
        else {
            scene?.updateViewController!(MazeElementType.death_both)
        }
    }
    
    func bombExplode() {
        
        
    }
    
    func acidCorrosive() {
        
    }
    
}
