//
//  PathSelector.swift
//  iXor
//
//  Created by OSX on 13.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

class PathSelector: NSObject {
    
    //var panGestureRecognizer  : UIPanGestureRecognizer?
    var longPressGestureRecognizer  : UILongPressGestureRecognizer?
    
    var intermediateAlreadySpriteDrawnQueue = [PlaygroundPosition : MazeElement]()
    var movingQueue = Array<PlayerMoveDirection>()
    var startDrawing = false
    var oldPosition : PlaygroundPosition?
    var oldcoordinates : CGPoint?
    var playground : Playground
    
    init(scene:SceneDelegate) {
        playground = scene.getSceneDataSource()
        playground.sceneDelegate = scene
        super.init()
        longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action:#selector(PathSelector.handleLongPressFrom(recognizer:)))
        longPressGestureRecognizer?.minimumPressDuration=0.01
        //panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action:#selector(PathSelector.handlePanFrom(recognizer:)))
        //panGestureRecognizer?.minimumNumberOfTouches = 1

    }
    
    func addGestureSelector(view:UIView)
    {
        view.addGestureRecognizer(longPressGestureRecognizer!)
        //view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    
    
    func handleLongPressFrom(recognizer:UILongPressGestureRecognizer)
    {
        if recognizer.state==UIGestureRecognizerState.ended {
            oldcoordinates=nil
            startDrawing = false
            for mazeElement in intermediateAlreadySpriteDrawnQueue.values {
                mazeElement.sprite?.removeFromParent()
            }
            intermediateAlreadySpriteDrawnQueue.removeAll()
            oldPosition = nil
            playground.movePlayer(queue: movingQueue)
            movingQueue.removeAll()
            
            return
        }
        
        
        let segment = playground.sceneDelegate?.segmentSize()
        let segmentX = segment?.x
        let segmentY = segment?.y
        let coordinates = playground.sceneDelegate?.fetchGestureTapCoordinates(gesture: longPressGestureRecognizer!)
        // recognizer.location(in: parentScene.view)
        let x = Double((coordinates?.x)!)//+Double(self.playground.cameraLeftTopPosition.x)
        //let y = Double(height-coordinates.y)//+Double(self.playground.cameraLeftTopPosition.y)
        
        print("handleLongPressFrom Tapped! \(x), \(coordinates?.y) ")
        let coordX = Int(x/Double(segmentX!))
        let coordY = Int(((round(Double(segmentY!)*Double((coordinates?.y)!))/Double(segmentY!))/Double(segmentY!)))
        print("handleLongPressFrom Tapped! \(coordX), \(coordY) ")
        
        let position = PlaygroundPosition(x:coordX+(playground.cameraLeftTopPosition.x),
                                          y:coordY+(playground.cameraLeftTopPosition.y))
        //let position2 = PlaygroundPosition(x:position.x,y:position.y-1)
        
        print("position: \(position)")
        
        if startDrawing == false { //lines.count==0 {
            // begin drawing
            print("Begin drawing!")
            let e = playground.element(position: position)
            print("element : \(e!)")
            if !(e?.mazeElementType == MazeElementType.player_1 || e?.mazeElementType == MazeElementType.player_2)
            {
                return
            }
            //self.moving(position: position)
        }
        else
        {
            // print("continue drawing!")
            let e = playground.element(position: position)
            print("element : \(e!)")
            
            var deltax = true
            var deltay = true
            var deltaBoth = false
            if let oldPos = oldPosition {
                if ((oldPos.y > position.y + 1) || (oldPos.y < position.y - 1)) {
                    deltay=false
                }
                if ((oldPos.x > position.x + 1) || (oldPos.x < position.x - 1)) {
                    deltax=false
                }
                if oldPos.x==position.x+1 || oldPos.x==position.x-1 {
                    if oldPos.y==position.y+1 || oldPos.y==position.y-1
                    {
                        deltaBoth = true
                    }
                }
            }
            
            if (deltax==false || deltay == false || deltaBoth==true)
            {
                return
            }
            
            if (e?.mazeElementType == MazeElementType.wall || e?.mazeElementType == MazeElementType.player_1 || e?.mazeElementType == MazeElementType.player_2)
            {
                if intermediateAlreadySpriteDrawnQueue.count == 1
                {
                    if let oldPos = oldPosition
                    {
                        let mazeElement = intermediateAlreadySpriteDrawnQueue[oldPos]
                        mazeElement?.sprite?.removeFromParent()
                        intermediateAlreadySpriteDrawnQueue[oldPos]=nil
                    }
                }
                return
            }
            else
            if intermediateAlreadySpriteDrawnQueue[position] == nil
            {
                let edgeSprite = EdgeSprite.init()
                edgeSprite.update(number:intermediateAlreadySpriteDrawnQueue.count+1)
                edgeSprite.zPosition=1
                playground.sceneDelegate?.addChild(edgeSprite)
                let mazeElement = MazeElement(mazeElementType: MazeElementType.redCorner, sprite: edgeSprite)
                intermediateAlreadySpriteDrawnQueue[position] = mazeElement
                
                self.moving(position: position)
                
                print("-> \(intermediateAlreadySpriteDrawnQueue.count)")
                playground.sceneDelegate?.drawRelativeToCamera(sprite: edgeSprite, element:mazeElement, position: position, duration: 0.0, completed: nil)
            }
            else
            {
                if oldPosition != position && oldPosition != nil
                {
                    print("Schon drin, also nichts tun \(intermediateAlreadySpriteDrawnQueue.count)")
                    let mazeElement = intermediateAlreadySpriteDrawnQueue[oldPosition!]
                    mazeElement?.sprite?.removeFromParent()
                    intermediateAlreadySpriteDrawnQueue[oldPosition!]=nil
                    movingQueue.removeLast()
                }
            }
            if intermediateAlreadySpriteDrawnQueue.count==0
            {
                oldPosition = nil
            }
            else
            {
                oldPosition = position
            }
            return
        }
        
        if oldcoordinates != nil
        {
            startDrawing = true
        }
        oldcoordinates = coordinates
    }
    
    func round40(_ x:Double)->Double
    {
        return round(x/40.0)*40.0
    }
    
    func moving(position:PlaygroundPosition)
    {
        var move = PlayerMoveDirection.UP
        var thePosition = playground.playerPosition
        
        if let oldPs = oldPosition
        {
            thePosition = oldPs
        }
        
        if thePosition.x==position.x
        {
            if thePosition.y<position.y
            {
                move = PlayerMoveDirection.DOWN
            }
            else
            {
                move = PlayerMoveDirection.UP
            }
        }
        
        if thePosition.y==position.y
        {
            if thePosition.x<position.x
            {
                move = PlayerMoveDirection.RIGHT
            }
            else
            {
                move = PlayerMoveDirection.LEFT
            }
        }
        movingQueue.append(move)
    }
//    func handlePanFrom(recognizer:UIPanGestureRecognizer)
//    {
//        let coordinates = recognizer.translation(in: parent Scene.view)
//        print("handlePanFrom Tapped! \(coordinates) ")
//    }

    
}
