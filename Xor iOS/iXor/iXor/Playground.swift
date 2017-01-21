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
    
    static func PlaygroundPositionUp(position:PlaygroundPosition) -> PlaygroundPosition {
        return PlaygroundPosition(x:position.x,y:position.y-1)
    }
    
    static func PlaygroundPositionDown(position:PlaygroundPosition) -> PlaygroundPosition {
        return PlaygroundPosition(x:position.x,y:position.y+1)
    }
    
    static func PlaygroundPositionLeft(position:PlaygroundPosition) -> PlaygroundPosition {
        return PlaygroundPosition(x:position.x-1,y:position.y)
    }
    
    static func PlaygroundPositionRight(position:PlaygroundPosition) -> PlaygroundPosition {
        return PlaygroundPosition(x:position.x+1,y:position.y)
    }
    
    static func PlaygroundPositionNull() -> PlaygroundPosition {
        return PlaygroundPosition(x: 0, y: 0)
    }
    
    func println() -> String {
        return "playground position x:\(self.x),y:\(self.y)."
    }
}




struct MazeType {
    var mazeElementType : MazeElementType?
    var sprite : SKSpriteNode?
}

enum SceneNotification : Int {
    case REDRAW = 0,
    UPDATE_VIEWCONTROLLER,
    DRAW_PLAYER,
    MOVE_CAMERA,
    DRAW_SPRITE,
    SPRITE_TO_REMOVE,
    SPRITE_OVERWRITE
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
    
