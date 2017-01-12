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

struct PlaygroundPosition {
    var positionX : Int
    var positionY : Int
}

class Playground: NSObject {
    
    struct Constants {
        static let groesse = 32;         // playground dimensions (=32x32)
        static let sichtbareGroesse = 8  // visible playground
    }
    
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
    var playgroundArray : Array<Array<MazeElementType>> = Array()  // Das spielfeld
    
    var successfulFinished = false
    var numberOfMoves = 0
    
    var beam_from = Array<Array<Int>>() // transporter start co-ordinates
    var beam_to =   Array<Array<Int>>() // transporter target co-ordinates
    
    
    
    
    var nothing_loaded = true         // =1:show start level, else greeting screen
    var karten_flag = false;          // =1: a map has been collected, so update the status display
    var akt_spieler = false;          // =0:player 1,  1:player 2
    var ende_erreicht = false;        // =0: start
    // =1: all masks collected !
    // =99: one player is dead and one has just been killed
    //      OR >1000 moves: You failed !
    // =98: one player is dead and the other alive
    var anzahl_spielzuege = 0                    // How many moves have you done ?
    var anzahl_masken = 0             // Number of masks available in a level
    var invisible = false             // have you collected a 'bad mask' all walls becomes invisible
    var karten = 0                    // how many map parts have you collected ?
    var gesammelte_masken = 0         // how many masks have you collected ?
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
    
    // screen co-ordinates of the player
    var playerCoordinates : PlaygroundPosition
    
    // old screen co-ordinates
    var playerCoordinatesOld : PlaygroundPosition
    
    var clipper : PlaygroundPosition  // the part of the playground, which should be shown
    var playerOne : PlaygroundPosition // current and startposition of Player One
    var playerTwo : PlaygroundPosition // current and startposition of Player Two
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
        self.playerOne = PlaygroundPosition(positionX: 0,positionY: 0)
        self.playerTwo = PlaygroundPosition(positionX: 0,positionY: 0)
        self.clipper   = PlaygroundPosition(positionX: 0, positionY: 0)
        self.playerCoordinates = PlaygroundPosition(positionX: -1, positionY: -1)
        self.playerCoordinatesOld = PlaygroundPosition(positionX: -1, positionY: -1)

        super.init()

        for _ in 0..<20 {
            beam_from.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
            beam_to.append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,])
        }
    }
    
    func readLevelString(filepath: String) {
        let s = try! String(contentsOfFile: filepath)
        print(s)
        
        var positionX = 0
        var positionY = 0
        
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
                positionX = 0
                positionY = positionY + 1
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
                if char == "a" {
                    self.playerOne.positionX = positionX
                    self.playerOne.positionY = positionY
                } else
                if char == "b" {
                    self.playerTwo.positionX = positionX
                    self.playerTwo.positionY = positionY
                } else
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
            positionX = positionX + 1

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


