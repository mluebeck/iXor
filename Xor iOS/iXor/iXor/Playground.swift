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
    var positionX : Int
    var positionY : Int
}


struct MazeType {
    var mazeElementType : MazeElementType?
    var sprite : SKSpriteNode?
}

class Playground: NSObject {
    
    static func up(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(positionX:position.positionX,positionY:position.positionY-1)
    }
    
    static func down(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(positionX:position.positionX,positionY:position.positionY+1)
    }
    
    
    static func left(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(positionX:position.positionX-1,positionY:position.positionY)
    }
    static func right(position:PlaygroundPosition)->PlaygroundPosition {
        return PlaygroundPosition(positionX:position.positionX+1,positionY:position.positionY)
    }
    
    
    struct Constants {
        static let groesseX = 32;         // playground dimensions (=32x32)
        static let groesseY = 32;         // playground dimensions (=32x32)
        static let sichtbareGroesseX = 8  // visible playground
        static let sichtbareGroesseY = 8  // visible playground
        static let maximumMoves = 1000
    }

    static let mazeElementToString : [Character : MazeElementType]=[
        "_":MazeElementType.space,
        "F":MazeElementType.fish,
        "C":MazeElementType.chicken,
        "m":MazeElementType.map_1,
        "n":MazeElementType.map_2,
        "o":MazeElementType.map_3,
        "p":MazeElementType.map_4,
        "M":MazeElementType.mask,
        "X":MazeElementType.bad_mask,
        "H":MazeElementType.h_wave,
        "V":MazeElementType.v_wave,
        "P":MazeElementType.puppet,
        "B":MazeElementType.bomb,
        "S":MazeElementType.acid,
        "T":MazeElementType.transporter,
        "a":MazeElementType.player_1,
        "b":MazeElementType.player_2,
        "E":MazeElementType.exit,
        "W":MazeElementType.wall   ]
    
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
    
    static var currentPlaygroundLevel = 1

    var playgroundArray : Array<Array<MazeType>> = Array()  // Das spielfeld
    
    var beam_from = Array<Array<Int>>() // transporter start co-ordinates
    var beam_to =   Array<Array<Int>>() // transporter target co-ordinates
    
    var playerOneSprite : SKSpriteNode?
    var playerTwoSprite : SKSpriteNode?
    
    
    
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
    var boolean_death = false         // false: 2 Spieler übrig, true : 1 Spieler übrig
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
    var playerCoordinates : PlaygroundPosition
    
    // old screen co-ordinates
    var playerCoordinatesOld : PlaygroundPosition
    
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
        self.positionPlayerOne = PlaygroundPosition(positionX: 0,positionY: 0)
        self.positionPlayerTwo = PlaygroundPosition(positionX: 0,positionY: 0)
        self.cameraPosition   = PlaygroundPosition(positionX: 0, positionY: 0)
        self.playerCoordinates = PlaygroundPosition(positionX: -1, positionY: -1)
        self.playerCoordinatesOld = PlaygroundPosition(positionX: -1, positionY: -1)

        super.init()

