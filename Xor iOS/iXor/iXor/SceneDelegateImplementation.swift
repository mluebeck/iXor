//
//  SceneDelegateImplementation.swift
//  iXor
//
//  Created by OSX on 08.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

protocol SceneDelegate
{
    func updateViewController(event:MazeEvent)
    func updateViewController(type:MazeElementType)
    func playSoundAcid()
    func playSoundBomb()
    func doBombAnimation(element:MazeElement,block:@escaping ()->())

    func doAcidAnimation(element:MazeElement,block:@escaping ()->())
    func drawPlayer(position: PlaygroundPosition, previousPosition:PlaygroundPosition, player: Bool, beamed:Bool,completition:@escaping ()->())
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition)
    func drawSprite(element:MazeElement,
                    position:PlaygroundPosition,
                    duration:TimeInterval,
                    completed:(()->Void)?)
    func spritesToRemove(_ element:MazeElement)
    func animationCompleted(function: ((MazeElement,PlaygroundPosition)->Void)?)
}

class SceneDelegateImplementation: NSObject,SceneDelegate
{
    var scene : GameScene
    
    init(scene:GameScene)
    {
        self.scene = scene
        super.init()
    }
    
    func updateViewController(event:MazeEvent)
    {
        scene.updateViewController!(event)
    }
    
    func updateViewController(type:MazeElementType)
    {
        switch (type) {
        case MazeElementType.map_1:
            updateViewController(event: MazeEvent.map1_found)
            break
        case MazeElementType.map_2:
            updateViewController(event: MazeEvent.map2_found)
            break
        case MazeElementType.map_3:
            updateViewController(event: MazeEvent.map3_found)
            break
        case MazeElementType.map_4:
            updateViewController(event: MazeEvent.map4_found)
            break
        default:
            break
        }
    }
    
    func playSoundAcid()
    {
        scene.run(SKAction.playSoundFileNamed("acid.wav" ,waitForCompletion:false))
        
    }
    
    func playSoundBomb()
    {
        scene.run(SKAction.playSoundFileNamed("bomb.caf" ,waitForCompletion:false))
        
    }
    
    func doAcidAnimation(element:MazeElement,block:@escaping ()->())
    {
        if let sprite = element.sprite
        {
            scene.doAcidAnimation(sprite: sprite,block:block)
        }
    }
    func doBombAnimation(element:MazeElement,block:@escaping ()->())
    {
        if let sprite = element.sprite
        {
            scene.doBombAnimation(sprite: sprite,block:block)
        }
    }
    
    func drawPlayer(position: PlaygroundPosition, previousPosition:PlaygroundPosition, player: Bool, beamed:Bool,completition:@escaping ()->())
    {
        scene.drawPlayer(position: position, previousPosition:previousPosition, beamed:beamed, completition:completition)
    }
    
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition)
    {
        scene.moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func drawSprite(element:MazeElement,
                    position:PlaygroundPosition,
                    duration:TimeInterval,
                    completed:(()->Void)?)
    {
        scene.drawSprite(element:element,
                          position:position,
                          duration:duration,
                          completed:completed)
    }
    
    func spritesToRemove(_ element:MazeElement)
    {
        scene.spritesToRemove.append(element.sprite)
    }
    
    func animationCompleted(function: ((MazeElement,PlaygroundPosition)->Void)?)
    {
        scene.animationCompleted=function
    }

}
