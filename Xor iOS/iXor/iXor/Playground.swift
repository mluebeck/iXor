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
    RIGHT,
    PLAYERCHANGED,
    NONE
}


class PlaygroundPosition : NSObject,NSCoding {
    
    override public var description: String {
        return "(\(x),\(y))"
    }
    
    init(x:Int,y:Int) {
        self.x=x
        self.y=y
    }
    
    override var hashValue: Int {
        return x.hashValue ^ y.hashValue*32
    }

    
    /*var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
    */
    static func == (lhs: PlaygroundPosition, rhs: PlaygroundPosition) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func != (lhs: PlaygroundPosition, rhs: PlaygroundPosition) -> Bool {
        return lhs.x != rhs.x || lhs.y != rhs.y
    }

    var x : Int
    var y : Int
    
    
    required init(coder: NSCoder)
    {
        self.x = Int(coder.decodeInt32(forKey: "x"))
        self.y = Int(coder.decodeInt32(forKey: "y"))
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.x, forKey: "x")
        aCoder.encode(self.y, forKey: "y")
    }
}


class Beamer : NSObject,NSCoding {
    var from : PlaygroundPosition
    var to : PlaygroundPosition
    
    init(from:PlaygroundPosition,to:PlaygroundPosition)
    {
        self.from = from
        self.to = to
    }
    
    required init(coder: NSCoder)
    {
        self.from = coder.decodeObject(forKey: "from") as! PlaygroundPosition
        self.to = coder.decodeObject(forKey: "to") as! PlaygroundPosition
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.from, forKey: "from")
        aCoder.encode(self.to, forKey: "to")
    }
}



