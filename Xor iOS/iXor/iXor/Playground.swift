//
//  Playground.swift
//  iXor
//
//  Created by Mario Rotz on 08.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import UIKit
enum MazeElementType: Int {
    case space = 0,
    fish,
    chicken,
    map_1,
    map_2,
    map_3,
    map_4,
    mask,
    bad_mask,
    h_wave,
    v_wave,
    puppet,
    bomb,
    acid,
    transporter,
    player_1,
    player_2,
    exit,
    wall
}


class Playground: NSObject {
    
    let mazeElementToString : [Character : MazeElementType]=[ "_":MazeElementType.space,
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

    var title : String = ""
    var playgroundArray : Array<Array<MazeElementType>> = Array()
    var transporterCoordinates : Array<Array<MazeElementType>> = Array()
    
    var levelSuccess : [Int : (Int,Bool)] =  [Int : (Int,Bool)]() // level no : (number of moves, successful finished)

    
    var beam_from = Array<Array<Int>>()
    var beam_to =   Array<Array<Int>>()
    
    override init() {
        super.init()
        for _ in 0..<20 {
            beam_from.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
            beam_to.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
        }
    }
    
    
    func readLevelString(filepath: String) {
        let s = try! String(contentsOfFile: filepath)
        print(s)
        var commentMode = false
        var titel : String = ""
        var mazeString : String = ""
        for char in s.characters {
            if commentMode == true {
                if char == "#" {
                    commentMode = false
                } else {
                    titel.append(char)
                }
            } else
            {
                if char == "#" {
                    commentMode = true
                }
                else {
                    mazeString.append(char)
                }
            }
            
        }
        print(mazeString)
        var i = 0
        var localArray = Array<MazeElementType>()
        
       
        var x=0
        var index = 0
        for char in mazeString.characters {
            if char == "\n" {
                print("newline")
                if localArray.count>0
                {
                    self.playgroundArray.append(localArray)
                    i += 1;
                    localArray = Array<MazeElementType>()
                }
            }
            else
            if !(char == " ")
            {
                if !(char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" ) {
                    if let element = mazeElementToString[char]! as MazeElementType? {
                        localArray.append(element)
                        print("add element: \(element)")
                    }
                } else {
                    // Transporter coordinates!
                    
                    let kl = Int(String(char))
                    if x % 4 == 0 {
                        print("add beam from beam_from[\(index)][0]=\(kl):")
                        beam_from[index][0] = kl!;
                    } else
                    if x % 4 == 1 {
                        print("add beam from beam_from[\(index)][1]=\(kl):")
                        beam_from[index][1] = kl!;
                    }
                    else
                    if x % 4 == 2 {
                        print("add beam from beam_to[\(index)][0]=\(kl):")
                        beam_to[index][0] = kl!;
                    }
                    else
                    if x % 4 == 3 {
                        print("add beam from beam_to[\(index)][1]=\(kl):")
                        beam_to[index][1] = kl!;
                        index=index+1
                    }
                    x=x+1
                }
            }
        }
        self.title = titel
    }
    
    
    func readLevel(number: Int) {
        var file : String = ""
        if number>9 {
            file = "level\(number)"
        } else {
            file = "level0\(number)"
        }
        
        let s = try! String(contentsOfFile: Bundle.main.path(forResource: file, ofType: "xor")!)
        readLevelString(filepath: s)
    }
}


