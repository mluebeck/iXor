//
//  SpeechBubbleView.swift
//  iXor
//
//  Created by OSX on 03.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class SpeechBubbleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 20;
    }
    
    
      func draw3(_ rect: CGRect) {
        // Size of rounded rectangle
        let rectCornerRadius = CGFloat(30.0)
        let rectBgColor = UIColor.white
        let rectWidth:CGFloat = self.bounds.width-20
        let rectHeight:CGFloat = self.bounds.height-20
        
        // Find center of actual frame to set rectangle in middle
        let xf:CGFloat = (self.frame.width  - rectWidth)  / 2
        let yf:CGFloat = (self.frame.height - rectHeight) / 2
        
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.clear(rect)
        ctx.saveGState()
        
        let rect = CGRect(x: xf, y: yf, width: rectWidth, height: rectHeight)
        
        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: rectCornerRadius).cgPath
        
        ctx.addPath(clipPath)
        
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.strokePath()
        
        //ctx.setFillColor(rectBgColor.cgColor)
        //ctx.fillPath()
        ctx.closePath()

        
        
        ctx.restoreGState()
    }
    
    func draw2(_ rect:CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        let aRect = CGRect(x:2.0, y:2.0, width:(self.bounds.size.width * 0.95),height: (self.bounds.size.width * 0.6)) // set the rect with inset.
        ctx!.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0); //white fill
        //ctx!.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0); //black stroke
        ctx!.setLineWidth(2.0);
    
    
        ctx!.fillEllipse(in: aRect);
        ctx!.strokeEllipse(in: aRect);
    
        ctx!.beginPath();
        ctx?.move(to: CGPoint(x:self.bounds.size.width * 0.10, y:self.bounds.size.width * 0.48))
        ctx?.addLine(to: CGPoint(x:3.0, y:(self.bounds.size.height * 0.80)))
        ctx?.addLine(to: CGPoint(x:20.0,y:(self.bounds.size.height * 0.70)))
        ctx?.closePath()
        ctx?.fillPath()
    /*
        ctx!.beginPath()
        ctx?.move(to: CGPoint(x:(self.bounds.size.width * 0.10),y: (self.bounds.size.width * 0.48)))
        
        ctx?.addLine(to: CGPoint(x:3.0,y: (self.bounds.size.height * 0.80)))
        ctx!.strokePath();
   
        ctx!.beginPath();
        ctx?.move(to: CGPoint(x: 3.0, y:(self.bounds.size.height * 0.80)))
        ctx?.addLine(to: CGPoint(x:20.0, y:(self.bounds.size.height * 0.70)))
        ctx!.strokePath()
    */
    }
}
