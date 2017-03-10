//
//  PlaygroundList.swift
//  iXor
//
//  Created by OSX on 20.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class PlaygroundList: NSObject,NSCoding
{
    var playgrounds : [Int: Playground]
    
    override init()
    {
        playgrounds = [Int: Playground]()
        super.init()
    }
    
    required init(coder: NSCoder)
    {
        self.playgrounds = coder.decodeObject(forKey: "playgrounds") as! [Int : Playground]
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.playgrounds, forKey: "playgrounds")
    }
}