        for _ in 0..<20 {
            beam_from.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
            beam_to.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
        }
    }
    func changePlayer()
    {
        if !boolean_death {
            if akt_spieler_ist_playerOne {
                playerCoordinates = positionPlayerOne
            }
            else
            {
                playerCoordinates = positionPlayerTwo
            }
        }
    }
    func readLevelString(filepath: String) {
        let s = try! String(contentsOfFile: filepath)
        var positionX = 0
        var positionY = 0
        var commentMode = false
        var levelTitleWithNumber : String = ""
        var mazeString : String = ""
        self.playgroundArray.removeAll()
        for char in s.characters {
            if commentMode == true {
                if char == "#" {
                    commentMode = false
                } else {
                    levelTitleWithNumber.append(char)
                }
            } else
            {
                if char == "#" {
                    commentMode = true
                }
                else {
                    if !(char == "\n" && mazeString.characters.count == 0)
                    {
                        mazeString.append(char)
                    }
                }
            }
        }
        
        let arr = levelTitleWithNumber.components(separatedBy:":")
        if arr.count==2 {
            self.level_name = arr[1]
            let numberStr = arr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.level_number = Int(numberStr)!
        }
        
        var i = 0
        var localArray = Array<MazeType>()
        
        var x=0
        var index = 0
        for char in mazeString.characters {
            if char == "\n" {
                positionX = 0
                positionY = positionY + 1
                if localArray.count>0
                {
                    self.playgroundArray.append(localArray)
                    i += 1;
                    localArray = Array<MazeType>()
                }
            }
            else
            if !(char == " ")
            {
                if char == "a" {
                    self.positionPlayerOne.positionX = positionX
                    self.positionPlayerOne.positionY = positionY
                } else
                if char == "b" {
                    self.positionPlayerTwo.positionX = positionX
                    self.positionPlayerTwo.positionY = positionY
                }
                else if char == "M" {
                    anzahl_masken += 1
                }
                if !(char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" ) {
                    if let element = Playground.mazeElementToString[char]! as MazeElementType? {
                        if element == MazeElementType.space {
                            let mazeElement = MazeType(mazeElementType: nil, sprite:nil)
                            localArray.append(mazeElement)
                        } else {
                            let sprite = SKSpriteNode(imageNamed:Playground.MazeElementToFilename[element]!)
                            if char == "a" {
                                sprite.zPosition = 1.0
                                playerOneSprite = sprite
                                
                            } else
                            if char == "b" {
                                sprite.zPosition = 1.0
                                playerTwoSprite = sprite
                            }
                            else
                            {
                                sprite.zPosition = 0.0
                            }
                            let mazeElement = MazeType(mazeElementType: element, sprite:sprite)
                            localArray.append(mazeElement)
                        }
                    }
                } else {
                    // Transporter coordinates!
                    
                    let kl = Int(String(char))
                    if x % 4 == 0 {
                        beam_from[index][0] = kl!;
                    } else
                    if x % 4 == 1 {
                        beam_from[index][1] = kl!;
                    }
                    else
                    if x % 4 == 2 {
                        beam_to[index][0] = kl!;
                    }
                    else
                    if x % 4 == 3 {
                        beam_to[index][1] = kl!;
                        index=index+1
                    }
                    x=x+1
                }
                positionX = positionX + 1
            }

        }
    }
    
    
    func readLevel(number: Int) {
        var file : String = ""
        if number>9 {
            file = "level\(number)"
        } else {
            file = "level0\(number)"
        }
        
        if let s = Bundle.main.path(forResource: file, ofType: "xor") {
            readLevelString(filepath: s)
        }
    }
    
    func element(position:PlaygroundPosition) -> MazeType? {
        let a = playgroundArray[position.positionY][position.positionX]
        print("Element:\(a) at position : \(position)")
        return a
    }
    
    func changeElement(position:PlaygroundPosition,element:MazeType) {
        playgroundArray[position.positionY][position.positionX] = element
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
            lposition = PlaygroundPosition(positionX: position.positionX-1, positionY: position.positionY)
        }
        else
        if direction == PlayerMoveDirection.RIGHT
        {
            lposition = PlaygroundPosition(positionX: position.positionX+1, positionY: position.positionY)
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
            lposition = PlaygroundPosition(positionX: position.positionX, positionY: position.positionY+1)
        }
        else
        if direction == PlayerMoveDirection.DOWN
        {
            lposition = PlaygroundPosition(positionX: position.positionX, positionY: position.positionY-1)
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
        return anzahl_spielzuege <= Playground.Constants.maximumMoves
    }
    
    func levelFinished(item:MazeElementType?) -> Bool{
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
    
    
    
    
    
    
    func movePlayer(direction:PlayerMoveDirection, scene:GameScene) {
        let cameraCoordinate = cameraPosition
        var coordinate = positionPlayerTwo
        var playerOne = false
        if akt_spieler_ist_playerOne == true
        {
            playerOne = true
            coordinate = positionPlayerOne
        }
        var canMoveToDirection = true
        var mazeElementType : MazeElementType?
        var newPosition : PlaygroundPosition?
        
        if direction == PlayerMoveDirection.UP  || direction == PlayerMoveDirection.DOWN
        {
            
            if direction == PlayerMoveDirection.UP && coordinate.positionY > 0
            {
                newPosition = Playground.up(position: coordinate)
            }
            else
                if direction == PlayerMoveDirection.DOWN && coordinate.positionY < Playground.Constants.groesseY-1
                {
                    newPosition = Playground.down(position: coordinate)
            }
            
            mazeElementType = element(position: newPosition!)?.mazeElementType
            if !levelFinished(item:mazeElementType)
            {
                if  MazeElement.is_v_wave(item: mazeElementType)
                {
                    canMoveToDirection = false
                }
                else
                {
                    anzahl_spielzuege += 1
                    
                    if checkIfWaveFound(mazeElementType: mazeElementType, position: newPosition!,scene: scene) == false
                    {
                        checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!,scene: scene)
                    }
                    scene.updateViewController!(MazeElementType.step)
                }
            }
        }
        else
            if direction == PlayerMoveDirection.LEFT || direction == PlayerMoveDirection.RIGHT
            {
                if direction == PlayerMoveDirection.LEFT && coordinate.positionX > 0
                {
                    newPosition = Playground.left(position: coordinate)
                }
                else
                    if direction == PlayerMoveDirection.RIGHT && coordinate.positionX < Playground.Constants.groesseX-1
                    {
                        newPosition = Playground.right(position: coordinate)
                }
                
                mazeElementType = element(position: newPosition!)?.mazeElementType
                if !levelFinished(item:mazeElementType)
                {
                    if  MazeElement.is_h_wave(item: mazeElementType)
                    {
                        canMoveToDirection = false
                    }
                    else
                    {
                        anzahl_spielzuege += 1
                        if checkIfWaveFound(mazeElementType: mazeElementType, position: newPosition!,scene: scene) == false {
                            checkIfMapOrMaskFound(mazeElementType: mazeElementType, position: newPosition!,scene: scene)
                        }
                        scene.updateViewController!(MazeElementType.step)
                    }
                }
        }
        
        // WE CAN MOVE!
        if canMoveToDirection==true
        {
            // old position : draw a space
            let mazeType = playgroundArray[coordinate.positionY][coordinate.positionX];
            let mazeSpace = MazeType(mazeElementType: nil, sprite:nil)
            playgroundArray[coordinate.positionY][coordinate.positionX] = mazeSpace
            
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
            // move player 1 to new position in the playground array
            playgroundArray[coordinate.positionY][coordinate.positionX] = mazeType
            
            scene.drawPlayer(coordinate: coordinate, player: playerOne)
            
            // CAMERA
            // we moved the player, now check if we have to move the camera
            var newCameraPosition = cameraCoordinate
            
            if (cameraCoordinate.positionX == (coordinate.positionX) && direction==PlayerMoveDirection.LEFT) ||
                (cameraCoordinate.positionX == (coordinate.positionX - 7) && direction==PlayerMoveDirection.RIGHT) {
                newCameraPosition.positionX = coordinate.positionX - 3
            }
            else
                if (cameraCoordinate.positionY == (coordinate.positionY) && direction==PlayerMoveDirection.UP) ||
                    (cameraCoordinate.positionY == (coordinate.positionY - 7) && direction==PlayerMoveDirection.DOWN) {
                    newCameraPosition.positionY = coordinate.positionY - 3
            }
            scene.moveCameraToPlaygroundCoordinates(coordinate: newCameraPosition)
        }
    } // func movePlayer
    
    
    
    func checkIfWaveFound(mazeElementType:MazeElementType?,position:PlaygroundPosition,scene:GameScene) -> Bool {
        if !(mazeElementType==nil) && (mazeElementType == MazeElementType.v_wave || mazeElementType == MazeElementType.h_wave)
        {
            let mazeType = element(position: position)
            scene.spriteToRemove = mazeType?.sprite //.removeFromParent()
            changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            return true
        }
        else
        {
            return false
        }
    }
    
    func checkIfMapOrMaskFound(mazeElementType:MazeElementType?, position:PlaygroundPosition,scene:GameScene)
    {
        if !(mazeElementType==nil) {
            if mapFound(mazeElementType: mazeElementType!, position: position,scene:scene) == false
            {
                if happyMaskFound(mazeElementType: mazeElementType!, position: position,scene:scene) == false
                {
                    if badMaskFound(mazeElementType :mazeElementType!,position:position,scene:scene) == false
                    {
                    }
                }
            }
            
        }
    }
    
    func mapFound(mazeElementType:MazeElementType,position:PlaygroundPosition,scene:GameScene) -> Bool {
        if MazeElement.isMap(item:mazeElementType)
        {
            mapsFound.append(mazeElementType)
            let mazeType = element(position: position)
            
            scene.spriteToRemove = mazeType?.sprite //.removeFromParent()
            
            changeElement(position: position,element: MazeType(mazeElementType: nil, sprite:nil))
            scene.updateViewController!(mazeElementType)
            return true
        }
        else
        {
            return false
        }
    }
    
    func happyMaskFound(mazeElementType:MazeElementType,position:PlaygroundPosition,scene:GameScene) -> Bool {
        if mazeElementType == MazeElementType.mask
        {
            anzahl_gesammelter_masken += 1
            scene.updateViewController!(MazeElementType.step)
            let mazeType = element(position: position)
            scene.spriteToRemove = mazeType?.sprite //.removeFromParent()
            changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            scene.updateViewController!(mazeElementType)
            return true
        }
        else
        {
            return false
        }
    }
    
    func badMaskFound(mazeElementType:MazeElementType,position:PlaygroundPosition,scene:GameScene) -> Bool {
        if mazeElementType == MazeElementType.bad_mask
        {
            if invisible==true {
                invisible = false
            }
            else {
                invisible = false
            }
            let mazeType = element(position: position)
            scene.spriteToRemove = mazeType?.sprite //.removeFromParent()
            
            changeElement(position: position, element: MazeType(mazeElementType: nil, sprite:nil))
            return true
        }
        else
        {
            return false
        }
    }
    

}


