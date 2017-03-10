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
    func playApplause()
    func doAcidAnimation(element:MazeElement,block:@escaping ()->())
    func doBombAnimation(element:MazeElement,block:@escaping ()->())
    
    func addChild(_ sprite: SKNode)
    
    func drawPlayer(position: PlaygroundPosition, previousPosition:PlaygroundPosition, player: Bool, beamed:Bool,completition:@escaping ()->())
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition)
    func drawSprite(element:MazeElement,
                    position:PlaygroundPosition,
                    duration:TimeInterval,
                    completed:(()->Void)?,relativeToCamera:Bool)
    func spritesToRemove(_ element:MazeElement)
    
    func animationCompleted(function: ((MazeElement?,PlaygroundPosition)->Void)?)
    
    func fetchGestureTapCoordinates(gesture:UIGestureRecognizer) -> CGPoint
    
    func getSceneDataSource() -> Playground
    func segmentSize() -> (x:CGFloat,y:CGFloat)
}

class SceneDelegateImplementation: NSObject,SceneDelegate
{
    var scene : GameScene
    
    init(scene:GameScene)
    {
        self.scene = scene
        super.init()
    }
    
    func getSceneDataSource() -> Playground {
        return scene.playground
    }
    
    func segmentSize() -> (x:CGFloat,y:CGFloat)
    {
        return scene.segmentSize()
    }
    
    
    
    func fetchGestureTapCoordinates(gesture:UIGestureRecognizer) -> CGPoint
    {
        return gesture.location(in: self.scene.view)
    }
    
    func addChild(_ sprite: SKNode) {
        scene.addChild(sprite)
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
        scene.run(SKAction.playSoundFileNamed("acid2.wav" ,waitForCompletion:false))
        
    }
    
    func playSoundBomb()
    {
        scene.run(SKAction.playSoundFileNamed("bomb.caf" ,waitForCompletion:false))
        
    }
    
    func playApplause()
    {
        scene.run(SKAction.playSoundFileNamed("applause.wav" ,waitForCompletion:false))
        
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
                    completed:(()->Void)?, relativeToCamera:Bool)
    {
        scene.drawSprite(element:element,
                          position:position,
                          duration:duration,
                          completed:completed,relativeToCamera:relativeToCamera)
    }
    
    func spritesToRemove(_ element:MazeElement)
    {
        scene.spritesToRemove.append(element.sprite)
    }
    
    func animationCompleted(function: ((MazeElement?,PlaygroundPosition)->Void)?)
    {
        scene.animationCompleted=function
    }

}
