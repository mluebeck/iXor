//
//  TouchSKView.swift
//  iXor
//
//  Created by OSX on 10.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

class TouchSKView: SKView {

    var path : UIBezierPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        self.isMultipleTouchEnabled=false // (2)
        self.backgroundColor=UIColor.white
        let path = UIBezierPath.init()
        path.lineWidth=2.0
        
       
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let  p = touch?.location(in: self)
        path?.move(to:p!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event:UIEvent?)
    {
        let touch = touches.first
        let  p = touch?.location(in: self)
        path?.addLine(to: p!) // (4)
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event:UIEvent?)
    {
        self.touchesMoved(touches,with:event)
    }
    
    func touchesCancelled(touches:NSSet,event:UIEvent)
    {
        self.touchesEnded(touches as! Set<UITouch>, with:event)
    }
}
