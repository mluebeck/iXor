//
//  PlaygroundBuilder.swift
//  iXor
//
//  Created by Mario Rotz on 22.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

class PlaygroundBuilder: NSObject
{

    static var filePath : String
    {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url?.appendingPathComponent("playgrounds").path)!
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
    
    static let stringToMazeElement : [MazeElementType : String]=[
        MazeElementType.space : "_",
        MazeElementType.fish : "F",
        MazeElementType.chicken : "C" ,
        MazeElementType.map_1: "m",
        MazeElementType.map_2: "n",
        MazeElementType.map_3: "o",
        MazeElementType.map_4 : "p",
        MazeElementType.mask : "M",
        MazeElementType.bad_mask : "X",
        MazeElementType.h_wave : "H",
        MazeElementType.v_wave : "V",
        MazeElementType.puppet : "P",
        MazeElementType.bomb : "B",
        MazeElementType.acid : "S",
        MazeElementType.transporter : "T",
        MazeElementType.player_1 : "a",
        MazeElementType.player_2 : "b",
        MazeElementType.exit : "E",
        MazeElementType.wall : "W"  ]
   
    
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
        MazeElementType.wall:       "wand",
        MazeElementType.skull:       "skull",
        
    ]
    
    
    struct Constants
    {
        static let groesseX = 32;         // playground dimensions (=32x32)
        static let groesseY = 32;         // playground dimensions (=32x32)
        static let sichtbareGroesseX = 8  // visible playground
        static let sichtbareGroesseY = 8  // visible playground
        static let maximumMoves = 1000
    }
    
    static func readLevelString(filepath: String) -> Playground
    {
        return readFromFile(filepath: filepath)
    }
    
    static func readFromFile(filepath: String) -> Playground
    {
        let localPlayground = Playground()
        let s = try! String(contentsOfFile: filepath)
        localPlayground.contentAsString = s
        return readFromString(playground:localPlayground)
    }
    
    static func readFromString(playground:Playground?) -> Playground
    {
        var x = 0
        var y = 0
        var beamerCoordinates = Beamer(from:Playground.Null(),to:Playground.Null())
        
        var commentMode = false
        var levelTitleWithNumber : String = ""
        var mazeString : String = ""
        playground?.playgroundArray.removeAll()
        playground?.masken_gesamtanzahl = 0
        playground?.masken_gesammelt = 0
        playground?.anzahl_spielzuege = 0
        playground?.akt_spieler_ist_playerOne = true
        playground?.numberOfKilledPlayer = 0

        let language = Bundle.main.preferredLocalizations.first

        for char in (playground?.contentAsString)!
        {
            if commentMode == true
            {
                if char == "#"
                {
                    commentMode = false
                }
                else
                {
                    levelTitleWithNumber.append(char)
                }
            }
            else
            {
                if char == "#"
                {
                    commentMode = true
                }
                else
                {
                    if !(char == "\n" && mazeString.count == 0)
                    {
                        mazeString.append(char)
                    }
                }
            }
        }
        
        let arr = levelTitleWithNumber.components(separatedBy:":")
        
        for i in 1...arr.count
        {
            if arr[i]==language {
                playground?.level_name = arr[i+1]
                break
            }
        }
        let numberStr = arr[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        playground?.level_number = Int(numberStr)!
        
        var i = 0
        var localArray = Array<MazeElement>()
        
        for char in mazeString
        {
            if char == "z"
            {
                Playground.finalLevel=(playground?.level_number)!
                y -= 1
            }
            else
            if char == "\n"
            {
                x = 0
                y += 1
                if localArray.count>0
                {
                    playground?.playgroundArray.append(localArray)
                    i += 1;
                    localArray = Array<MazeElement>()
                }
            }
            else
            if !(char == " ")
            {
                if char == "a"
                {
                    if !((playground?.positionPlayerOne.x)!>0 && (playground?.positionPlayerOne.y)!>0)
                    {
                        playground?.positionPlayerOne.x = x
                        playground?.positionPlayerOne.y = y
                        playground?.playerPosition.x = x
                        playground?.playerPosition.y = y
                        playground?.oldPlayerPosition = (playground?.playerPosition)!
                    }
                }
                else
                if char == "b"
                {
                    playground?.positionPlayerTwo.x = x
                    playground?.positionPlayerTwo.y = y
                }
                else
                if char == "M"
                {
                    playground?.masken_gesamtanzahl += 1
                }
                
                if !(char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" )
                {
                    if let element = PlaygroundBuilder.mazeElementToString[char]! as MazeElementType?
                    {
                        if element == MazeElementType.space
                        {
                            let mazeElement = MazeElement(mazeElementType: MazeElementType.space, sprite:nil)
                            localArray.append(mazeElement)
                        }
                        else
                        {
                            let sprite = SKSpriteNode(imageNamed:PlaygroundBuilder.MazeElementToFilename[element]!)
                            let mazeElement = MazeElement(mazeElementType: element, sprite:sprite)
                            if char == "a"
                            {
                                sprite.zPosition = 1.0
                                playground?.playerOneMazeElement = mazeElement
                                
                            }
                            else
                            if char == "b"
                            {
                                sprite.zPosition = 1.0
                                playground?.playerTwoMazeElement = mazeElement
                            }
                            else
                            {
                                sprite.zPosition = 0.0
                            }
                            if mazeElement.mazeElementType == MazeElementType.chicken
                            {
                                print("Added Chicken:\(x) \(y)")
                            }
                            localArray.append(mazeElement)
                        }
                    }
                }
                else
                {
                    // Transporter coordinates!
                        
                    let kl = Int(String(char))
                    if x % 4 == 0
                    {
                        beamerCoordinates.from.x = kl!
                    }
                    else
                    if x % 4 == 1
                    {
                        beamerCoordinates.from.y = kl!//playground?.beam_from[index][1] = kl!;
                    }
                    else
                    if x % 4 == 2
                    {
                        beamerCoordinates.to.x = kl!
                    }
                    else
                    if x % 4 == 3
                    {
                        beamerCoordinates.to.y = kl!//playground?.beam_from[index][1] = kl!;
                        playground?.beamerArray.append(beamerCoordinates)
                        beamerCoordinates = Beamer(from:Playground.Null(),to:Playground.Null())
                    }
                }
                x+=1
            }
            //print("testing \(x), \(y).... \(playground?.element(position: PlaygroundPosition(x:x,y:y)))")
        }
        return playground!
    }
    
    
    static private func readLevel(number: Int) -> Playground
    {
        var file : String = ""
        if number>9
        {
            file = "level\(number)"
        }
        else
        {
            file = "level0\(number)"
        }
        
        if let s = Bundle.main.path(forResource: file, ofType: levelsToLoad)
        {
            return self.readFromFile(filepath: s)
        }
        else
        {
            assert(false, "File does not exists")
        }
    }
    
    
    static func archive(_ playgroundList : PlaygroundList)
    {
        let b = NSKeyedArchiver.archiveRootObject(playgroundList, toFile: filePath)
        print("Bool:\(b)")
    }

    static func unarchive()->PlaygroundList
    {
        let path = filePath
        print("\(path)")
        var playgroundList : PlaygroundList?
        playgroundList = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? PlaygroundList
        if playgroundList == nil
        {
            return PlaygroundList()
        }
        return playgroundList!
    }
    
    static func playgrounds(_ name:String,fromArchive:Bool) -> PlaygroundList
    {
        if fromArchive == true
        {
            let  playgroundList = self.unarchive()
            if playgroundList.playgrounds.count == 0
            {
                return self.playgrounds(name, fromArchive: false)
            }
            else
            {
                return playgroundList
            }
        }
        else
        {
            let playgroundList = PlaygroundList()
            let paths = Bundle.main.paths(forResourcesOfType: name, inDirectory: nil)
            for path in paths
            {
                let playground = PlaygroundBuilder.readLevelString(filepath:path)
                playgroundList.playgrounds[playground.level_number]=playground
            }
            self.archive(playgroundList)
            return playgroundList
        }
    }
    
    
    
}
