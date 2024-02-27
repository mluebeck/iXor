//
//  VolumeSlider.swift
//  Xanadoo
//
//  Created by Mario Rotz on 24.01.24.
//  Copyright © 2024 MarioRotz. All rights reserved.
//

import UIKit

extension UIView
 {
    func makeVertical()
    {
         transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
 }

extension UIImage {
    static func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
class VolumeSlider: UIView {
    var autolayouted = false
    let sliderMusic  = UISlider()
    let sliderSoundeffects  = UISlider()
    let text1Label = UILabel()
    let text2Label = UILabel()
    var margin = 0.0
    var volumeControl : VolumeControl?
    
    func set(minimumTrackTintColor:UIColor) {
        self.sliderMusic.minimumTrackTintColor = minimumTrackTintColor
        self.sliderSoundeffects.minimumTrackTintColor = minimumTrackTintColor
    }
    
    func set(maximumTrackTintColor:UIColor) {
        self.sliderMusic.maximumTrackTintColor = maximumTrackTintColor
        self.sliderSoundeffects.maximumTrackTintColor = maximumTrackTintColor
    }
    
    func set(thumbImage:UIImage) {
        sliderMusic.setThumbImage(thumbImage, for: UIControl.State.normal)
        sliderSoundeffects.setThumbImage(thumbImage, for: UIControl.State.normal)
    }
    
    override func setNeedsLayout() {
        //let margin = 25.0
        //self.sliderMusic.frame = CGRect(x: margin, y: 0, width:frame.size.width-2*margin , height: 20)
        //self.sliderSoundeffects.frame = CGRect(x: margin, y: 100, width:frame.size.width-2*margin , height: 20)
        self.setAutolayout()
    }
    
    func setAutolayout() {
        if autolayouted==false  {
            autolayouted = true
            self.sliderMusic.translatesAutoresizingMaskIntoConstraints = false
            self.sliderSoundeffects.translatesAutoresizingMaskIntoConstraints = false
            self.text1Label.translatesAutoresizingMaskIntoConstraints=false
            self.text2Label.translatesAutoresizingMaskIntoConstraints=false
            
            NSLayoutConstraint.activate([
                self.text1Label.topAnchor.constraint(equalTo: self.topAnchor,constant: 10.0),
                self.text1Label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10.0),
                self.text1Label.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10.0),
                self.text1Label.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            NSLayoutConstraint.activate([
                self.sliderMusic.topAnchor.constraint(equalTo: self.text1Label.bottomAnchor,constant: 0.0),
                self.sliderMusic.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10.0),
                self.sliderMusic.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10.0),
                self.sliderMusic.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            NSLayoutConstraint.activate([
                self.text2Label.bottomAnchor.constraint(equalTo: self.sliderSoundeffects.topAnchor,constant: -10.0),
                self.text2Label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10.0),
                self.text2Label.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10.0),
                self.text2Label.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            NSLayoutConstraint.activate([
                self.sliderSoundeffects.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -10.0),
                self.sliderSoundeffects.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10.0),
                self.sliderSoundeffects.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10.0),
                self.sliderSoundeffects.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }
    
    @IBAction func sliderMusicChanged() {
        self.volumeControl?.changed(value: Volume.music(changed: Double(self.sliderMusic.value)))
    }
    
    @IBAction func sliderSoundEffectsChanged() {
        self.volumeControl?.changed(value: Volume.sound(changed: Double(self.sliderSoundeffects.value)))
    }
     
    
    init(frame: CGRect,volumeControl:VolumeControl) {
        self.volumeControl = volumeControl
        super.init(frame: frame)
        self.backgroundColor = .white
        [self.sliderMusic,self.sliderSoundeffects].forEach { slider in
            slider.backgroundColor = .clear
            let image = UIImage.makeCircleWith(size:
                                                CGSize(width: 10.0, height: 10.0), backgroundColor:   UIColor.white)
            slider.setThumbImage(image, for: UIControl.State.normal)
            slider.minimumValueImage = UIImage(systemName: "speaker")
            slider.maximumValueImage = UIImage(systemName: "speaker.wave.3")
            slider.minimumTrackTintColor = .red
            slider.maximumTrackTintColor = .brown.withAlphaComponent(0.4)
            self.layer.cornerRadius = 20
            self.addSubview(slider)
        }
        
        self.layer.cornerRadius = 10
        self.text1Label.text = "Music"
        self.text2Label.text = "Soundeffects"
        self.text1Label.font = UIFont.init(name: "PressStart2P", size: 12.0)
        self.text2Label.font = UIFont.init(name: "PressStart2P", size: 12.0)
        self.addSubview(self.text1Label)
        self.addSubview(self.text2Label)
        
        self.sliderMusic.addTarget(self, action: #selector(sliderMusicChanged), for: .valueChanged)
        self.sliderSoundeffects.addTarget(self, action: #selector(sliderSoundEffectsChanged), for: .valueChanged)
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
