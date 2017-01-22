//
//  PlaygroundBuilder.swift
//  iXor
//
//  Created by Mario Rotz on 22.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

class PlaygroundBuilder: NSObject {

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
    
    struct Constants {
        static let groesseX = 32;         // playground dimensions (=32x32)
        static let groesseY = 32;         // playground dimensions (=32x32)
        static let sichtbareGroesseX = 8  // visible playground
        static let sichtbareGroesseY = 8  // visible playground
        static let maximumMoves = 1000
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
    
    static func readLevelString(filepath: String) -> Playground {
        return readLevelString(filepath: filepath, playground:nil)
    }
    
    static func readLevelString(filepath: String, playground:Playground?) -> Playground
    {
        let s = try! String(contentsOfFile: filepath)
        var x = 0
        var y = 0
        var commentMode = false
        var levelTitleWithNumber : String = ""
        var mazeString : String = ""
        var localPlayground = playground
        if playground == nil {
            localPlayground = Playground()
        }
        
        localPlayground?.playgroundArray.removeAll()
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
            localPlayground?.level_name = arr[1]
            let numberStr = arr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            localPlayground?.level_number = Int(numberStr)!
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
                    localPlayground?.playgroundArray.append(localArray)
                    i += 1;
                    localArray = Array<MazeType>()
                }
            }
            else
                if !(char == " ")
                {
                    if char == "a" {
                        localPlayground?.positionPlayerOne.x = x
                        localPlayground?.positionPlayerOne.y = y
                        localPlayground?.playerPosition.x = x
                        localPlayground?.playerPosition.y = y
                        localPlayground?.oldPlayerPosition = (localPlayground?.playerPosition)!
                    } else
                        if char == "b" {
                            localPlayground?.positionPlayerTwo.x = x
                            localPlayground?.positionPlayerTwo.y = y
                        }
                        else if char == "M" {
                            localPlayground?.anzahl_masken += 1
                    }
                    if !(char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" ) {
                        if let element = PlaygroundBuilder.mazeElementToString[char]! as MazeElementType? {
                            if element == MazeElementType.space {
                                let mazeElement = MazeType(mazeElementType: MazeElementType.space, sprite:nil)
                                localArray.append(mazeElement)
                            } else {
                                let sprite = SKSpriteNode(imageNamed:PlaygroundBuilder.MazeElementToFilename[element]!)
                                if char == "a" {
                                    sprite.zPosition = 1.0
                                    localPlayground?.playerOneSprite = sprite
                                    
                                } else
                                    if char == "b" {
                                        sprite.zPosition = 1.0
                                        localPlayground?.playerTwoSprite = sprite
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
                            localPlayground?.beam_from[index][0] = kl!;
                        } else
                            if x % 4 == 1 {
                                localPlayground?.beam_from[index][1] = kl!;
                            }
                            else
                                if x % 4 == 2 {
                                    localPlayground?.beam_to[index][0] = kl!;
                                }
                                else
                                    if x % 4 == 3 {
                                        localPlayground?.beam_to[index][1] = kl!;
                                        index=index+1
                        }
                        x=x+1
                    }
                    x = x + 1
            }
            
        }
        return localPlayground!
    }
    
    static func readLevel(number: Int) -> Playground {
        return readLevel(number:number,playground:nil)!
    }
    
    static func readLevel(number: Int, playground: Playground?) -> Playground? {
        var file : String = ""
        if number>9 {
            file = "level\(number)"
        } else {
            file = "level0\(number)"
        }
        
        if let s = Bundle.main.path(forResource: file, ofType: "xor") {
            return self.readLevelString(filepath: s, playground:playground)
        }
        return nil
    }
}