    var sceneShallChange : ((SceneNotification,PlaygroundPosition?,MazeType?,Bool) -> Void)?
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
        if !boolean_death {
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
        for x in 0..<Playground.Constants.groesseX {
            for y in 0..<Playground.Constants.groesseY {
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
    
    func readLevelString(filepath: String) {
        let s = try! String(contentsOfFile: filepath)
        var x = 0
        var y = 0
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
        
        var index = 0
        for char in mazeString.characters {
            if char == "\n" {
                x = 0
                y = y + 1
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
                    self.positionPlayerOne.x = x
                    self.positionPlayerOne.y = y
                    self.playerPosition.x = x
                    self.playerPosition.y = y
                    self.oldPlayerPosition = self.playerPosition
                } else
                if char == "b" {
                    self.positionPlayerTwo.x = x
                    self.positionPlayerTwo.y = y
                }
                else if char == "M" {
                    anzahl_masken += 1
                }
                if !(char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" ) {
                    if let element = Playground.mazeElementToString[char]! as MazeElementType? {
                        if element == MazeElementType.space {
                            let mazeElement = MazeType(mazeElementType: MazeElementType.space, sprite:nil)
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
                x = x + 1
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
        return anzahl_spielzuege <= Playground.Constants.maximumMoves
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
        
        if direction == PlayerMoveDirection.UP  || direction == PlayerMoveDirection.DOWN
        {
            
            if direction == PlayerMoveDirection.UP && playerPosition.y > 0
            {
                newPosition = Playground.up(position: playerPosition)
            }
            else
            if direction == PlayerMoveDirection.DOWN && playerPosition.y < Playground.Constants.groesseY-1
            {
                newPosition = Playground.down(position: playerPosition)
            }
            
            mazeElementType = element(position: newPosition!)?.mazeElementType
            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                if MazeElement.canMoveUpDown(item: mazeElementType) == true
                {
                    anzahl_spielzuege += 1
                    
                    // Alte position löschen und den View Controller updaten.
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        //self.sceneShallChange!(SceneNotification.UPDATE_VIEWCONTROLLER,nil,MazeType(mazeElementType:MazeElementType.step,sprite:nil),playerOne)
                        scene?.updateViewController!(MazeElementType.step)
                    }
                }
                else
                {
                    
                    if mazeElementType == MazeElementType.chicken {
                        if direction == PlayerMoveDirection.UP {
                            if let anElement = elementAboveFrom(position: newPosition!) {
                                if anElement.mazeElementType == MazeElementType.space {
                                    anzahl_spielzuege += 1
                                    moveChickenUp(position: newPosition!)
                                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                                    {
                                        //self.sceneShallChange!(SceneNotification.UPDATE_VIEWCONTROLLER,nil,MazeType(mazeElementType:MazeElementType.step,sprite:nil),playerOne)
                                        scene?.updateViewController!(MazeElementType.step)
                                    }
                                }
                            }
                        }else
                        if direction == PlayerMoveDirection.DOWN {
                            if let anElement = elementDownFrom(position: newPosition!) {
                                if anElement.mazeElementType == MazeElementType.space {
                                    anzahl_spielzuege += 1
                                    moveChickenDown(position: newPosition!)
                                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                                    {
                                        //self.sceneShallChange!(SceneNotification.UPDATE_VIEWCONTROLLER,nil,MazeType(mazeElementType:MazeElementType.step,sprite:nil),playerOne)
                                        scene?.updateViewController!(MazeElementType.step)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        return
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
            if direction == PlayerMoveDirection.RIGHT && playerPosition.x < Playground.Constants.groesseX-1
            {
                newPosition = Playground.right(position: playerPosition)
            }
            
            // fetch element at new position
            mazeElementType = element(position: newPosition!)?.mazeElementType
            if !levelFinishedAndExitReached(item:mazeElementType)
            {
                if  MazeElement.canMoveLeftRight(item: mazeElementType) == true
                {
                    anzahl_spielzuege += 1
                    if removeItemFromPlayground(mazeElementType: mazeElementType, position: newPosition!)
                    {
                        //self.sceneShallChange!(SceneNotification.UPDATE_VIEWCONTROLLER,nil,MazeType(mazeElementType:MazeElementType.step,sprite:nil),playerOne)
                        scene?.updateViewController!(MazeElementType.step)
                    }
                }
                else
                {
                    return
                }
            }
        }
        updateScene(direction:direction)
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
    } 
    
    
    func removeItemFromPlayground(mazeElementType:MazeElementType?,position:PlaygroundPosition) -> Bool
    {
        if let mazeelementtype = mazeElementType
        {
            if  (mazeelementtype == MazeElementType.v_wave || mazeelementtype == MazeElementType.h_wave)
            {
                let mazeType = element(position:position)
                scene?.spritesToRemove.append(mazeType?.sprite)
                //createEmptySpaceOnPlayground(position:oldPlayerPosition)
                createEmptySpaceOnPlayground(position:position)
                scene?.updateViewController!(mazeElementType!)
            } else 
            if MazeElement.isMap(mazeelementtype)
            {
                mapsFound.append(mazeelementtype)
                let mazeType = element(position:position)
                scene?.spritesToRemove.append(mazeType?.sprite)
                createEmptySpaceOnPlayground(position:position)
                scene?.updateViewController!(mazeElementType!)
            }
            else
            if mazeelementtype == MazeElementType.mask
            {
                anzahl_gesammelter_masken += 1
                let mazeType = element(position:position)
                scene?.spritesToRemove.append(mazeType?.sprite)
                createEmptySpaceOnPlayground(position:position)
                scene?.updateViewController!(mazeElementType!)
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
                let mazeType = element(position:position)
                scene?.spritesToRemove.append(mazeType?.sprite)
                createEmptySpaceOnPlayground(position:position)
                scene?.updateViewController!(mazeElementType!)
            }
            else
            {
                //self.sceneShallChange!(SceneNotification.SPRITE_TO_REMOVE,position,nil,player)
                //print("SPRITE_TO_REMOVElösche Element an Position \(position)")
                let mazeType = element(position:position)
                scene?.spritesToRemove.append(mazeType?.sprite)
                //createEmptySpaceOnPlayground(position:oldPlayerPosition)
                createEmptySpaceOnPlayground(position:position)
                
            }
        }
        return false
    }
    
    
    func createEmptySpaceOnPlayground(position:PlaygroundPosition)
    {
        
        print("Element at position: \(position)")
        print("maze Element type:\(element(position:position))")
        
        changeElement(position: position, element: MazeType(mazeElementType: MazeElementType.space, sprite:nil))
        //testForChickenOrFishAction(position: position, scene: scene, player: player)
    }
    
    func testForChickenOrFishAction(position:PlaygroundPosition)
    {
        if let mazeType = elementAboveFrom(position: position)?.mazeElementType
        {
            // ist über dem leeren Feld ein Fish/Bombe?
            // fish, bombe fällt runter von selbst
            if mazeType==MazeElementType.fish || mazeType == MazeElementType.bomb {
                fishFall(position:PlaygroundPosition.PlaygroundPositionUp(position: position))
            }
        }
        
        if let mazeType = elementRightFrom(position: position)?.mazeElementType
        {
            // chicken, acid fliegen nach links von selbst
            // puppet in jede richtung, aber nur wenn sie angeschubst werden
            if mazeType==MazeElementType.chicken || mazeType == MazeElementType.acid {
                chickenRun(position:PlaygroundPosition.PlaygroundPositionRight(position: position))
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
        let leftposition = PlaygroundPosition.PlaygroundPositionLeft(position: position)
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
            //scene.drawSprite(sprite:(chickenElement?.sprite)!,position:leftposition)

            self.sceneShallChange!(SceneNotification.DRAW_SPRITE,leftposition,chickenElement,self.akt_spieler_ist_playerOne)

            // weitermachen !
            chickenRun(position:leftposition)
            testForChickenOrFishAction(position:position)

            break
        case MazeElementType.player_1, MazeElementType.player_2:
            killCurrentPlayer()
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            changeElement(position: leftposition, element: leftElement!)
            scene?.drawSprite(sprite:(leftElement?.sprite)!,position:leftposition)
            
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
            scene?.drawSprite(sprite:(chickenElement?.sprite)!,position:position)
            
            break
        default:
            break
        }
        
    }
    
    func fishFall(position:PlaygroundPosition) {
        let bottomposition = PlaygroundPosition.PlaygroundPositionDown(position: position)
        let fishElement = self.element(position: position)
        let bottomElement = self.element(position:bottomposition)                                  // space ?
        var elementType = MazeElementType.space
        if let elementtype = bottomElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.h_wave,MazeElementType.space:
            // Lösche alte Position des Fishes
            createEmptySpaceOnPlayground(position: position)
            // Bewege Fish um eins nach unten
            changeElement(position: bottomposition, element: fishElement!)
            //scene.drawSprite(sprite:(fishElement?.sprite)!,position:bottomposition)

            self.sceneShallChange!(SceneNotification.DRAW_PLAYER,bottomposition,nil,self.akt_spieler_ist_playerOne)

            // weitermachen !
            fishFall(position:bottomposition)
            testForChickenOrFishAction(position:position)
            
            break
        case MazeElementType.player_1, MazeElementType.player_2:
            killCurrentPlayer()
            
            // Bewege Huhn um eins nach links

            createEmptySpaceOnPlayground(position: position)
            changeElement(position: bottomposition, element: bottomElement!)
            //scene.drawSprite(sprite:(bottomElement?.sprite)!,position:bottomposition)
 
            self.sceneShallChange!(SceneNotification.DRAW_PLAYER,bottomposition,nil,self.akt_spieler_ist_playerOne)

            // weitermachen !
            fishFall(position:bottomposition)
            testForChickenOrFishAction(position:position)
            
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
            //scene.drawSprite(sprite:(fishElement?.sprite)!,position:position)
            self.sceneShallChange!(SceneNotification.DRAW_PLAYER,position,nil,self.akt_spieler_ist_playerOne)

            break
        default:
            break
        }
    }
    
    func killCurrentPlayer() {
        
    }
    
    func bombExplode() {
        
        
    }
    
    func acidCorrosive() {
        
    }
    
    func moveChickenUp(position:PlaygroundPosition) {
        
    }
    
    func moveChickenDown(position:PlaygroundPosition) {
        
    }
    
    
    
}
