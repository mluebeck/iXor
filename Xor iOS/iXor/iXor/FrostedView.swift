//
//  FrostedView.swift
//  iXor
//
//  Created by OSX on 27.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class FrostedView: UIView {

    var imageView:UIImageView?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame:CGRect) {
        super.init(frame:frame)
        //let  snapshotView = self.superview
        //createFrostedBackground()
    }
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //createFrostedBackground()
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        //self.createFrostedBackground()

    }
    
    func show(visible:Bool) {
        if visible == true {
            self.createFrostedBackground()
            self.isHidden=false
        }
        else
        {
            self.isHidden=true
            self.imageView?.removeFromSuperview()
            self.imageView=nil
        }
    }
    
    private func createFrostedBackground() {
        if let sview=self.superview {
            if self.imageView == nil {
                let imgaa = sview.re_screenshot()
                let color = UIColor.white
                color.withAlphaComponent(0.75)
                let newbackground = imgaa?.re_applyBlur(withRadius: 10.0,
                                                        tintColor: nil,
                                                        saturationDeltaFactor: 1.8,
                                                        maskImage: nil)
                self.imageView = UIImageView(image: newbackground)
                imageView?.frame = CGRect(x: 0, y: 0, width: sview.frame.size.width, height: sview.frame.size.height)
                imageView?.contentMode = UIViewContentMode.scaleToFill
                imageView?.clipsToBounds = true
                imageView?.image = newbackground
                //imageView?.center = sview.center
                imageView?.alpha = 0.5
                print(imageView?.frame.origin ?? "no values")
                self.addSubview(imageView!)
                self.sendSubview(toBack: imageView!)
                self.addSubview(imageView!)
                self.sendSubview(toBack: imageView!)
            }
        }
    }

    /*
    private func createFrostedBackground() {
        if let sview=self.superview {
            if self.imageView == nil {
                let  snapshotView:UIView = sview.snapshotView(afterScreenUpdates: true)!
        
                UIGraphicsBeginImageContextWithOptions(sview.bounds.size, true, 0.0)
                snapshotView.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
                let imgaa  = UIGraphicsGetImageFromCurrentImageContext()
                let  ciimage  = CIImage(image: imgaa!)
                let filter  = CIFilter(name:"CIGaussianBlur")
                filter?.setDefaults()
                filter?.setValue(ciimage, forKey: kCIInputImageKey)
                filter?.setValue(20, forKey: kCIInputRadiusKey)
                let  outputImage : CIImage = filter!.outputImage!;
                
                //let rect: CGRect = CGRect(x:-100, y:-100, width:1040, height:1040)
                
                // Create bitmap image from context using the rect
                //let cimage = outputImage.cropping(to: rect)
                
                // Create a new image based on the imageRef and rotate back to the original orientation
                let newbackground  = UIImage(ciImage:outputImage)

                
                //let newbackground :UIImage = UIImage(ciImage: outputImage)
                UIGraphicsEndImageContext();
            
                self.imageView = UIImageView(image: newbackground)
                imageView?.frame = sview.frame //CGRect(x: 0, y: 0, width: sview.frame.size.width, height: sview.frame.size.height)
                imageView?.contentMode = UIViewContentMode.scaleToFill
                imageView?.clipsToBounds = true
                imageView?.image = newbackground
                imageView?.center = sview.center
            
            
                self.addSubview(imageView!)
                self.sendSubview(toBack: imageView!)
            }
        }
    }
     */
    
}