class Playground: NSObject,NSCoding {
    
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
        default:
            return position
        }
    }

    static let chickenDuration = 0.1
    static let fishDuration = 0.1
    static let puppetMove = 0.1
    
    static var replay = Array<Playground>()

    static var finalLevel = 15
    
    var playgroundArray : Array<Array<MazeElement>> = Array()  // Das spielfeld
    var beamerArray = Array<Beamer>() // transporter start co-ordinates
    var playerOneMazeElement : MazeElement?
    var playerTwoMazeElement : MazeElement?
    var sceneDelegate : SceneDelegate?
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
    var endOfAnimation = {}
    var playerJustKilled = false
    // screen co-ordinates of the current player
    var playerPosition : PlaygroundPosition
    var moveDirection : PlayerMoveDirection
    // old screen co-ordinates
    var oldPlayerPosition : PlaygroundPosition
    var cameraLeftTopPosition : PlaygroundPosition  // the part of the playground, which should be shown: clipper
    var positionPlayerOne : PlaygroundPosition // current and startposition of Player One
    var positionPlayerTwo : PlaygroundPosition // current and startposition of Player Two
    
    override public var description : String {
        var strX = ""
        var strY = "\n"
        for y in 0..<PlaygroundBuilder.Constants.groesseX
        {
            for x in 0..<PlaygroundBuilder.Constants.groesseY
            {
                let element = self.element(position: PlaygroundPosition(x:x,y:y))
                if let mazetype = element?.mazeElementType
                {
                    if let s = PlaygroundBuilder.stringToMazeElement[mazetype]
                    {
                        strX = strX.appending(s)
                    }
                    else
                    {
                        strX = strX.appending("_")
                    }
                }
                else
                {
                    strX = strX.appending("_")
                }
                
            }
            strY = strY.appending(strX).appending("\n")
            strX=""
        }
        
       strY = strY.appending("Position Player One:\(self.positionPlayerOne),\(self.playerPosition), finished:\(self.finished),justFinished:\(self.justFinished), Direction:\(self.moveDirection)")
        return strY
    }

    // MARK: Init Methods
    // NSCoder
    required init(coder: NSCoder)
    {
        self.positionPlayerOne = coder.decodeObject(forKey: "positionPlayerOne") as! PlaygroundPosition
        self.positionPlayerTwo = coder.decodeObject(forKey: "positionPlayerTwo") as! PlaygroundPosition
        self.cameraLeftTopPosition    = coder.decodeObject(forKey: "cameraLeftTopPosition") as! PlaygroundPosition
        self.playerPosition = coder.decodeObject(forKey: "playerPosition") as! PlaygroundPosition
        self.oldPlayerPosition = coder.decodeObject(forKey: "oldPlayerPosition") as! PlaygroundPosition
        self.moveDirection = PlayerMoveDirection(rawValue: Int(coder.decodeInt32(forKey: "moveDirection")))!
        super.init()
        self.beamerArray = coder.decodeObject(forKey: "beamerArray") as! Array<Beamer>
        self.playgroundArray = coder.decodeObject(forKey: "playgroundArray") as! Array<Array<MazeElement>>
        self.playerOneMazeElement = coder.decodeObject(forKey: "playerOneMazeElement") as? MazeElement
        self.playerTwoMazeElement = coder.decodeObject(forKey: "playerTwoMazeElement") as? MazeElement
        self.sceneDelegate = nil
        self.akt_spieler_ist_playerOne = (coder.decodeObject(forKey: "akt_spieler_ist_playerOne") != nil)
        self.ende_erreicht = (coder.decodeObject(forKey: "ende_erreicht") != nil)
        self.anzahl_spielzuege = Int(coder.decodeInt32(forKey: "anzahl_spielzuege"))
        self.masken_gesammelt = Int(coder.decodeInt32(forKey: "masken_gesammelt"))
        self.masken_gesamtanzahl = Int(coder.decodeInt32(forKey:"masken_gesamtanzahl"))
        self.invisible = (coder.decodeObject(forKey: "invisible") != nil)
        self.numberOfKilledPlayer = Int(coder.decodeInt32(forKey: "numberOfKilledPlayer"))
        self.next_step = Int(coder.decodeInt32(forKey: "next_step"))
        self.level_name = coder.decodeObject(forKey: "level_name") as! String?
        self.level_geschafft = Int(coder.decodeInt32(forKey: "level_geschafft"))
        self.level_number = Int(coder.decodeInt32(forKey: "level_number"))
        self.justFinished = (coder.decodeObject(forKey: "justFinished") != nil)
        self.numberOfMoves = Int(coder.decodeInt32(forKey: "numberOfMoves"))
        self.mapsFound = coder.decodeObject(forKey: "mapsFound") as! Array<MazeElementType>
        self.finished = (coder.decodeObject(forKey: "finished") != nil)
        if self.level_number==1
        {
            print(self)
        }
        if qaTesting==true
        {
            self.finished = true
        }
        
     }
    
    func encode(with aCoder: NSCoder) {
        if self.akt_spieler_ist_playerOne == true
        {
            self.positionPlayerOne = self.playerPosition
        }
        else
        {
            self.positionPlayerTwo = self.playerPosition
        }
        
        aCoder.encode(positionPlayerOne, forKey: "positionPlayerOne")
        aCoder.encode(positionPlayerTwo, forKey: "positionPlayerTwo")
        aCoder.encode(cameraLeftTopPosition, forKey: "cameraLeftTopPosition")
        aCoder.encode(playerPosition, forKey: "playerPosition")
        aCoder.encode(oldPlayerPosition, forKey: "oldPlayerPosition")
        aCoder.encode(Int(moveDirection.rawValue),forKey:"moveDirection")
        aCoder.encode(beamerArray, forKey: "beamerArray")
        aCoder.encode(playgroundArray, forKey: "playgroundArray")
        aCoder.encode(playerOneMazeElement, forKey: "playerOneMazeElement")
        aCoder.encode(playerTwoMazeElement, forKey: "playerTwoMazeElement")
        aCoder.encode(akt_spieler_ist_playerOne, forKey: "akt_spieler_ist_playerOne")
        aCoder.encode(ende_erreicht, forKey: "ende_erreicht")
        aCoder.encode(anzahl_spielzuege, forKey: "anzahl_spielzuege")
        aCoder.encode(masken_gesammelt, forKey: "masken_gesammelt")
        aCoder.encode(masken_gesamtanzahl, forKey: "masken_gesamtanzahl")
        aCoder.encode(invisible, forKey: "invisible")
        aCoder.encode(numberOfKilledPlayer, forKey: "numberOfKilledPlayer")
        aCoder.encode(next_step, forKey: "next_step")
        aCoder.encode(level_name, forKey: "level_name")
        aCoder.encode(level_geschafft, forKey: "level_geschafft")
        aCoder.encode(level_number, forKey: "level_number")
        
        aCoder.encode(numberOfMoves, forKey: "numberOfMoves")
        aCoder.encode(mapsFound, forKey: "mapsFound")
        if finished==true
        {
            aCoder.encode("1",forKey:"finished")
        }
        if justFinished==true
        {
            aCoder.encode("1", forKey: "justFinished")
        }
        // aCoder.encode(playerOneMazeElement, forKey: "playerOneMazeElement")
       // aCoder.encode(playerTwoMazeElement, forKey: "playerTwoMazeElement")
        
        if self.level_number==1 {
            print(self)
        }
        
        
    }
    
    override func copy() -> Any
    {
        let playground = Playground()
        playground.playgroundArray = self.playgroundArray.map{$0}
//        for i in playgroundArray
//        {
//            for var j in i
//            {
//                j.sprite=nil
//            }
//        }
        playground.beamerArray = self.beamerArray
        playground.playerOneMazeElement = self.playerOneMazeElement
        playground.playerTwoMazeElement = self.playerTwoMazeElement
        playground.sceneDelegate = self.sceneDelegate
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
        playground.finished = self.finished
        playground.numberOfMoves = self.numberOfMoves
        playground.mapsFound = self.mapsFound
        playground.playerPosition = self.playerPosition
        playground.oldPlayerPosition = self.oldPlayerPosition
        playground.cameraLeftTopPosition = self.cameraLeftTopPosition
        playground.positionPlayerOne = self.positionPlayerOne
        playground.positionPlayerTwo = self.positionPlayerTwo
        playground.moveDirection = self.moveDirection
        
        return playground
    }
    
    
    
    override init()
    {
        self.positionPlayerOne = Playground.Null()
        self.positionPlayerTwo = Playground.Null()
        self.cameraLeftTopPosition    = Playground.Null()
        self.playerPosition    = PlaygroundPosition(x: -1, y: -1)
        self.oldPlayerPosition = PlaygroundPosition(x: -1, y: -1)
        self.moveDirection=PlayerMoveDirection.NONE
        super.init()
    }
    
    // MARK: Player changes
    
    func changePlayer()
    {
        self.moveDirection = PlayerMoveDirection.PLAYERCHANGED
        let previousPlayground = self.copy() as! Playground
        Playground.replay.append(previousPlayground)
        self.anzahl_spielzuege += 1
        sceneDelegate?.updateViewController(event:MazeEvent.switchPlayer)
        sceneDelegate?.updateViewController(event:MazeEvent.step_done)

    }
    
    
    func movePlayer(queue:Array<PlayerMoveDirection>)
    {
        if queue.count>0
        {
            let firstElement = queue.first
            var q = queue
            self.endOfAnimation = {
                if q.count>0
                {
                    if self.playerJustKilled==false
                    {
                        q.removeFirst()
                        self.movePlayer(queue:q)
                    }
                    else
                    {
                        self.playerJustKilled = false
                    }
                }
            }
            self.movePlayer(direction: firstElement!,replaying:false)
        }
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
    
       
    
        
    func allMasksCollected() -> Bool
    {
        return true // self.masken_gesamtanzahl == self.masken_gesammelt
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
                sceneDelegate?.playApplause()
                return true
            }
        }
        return false
    }
    
    func movePlayer(direction:PlayerMoveDirection,replaying:Bool)
    {
        if self.numberOfMovesNotExceeded()==false 
        {
            return
        }
        self.moveDirection = direction
        let previousPlayground = self.copy() as! Playground
        if replaying==false
        {
            Playground.replay.append(previousPlayground)
        }
        var canMove = true
        var mazeElementType : MazeElementType?
        var newPosition : PlaygroundPosition?
        var canMoveFish = false
        var canMoveChicken = false
        var beamed = false
        sceneDelegate?.animationCompleted(function: nil)
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
                    if let newpos = beamMeUp(position:playerPosition)
                    {
                        if element(position: newpos)?.mazeElementType == MazeElementType.space
                        {
                            beamed = true
                            anzahl_spielzuege += 1
                            newPosition = newpos
                        }
                        else
                        {
                            canMove = false
                        }
                    }
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
                        sceneDelegate?.animationCompleted(function:
                            {
                                element, position in

                                if canMoveChicken == true
                                {
                                    canMoveChicken = false
                                    if mazeElementType == MazeElementType.puppet
                                    {
                                        self.increaseEventCounter(comment: "puppet run!", element: MazeElementType.puppet)
                                        self.puppetMove(position: position, direction: direction)
                                    }
                                    else
                                    {
                                        self.increaseEventCounter(comment: "chicken run 2!", element: MazeElementType.chicken)
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
                    if let newpos = beamMeUp(position:playerPosition)
                    {
                        if element(position: newpos)?.mazeElementType == MazeElementType.space
                        {
                            beamed = true
                            anzahl_spielzuege += 1
                            newPosition = newpos
                        }
                        else
                        {
                            canMove = false
                        }
                    }
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
                    sceneDelegate?.animationCompleted(function:
                        {

                            element, position in
                            

                            if canMoveFish == true
                            {
                                canMoveFish = false
                                if mazeElementType==MazeElementType.puppet
                                {
                                    self.increaseEventCounter(comment: "puppet run!", element: MazeElementType.puppet)
                                    self.puppetMove(position:position,direction: direction)
                                }
                                else
                                {
                                    self.increaseEventCounter(comment: "fish fall!", element: MazeElementType.puppet)
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
        if self.numberOfMovesNotExceeded() == false {
            print("Ende!")
            sceneDelegate?.updateViewController(event: MazeEvent.movesExceeded)
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
            default:
                break
            }
            // move player 1 to new position in the playground array
        }
        
        changeElement(position: playerPosition, element: mazeType!)
        sceneDelegate?.drawPlayer(position: playerPosition, previousPosition: oldPlayerPosition, player: self.akt_spieler_ist_playerOne, beamed:beamed, completition:
            {
                self.doTheFishChickenMoving(position: self.oldPlayerPosition)
            }
        )
        
        sceneDelegate?.updateViewController(event:MazeEvent.step_done)
        if beamed==true
        {
             sceneDelegate?.moveCameraToPlaygroundCoordinates(position:PlaygroundPosition(x:playerPosition.x-3,y:playerPosition.y-3))
        }
        else
        {
            self.updateCameraPosition(direction)
        }
        
    }
    
    func setCameraPositionToPlayerOne()
    {
        cameraLeftTopPosition.x = self.positionPlayerOne.x
        cameraLeftTopPosition.y = self.positionPlayerOne.y
        self.updateCameraPosition(PlayerMoveDirection.UP)
    }
    
    func updateCameraPosition(_ direction:PlayerMoveDirection)
    {
        // CAMERA
        // we moved the player, now check if we have to move the camera
        let newCameraPosition = cameraLeftTopPosition
        
        if (cameraLeftTopPosition.x == playerPosition.x && direction==PlayerMoveDirection.LEFT) ||
           (abs(cameraLeftTopPosition.x-playerPosition.x)>6 && direction==PlayerMoveDirection.RIGHT)
        {
            newCameraPosition.x = oldPlayerPosition.x - 3
        }
        else
        if (cameraLeftTopPosition.y == (playerPosition.y) && direction==PlayerMoveDirection.UP) ||
            (abs(cameraLeftTopPosition.y-playerPosition.y)>6 && direction==PlayerMoveDirection.DOWN)
        {
                newCameraPosition.y = playerPosition.y - 3
        }
        if newCameraPosition.y > (PlaygroundBuilder.Constants.groesseY-PlaygroundBuilder.Constants.sichtbareGroesseY)
        {
            newCameraPosition.y = (PlaygroundBuilder.Constants.groesseY-PlaygroundBuilder.Constants.sichtbareGroesseY)
        }
        if newCameraPosition.x > (PlaygroundBuilder.Constants.groesseX-PlaygroundBuilder.Constants.sichtbareGroesseX)
        {
            newCameraPosition.x = PlaygroundBuilder.Constants.groesseX-PlaygroundBuilder.Constants.sichtbareGroesseX
        }
        
        sceneDelegate?.moveCameraToPlaygroundCoordinates(position: newCameraPosition)
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
                sceneDelegate?.updateViewController(type: mazeelementtype)
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
                 sceneDelegate?.updateViewController(event:MazeEvent.bad_mask_found)
            }
            let mazeType = element(position:position)
            sceneDelegate?.spritesToRemove(mazeType!)
            createEmptySpaceOnPlayground(position:position)
            sceneDelegate?.updateViewController(event:MazeEvent.redraw)
        }
    }
    
   
    
    func createEmptySpaceOnPlaygroundAndRemoveSprite(position:PlaygroundPosition,duration:TimeInterval)
    {
        let e = element(position: position)?.mazeElementType
        
        if (e==MazeElementType.player_1 || e==MazeElementType.player_2) {
            self.killCurrentPlayer(e!)
        }
        changeElementAndRemoveSprite(position: position, element: MazeElement(mazeElementType: MazeElementType.space, sprite:nil),duration:duration)
    }
    
    
    func createEmptySpaceOnPlayground(position:PlaygroundPosition)
    {
        changeElement(position: position, element: MazeElement(mazeElementType: MazeElementType.space, sprite:nil))
    }
    
    func createWallOnPlayground(position:PlaygroundPosition)
    {
        changeElement(position: position, element: MazeElement(mazeElementType: MazeElementType.wall, sprite:nil))
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
        //print("elementLeftFrom Element:\(a)")
        return a
    }
    func elementRightFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y][position.x+1]
        //print("elementRightFrom Element:\(a)")
        return a
    }
    func elementAboveFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y-1][position.x]
        //print("elementAboveFrom Element:\(a)")
        return a
    }
    func elementDownFrom(position:PlaygroundPosition) -> MazeElement?
    {
        let a = playgroundArray[position.y+1][position.x]
        //print("elementDownFrom Element:\(a)")
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
        
         sceneDelegate?.drawSprite(element:element,
                          position:position,
                          duration:Playground.chickenDuration,
                          completed:completition)

    }
    
 
    // MARK: chicken run and fish fall methods
    
       
    func killCurrentPlayer(_ elementType:MazeElementType)
    {
        playerJustKilled=true
        if numberOfKilledPlayer==0
        {
            numberOfKilledPlayer=1
            if elementType==MazeElementType.player_1
            {
                 sceneDelegate?.updateViewController(event:MazeEvent.death_player1)
            }
            else
            {
                 sceneDelegate?.updateViewController(event:MazeEvent.death_player2)
            }
            
        }
        else
        {
            numberOfKilledPlayer=2
             sceneDelegate?.updateViewController(event:MazeEvent.death_both)
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
    
    
    
    
    
}
