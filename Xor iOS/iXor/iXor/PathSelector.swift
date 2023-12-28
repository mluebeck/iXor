//
//  PathSelector.swift
//  iXor
//
//  Created by OSX on 13.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

extension PathSelector : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if touch.view is UIButton
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    
}

class PathSelector: NSObject  {
    
    //var panGestureRecognizer  : UIPanGestureRecognizer?
    var longPressGestureRecognizer  : UILongPressGestureRecognizer?
    var tapGestureRecognizer  : UITapGestureRecognizer?
    var doubleTapGestureRecognizer  : UITapGestureRecognizer?

    var intermediateAlreadySpriteDrawnQueue = [Int : MazeElement]()
    var movingQueue = Array<PlayerMoveDirection>()
    var startDrawing = false
    var oldPosition : PlaygroundPosition?
    var oldcoordinates : CGPoint?
    var playground : Playground
    
    init(scene:SceneDelegate) {
        playground = scene.getSceneDataSource()
        playground.sceneDelegate = scene
        super.init()
        
        self.longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action:#selector(PathSelector.handleLongPressFrom(recognizer:)))
        self.longPressGestureRecognizer?.minimumPressDuration=0.5
        self.longPressGestureRecognizer?.delegate = self
       
        self.tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(PathSelector.handleTapFrom(recognizer:)))
        self.tapGestureRecognizer?.numberOfTapsRequired = 1
        self.tapGestureRecognizer?.delegate = self
       
        self.doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(PathSelector.handleDoubleTapFrom(recognizer:)))
        self.doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        self.doubleTapGestureRecognizer?.delegate = self
       
        
    }
    
    
    
    func addGestureSelector(view:UIView)
    {
        view.addGestureRecognizer(longPressGestureRecognizer!)
        view.addGestureRecognizer(tapGestureRecognizer!)
        //view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc func handleDoubleTapFrom(recognizer:UILongPressGestureRecognizer)
    {
        
    }
    
    func handleDoubleTap()
    {
        self.playground.changePlayerVisible()
    }
    @objc func handleTapFrom(recognizer:UILongPressGestureRecognizer)
    {
       print("Tap!")
        let segment = playground.sceneDelegate?.segmentSize()
        let segmentX = segment?.x
        let segmentY = segment?.y
        let coordinates = playground.sceneDelegate?.fetchGestureTapCoordinates(gesture: longPressGestureRecognizer!)
        // recognizer.location(in: parentScene.view)
        let x = Double((coordinates?.x)!)//+Double(self.playground.cameraLeftTopPosition.x)
        //let y = Double(height-coordinates.y)//+Double(self.playground.cameraLeftTopPosition.y)
        
        //print("handleLongPressFrom Tapped! \(x), \(coordinates?.y) ")
        let coordX = Int(x/Double(segmentX!))
        let coordY = Int(((round(Double(segmentY!)*Double((coordinates?.y)!))/Double(segmentY!))/Double(segmentY!)))
        print("Tap! \(coordX), \(coordY) ")
        print("cameraPosition: \(playground.cameraLeftTopPosition.x), \(playground.cameraLeftTopPosition.y) ")
        
        let xPos = coordX+playground.cameraLeftTopPosition.x
        let yPos = coordY+playground.cameraLeftTopPosition.y
        
        let position = PlaygroundPosition(x:xPos,
                                          y:yPos)
        //let position2 = PlaygroundPosition(x:position.x,y:position.y-1)
        
        print("position: \(position) \(playground.playerPosition)")
        if position.x == playground.playerPosition.x && position.y == playground.playerPosition.y {
            self.handleDoubleTap()
            return
        }
        let xTap = position.x
        let yTap = position.y
        
        let playerX = playground.playerPosition.x
        let playerY = playground.playerPosition.y
        
        if xTap == playerX {
            if yTap < playerY {
                self.moving(position: PlaygroundPosition(x:playerX  , y:playerY-1  ))
                playground.movePlayer(queue: movingQueue)
                movingQueue.removeAll()
            }
            if yTap > playerY {
                self.moving(position: PlaygroundPosition(x:playerX  , y:playerY+1  ))
                playground.movePlayer(queue: movingQueue)
                movingQueue.removeAll()
            }
        }
        
        if yTap == playerY {
            if xTap < playerX {
                self.moving(position: PlaygroundPosition(x:playerX-1  , y:playerY  ))
                playground.movePlayer(queue: movingQueue)
                movingQueue.removeAll()
            }
            if xTap > playerX {
                self.moving(position: PlaygroundPosition(x:playerX+1  , y:playerY  ))
                playground.movePlayer(queue: movingQueue)
                movingQueue.removeAll()
            }
        }
        
     }
    
    
    @objc func handleLongPressFrom(recognizer:UILongPressGestureRecognizer)
    {
        print("handleLongPressFrom!")

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
        
        //print("handleLongPressFrom Tapped! \(x), \(coordinates?.y) ")
        let coordX = Int(x/Double(segmentX!))
        let coordY = Int(((round(Double(segmentY!)*Double((coordinates?.y)!))/Double(segmentY!))/Double(segmentY!)))
        print("handleLongPressFrom Tapped! \(coordX), \(coordY) ")
        print("cameraPosition: \(playground.cameraLeftTopPosition.x), \(playground.cameraLeftTopPosition.y) ")
        
        let xPos = coordX+playground.cameraLeftTopPosition.x
        let yPos = coordY+playground.cameraLeftTopPosition.y
        
        let position = PlaygroundPosition(x:xPos,
                                          y:yPos)
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
            
            if ((playground.akt_spieler_ist_playerOne==true && (e?.mazeElementType == MazeElementType.player_2)) ||
                (playground.akt_spieler_ist_playerOne==false && (e?.mazeElementType == MazeElementType.player_1)))
                
            {
                playground.changePlayerVisible()
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
                        let mazeElement = intermediateAlreadySpriteDrawnQueue[oldPos.hashValue]
                        mazeElement?.sprite?.removeFromParent()
                        intermediateAlreadySpriteDrawnQueue[oldPos.hashValue]=nil
                    }
                }
                return
            }
            else
            if intermediateAlreadySpriteDrawnQueue[position.hashValue] == nil
            {
                let edgeSprite = EdgeSprite.init()
                edgeSprite.update(number:intermediateAlreadySpriteDrawnQueue.count+1)
                edgeSprite.zPosition=1
                playground.sceneDelegate?.addChild(edgeSprite)
                let mazeElement = MazeElement(mazeElementType: MazeElementType.redCorner, sprite: edgeSprite)
                intermediateAlreadySpriteDrawnQueue[position.hashValue] = mazeElement
                
                self.moving(position: position)
                
                print("2-> \(position.hashValue) \(intermediateAlreadySpriteDrawnQueue.count)")
                //playground.sceneDelegate?.drawRelativeToCamera(sprite: edgeSprite, element:mazeElement, position: position, duration: 0.0, completed: nil)
                
                playground.sceneDelegate?.drawSprite(element:mazeElement,
                                 position:position,
                                 duration:0.0,
                                 completed:nil,
                                 relativeToCamera:true)
                
            }
            else
            {
                print("-> \(position)")
                if let op = oldPosition, op != position
                {
                    print("Schon drin, also nichts tun \(intermediateAlreadySpriteDrawnQueue.count)")
                    let mazeElement = intermediateAlreadySpriteDrawnQueue[(oldPosition?.hashValue)!]
                    mazeElement?.sprite?.removeFromParent()
                    intermediateAlreadySpriteDrawnQueue[(oldPosition?.hashValue)!]=nil
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
}
