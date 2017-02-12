//
//  EdgeSprite.swift
//  iXor
//
//  Created by OSX on 12.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import SpriteKit

class EdgeSprite: SKSpriteNode {
    var number : Int
    var numberLabel = SKLabelNode(fontNamed:"Press Start 2P")
    
    override public init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        number=1
        super.init(texture: texture, color: color, size: size)
        initialize()
    }
    
    required init(coder:NSCoder)
    {
        number=1
        super.init(coder: coder)!
        initialize()
    }

    init() {
        number=1
        super.init(texture:SKTexture.init(imageNamed: "redEdges"), color:UIColor.clear, size:CGSize(width:40,height:40))
        initialize()
    }
    
    func update(number:Int)
    {
        self.number=number
        numberLabel.text = String(number)
    }
    
    func initialize()
    {
        numberLabel.text = String(number)
        numberLabel.position=CGPoint(x:5,y:5)
        numberLabel.fontSize = 10;
        numberLabel.horizontalAlignmentMode=SKLabelHorizontalAlignmentMode.center;
        numberLabel.verticalAlignmentMode=SKLabelVerticalAlignmentMode.center;
        numberLabel.fontColor = SKColor.white
        self.addChild(numberLabel)
    }
}
