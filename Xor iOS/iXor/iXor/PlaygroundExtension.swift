//
//  PlaygroundExtension.swift
//  iXor
//
//  Created by OSX on 19.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

extension Playground {
    
    func testChickenAcidFishBomb()
    {
        let playgroundCopy = self.playgroundArray.map{$0}
        var x=0
        var y=0
        for _ in 0..<PlaygroundBuilder.Constants.groesseX
        {
            for _ in 0..<PlaygroundBuilder.Constants.groesseY
            {
                let currentPosition = PlaygroundPosition(x:x,y:y)
                let mazetype = playgroundCopy[y][x]
                
                //print("testing \(x), \(y).... \(mazetype?.mazeElementType)")
                
                if mazetype.mazeElementType==MazeElementType.chicken || mazetype.mazeElementType==MazeElementType.acid
                {
                    let leftPosition = Playground.left(position: currentPosition)
                    let leftElement = playgroundCopy[leftPosition.y][leftPosition.x]
                    if leftElement.mazeElementType == MazeElementType.space || leftElement.mazeElementType == MazeElementType.v_wave
                    {
                        //x += 1
                        self.increaseEventCounter(comment: "chicken run 1!", element: MazeElementType.fish)
                        chickenRun(position: currentPosition,juststarted: true)
                    }
                }
                else
                    if mazetype.mazeElementType==MazeElementType.fish || mazetype.mazeElementType==MazeElementType.bomb
                    {
                        let downPosition = Playground.down(position: currentPosition)
                        let downElement = playgroundCopy[downPosition.y][downPosition.x]
                        if downElement.mazeElementType == MazeElementType.space || downElement.mazeElementType == MazeElementType.h_wave
                        {
                            //y += 1
                            self.increaseEventCounter(comment: "fish fall!", element: MazeElementType.fish)
                            fishFall(position: currentPosition,juststarted:true)
                        }
                }
                y=y+1
                if y == PlaygroundBuilder.Constants.groesseY
                {
                    break
                }
            }
            x=x+1
            y=0
            if x==PlaygroundBuilder.Constants.groesseX
            {
                break
            }
        }
    }

    func testForChickenOrFishAction(position:PlaygroundPosition,justStarted:Bool,causedby:MazeElementType)
    {
        let sourceType = causedby
        
        if let mazeType = elementAboveFrom(position: position)?.mazeElementType
        {
            // ist über dem leeren Feld ein Fish/Bombe?
            // fish, bombe fällt runter von selbst
            if mazeType==MazeElementType.fish || mazeType == MazeElementType.bomb
            {
                if justStarted==true || sourceType==MazeElementType.chicken || sourceType==MazeElementType.acid
                 {
                    self.increaseEventCounter(comment: "fish fall", element: mazeType)
                }
                fishFall(position:Playground.up(position: position),juststarted: justStarted)
                return
            }
        }
        
        if let mazeType = elementRightFrom(position: position)?.mazeElementType
        {
            // chicken, acid fliegen nach links von selbst
            // puppet in jede richtung, aber nur wenn sie angeschubst werden
            if mazeType==MazeElementType.chicken || mazeType == MazeElementType.acid
            {
                if justStarted==true || sourceType==MazeElementType.fish || sourceType==MazeElementType.bomb
                {
                    self.increaseEventCounter(comment: "chicken run 4!", element: mazeType)
                }
                chickenRun(position:Playground.right(position: position),juststarted: justStarted)
                return
            }
        }
    }
    
    func doTheFishChickenMoving(position:PlaygroundPosition)
    {
        let upFromPosition = Playground.up(position: position)
        let upElement = element(position: upFromPosition)
        if let element = upElement?.mazeElementType
        {
            if element == MazeElementType.fish || element == MazeElementType.bomb
            {
                self.increaseEventCounter(comment: "fish fall!", element: element)
                self.fishFall(position: upFromPosition,juststarted: true)
                return
            }
        }
        
        let rightFromPosition = Playground.right(position: position)
        let rightElement = element(position: rightFromPosition)
        if let element = rightElement?.mazeElementType
        {
            if element == MazeElementType.chicken || element == MazeElementType.acid
            {
                self.increaseEventCounter(comment: "chicken run 3!", element: MazeElementType.chicken)
                self.chickenRun(position: rightFromPosition,juststarted: true)
                return
            }
        }
        self.endOfAnimation()
    }
    
    func chickenRun(position:PlaygroundPosition,juststarted:Bool)
    {
        // lasse das chicken so lange rennen, bis ein Hindernis da ist
        let leftposition = Playground.left(position: position)
        let chickenElement = self.element(position: position)
        let leftElement = self.element(position:leftposition)                                  // space ?
        var leftElementType = MazeElementType.space
        if let elementtype = leftElement?.mazeElementType
        {
            leftElementType = elementtype
        }
        
        switch(leftElementType)
        {
        case MazeElementType.v_wave,MazeElementType.space:
            // Lösche alte Position des Huhns
            createEmptySpaceOnPlayground(position: position)
            // Bewege Huhn um eins nach links
            changeElementAndDrawSprite(position: leftposition,
                                       element: chickenElement!,
                                       duration: Playground.chickenDuration,
                                       completition: {
                                        self.chickenRun(position:leftposition,juststarted: false)
                                        self.testForChickenOrFishAction(position:position,justStarted:juststarted,causedby: (chickenElement?.mazeElementType)!)
            })
            return
        case MazeElementType.player_1, MazeElementType.player_2:
            if juststarted==false
            {
                killCurrentPlayer(leftElementType)
                createEmptySpaceOnPlayground(position: position)
                // Bewege Huhn um eins nach links
                leftElement?.sprite?.removeFromParent()
                changeElement(position: leftposition, element: chickenElement!)
                sceneDelegate?.drawSprite(element:chickenElement!,
                                          position:leftposition,
                                          duration:Playground.chickenDuration,
                                          completed:{
                                            self.chickenRun(position:leftposition,juststarted: false)
                                            self.testForChickenOrFishAction(position:position,justStarted:false,causedby: (chickenElement?.mazeElementType)!)
                })
                return
            }
            else
            {
                createEmptySpaceOnPlayground(position: position)
                changeElementAndDrawSprite(position: position,
                                           element: chickenElement!,
                                           duration: Playground.chickenDuration,
                                           completition: {
                })
                return
                
            }
            
        case MazeElementType.acid:
            if juststarted==false && (chickenElement?.mazeElementType!) != MazeElementType.space {
                acidCorrosive(element:leftElement!,position:position,causedBy: MazeElementType.chicken)
                self.decreaseEventCounter(comment: "chicken run acid", element: MazeElementType.chicken)
                
            }
            break
        case MazeElementType.bomb:
            if juststarted==false && (chickenElement?.mazeElementType!) != MazeElementType.space {
                bombExplode(element:leftElement!,position:position,causedBy: MazeElementType.chicken)
                self.decreaseEventCounter(comment: "chicken run bomb", element: MazeElementType.chicken)
            }
            break
            
        // END OF CHICKEN RUN REACHED !
        case MazeElementType.wall,
             MazeElementType.h_wave,
             MazeElementType.fish,
             MazeElementType.chicken,
             MazeElementType.puppet:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: position, element: chickenElement!, duration: Playground.chickenDuration, completition: {
                self.decreaseEventCounter(comment: "chicken run end", element: MazeElementType.chicken)
            })
            return
        default:
            return
        }
        return
        
    }
    
    func fishFall(position:PlaygroundPosition,juststarted:Bool)
    {
        let bottomposition = Playground.down(position: position)
        let fishOrBombElement = self.element(position: position)
        let bottomElement = self.element(position:bottomposition)                                  // space ?
        var elementType = MazeElementType.space
        if let elementtype = bottomElement?.mazeElementType {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.h_wave,MazeElementType.space:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: bottomposition,
                                       element: fishOrBombElement!,
                                       duration: Playground.fishDuration,
                                       completition: {
                                        self.fishFall(position:bottomposition,juststarted: false)
                                        self.testForChickenOrFishAction(position:position,justStarted:juststarted,causedby:(fishOrBombElement?.mazeElementType)!)
            })
            return
        case MazeElementType.player_1, MazeElementType.player_2:
            if juststarted==false
            {
                killCurrentPlayer(elementType)
                createEmptySpaceOnPlayground(position: position)
                // Bewege Huhn um eins nach links
                bottomElement?.sprite?.removeFromParent()
                changeElement(position: bottomposition, element: fishOrBombElement!)
                sceneDelegate?.drawSprite(element:fishOrBombElement!,
                                          position:bottomposition,
                                          duration:Playground.fishDuration,
                                          completed:{
                                            self.fishFall(position:bottomposition,juststarted: false)
                                            self.testForChickenOrFishAction(position:position,justStarted:false,causedby: (fishOrBombElement?.mazeElementType)!)
                })
                return
            }
            else
            {
                createEmptySpaceOnPlayground(position: position)
                changeElementAndDrawSprite(position: position,
                                           element: fishOrBombElement!,
                                           duration: Playground.fishDuration,
                                           completition: {
                })
            }
            return
        case MazeElementType.acid:
            if juststarted==false && (fishOrBombElement?.mazeElementType!) != MazeElementType.space
            {
                acidCorrosive(element:bottomElement!,position:position,causedBy:MazeElementType.fish)
                self.decreaseEventCounter(comment:"move fish down",element: MazeElementType.fish)
            }
            return
            
        case MazeElementType.bomb:
            if juststarted==false && (fishOrBombElement?.mazeElementType!) != MazeElementType.space
            {
                bombExplode(element:bottomElement!,position:position,causedBy:MazeElementType.fish)
                self.decreaseEventCounter(comment:"move fish down, der die Bombe zur Explosion gebracht hat",element: MazeElementType.fish)
            }
            return
            
        case MazeElementType.wall,
             MazeElementType.v_wave,
             MazeElementType.fish,
             MazeElementType.chicken,
             MazeElementType.puppet,
             MazeElementType.bad_mask,
             MazeElementType.mask:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: position, element: fishOrBombElement!, duration: Playground.fishDuration, completition: {
                self.decreaseEventCounter(comment:"move fish down",element: elementType)
            })
            return
        default:
            return
        }
    }
    
    func puppetMove(position:PlaygroundPosition,direction:PlayerMoveDirection)
    {
        //
        let newPosition  = Playground.newPosition(position: position, direction: direction)
        let puppetElement     = self.element(position: position)
        let newElement   = self.element(position:newPosition)                                  // space ?
        var elementType     = MazeElementType.space
        if let elementtype  = newElement?.mazeElementType
        {
            elementType = elementtype
        }
        switch(elementType)
        {
        case MazeElementType.space:
            // Lösche alte Position des Fishes
            createEmptySpaceOnPlayground(position: position)
            newElement?.removeSprite()
            // Bewege Fish um eins nach unten
            self.increaseEventCounter(comment: "puppet moving", element:MazeElementType.puppet)
            changeElementAndDrawSprite(position: newPosition,
                                       element: puppetElement!,
                                       duration: Playground.puppetMove,
                                       completition: {
                                        self.puppetMove(position: newPosition, direction: direction)
            })
            
            return
            
        default:
            createEmptySpaceOnPlayground(position: position)
            changeElementAndDrawSprite(position: position, element: puppetElement!, duration: Playground.puppetMove, completition: {
                self.decreaseEventCounter(comment: "puppet done", element: MazeElementType.puppet)
            })
            return
        }
    }
    
    func bombExplode(element:MazeElement,position:PlaygroundPosition,causedBy:MazeElementType)
    {
        //        increaseEventCounter(comment: "bomb explode", element: MazeElementType.exit)
        if let _ = element.sprite
        {
            if causedBy==MazeElementType.fish || causedBy == MazeElementType.bomb
            {
                let positionDown = Playground.down(position: position) // here is the bomb!
                
                self.createWallOnPlayground(position: positionDown)
                
                sceneDelegate?.playSoundBomb()
                
                // remove all items the bomb destroyed
                self.cleanBombArea(position,positionDown)
                
                self.increaseEventCounter(comment: "bomb!", element:causedBy)

                self.testForChickenOrFishAction(position: Playground.left(position: positionDown),justStarted:true,causedby: causedBy)
                self.testForChickenOrFishAction(position: Playground.right(position: positionDown),justStarted:true,causedby: causedBy)
                self.testForChickenOrFishAction(position: position,justStarted:true,causedby: causedBy)
               
                
                self.createEmptySpaceOnPlayground(position: positionDown)
                sceneDelegate?.doBombAnimation(element: element,block:{
                    
                    element.sprite?.removeFromParent()
                    
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: positionDown,duration:0.0) // bomb

                    
                    self.testForChickenOrFishAction(position: positionDown,justStarted:true,causedby: causedBy)
                   
                    self.decreaseEventCounter(comment:"bomb exploded",element: causedBy)
                    
                    
                } )
                return
            }
            else
            {   // chicken or acid
                let positionLeft = Playground.left(position: position) // position bomb
                
                self.cleanBombArea(position,positionLeft)
                
                self.testForChickenOrFishAction(position: Playground.left(position: positionLeft),justStarted:true,causedby: causedBy)
                self.testForChickenOrFishAction(position: Playground.right(position: positionLeft),justStarted:true,causedby: causedBy)
                self.createEmptySpaceOnPlayground(position: positionLeft)
                self.increaseEventCounter(comment: "bomb!", element: MazeElementType.bomb)
                
                sceneDelegate?.playSoundBomb()
                
                sceneDelegate?.doBombAnimation(element:element,block:{
                    element.sprite?.removeFromParent()
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: positionLeft,duration:0.0) // bomb
                    self.testForChickenOrFishAction(position: positionLeft,justStarted:false,causedby: causedBy)
                    self.decreaseEventCounter(comment:"bomb exploded",element: causedBy)
                    
                } )
                return
                
            }
        }
    }
    
    func cleanBombArea(_ position:PlaygroundPosition,_ positionBomb:PlaygroundPosition)
    {
        let positionLeft = positionBomb// position bomb
        self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // bomb
        self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.left(position: positionLeft),duration:0.9) //  bomb left
        self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.right(position: positionLeft),duration:0.9) // bomb right
    }
    
    func acidCorrosive(element:MazeElement,position:PlaygroundPosition,causedBy:MazeElementType)
    {
        if let _ = element.sprite
        {
            if causedBy==MazeElementType.chicken || causedBy == MazeElementType.acid
            {
                let elementLeft = Playground.left(position: position) // here is the acid !
                
                self.createWallOnPlayground(position: elementLeft)
                
                sceneDelegate?.playSoundAcid()
                self.increaseEventCounter(comment:"acid corrosive",element: causedBy)

                // remove all items destroyed by acid
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // chicken/acid
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.up(position: elementLeft),duration:0.9) //  acid up
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.down(position: elementLeft),duration:0.9) // acid down
                
                sceneDelegate?.doAcidAnimation(element: element,block:{
                    
                    
                    element.sprite?.removeFromParent()
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:elementLeft,duration:0.0)
                    
                    self.testForChickenOrFishAction(position: Playground.up(position: elementLeft),justStarted:true,causedby: causedBy)
                    self.testForChickenOrFishAction(position: elementLeft,justStarted:true,causedby: causedBy)
                    self.testForChickenOrFishAction(position: position,justStarted:true,causedby: causedBy)
                    self.testForChickenOrFishAction(position: Playground.down(position: elementLeft),justStarted:true,causedby: causedBy)
                    self.decreaseEventCounter(comment:"acid corrosive",element: causedBy)
                    
                    
                })
            }
            else // causedBy==MazeElementType.fish || causedBy == MazeElementType.bomb
            {
                let elementFishAboveAcid = Playground.up(position: position)
                let elementDownFromAcid = Playground.down(position: Playground.down(position: position))
                
                self.createWallOnPlayground(position: elementDownFromAcid)
                
                sceneDelegate?.playSoundAcid()
                
                // remove all items destroyed by acid
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position:position,duration:0.9) // fish/bomb
                self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementDownFromAcid,duration:0.9) //  acid down
                
                self.testForChickenOrFishAction(position: position,justStarted:true,causedby: causedBy)
                self.testForChickenOrFishAction(position: elementDownFromAcid,justStarted:true,causedby: causedBy)
                
                self.increaseEventCounter(comment:"acid corrosive",element:causedBy)
                sceneDelegate?.doAcidAnimation(element: element,block:{
                    
                    element.sprite?.removeFromParent()
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: Playground.down(position: position),duration:0.0)
                    self.createEmptySpaceOnPlaygroundAndRemoveSprite(position: elementFishAboveAcid,duration:0.0) // acid
                    self.testForChickenOrFishAction(position: Playground.down(position: position),justStarted:true,causedby: causedBy)
                    self.testForChickenOrFishAction(position: elementFishAboveAcid,justStarted:true,causedby: causedBy)
                    self.decreaseEventCounter(comment:"acid corrosive",element:causedBy)
                })
                
            }
        }
    }
    
    
    func increaseEventCounter(comment:String,element:MazeElementType)
    {
        self.eventCounter = self.eventCounter + 1
        print("  increase!  events up at \(comment): \(self.eventCounter) because: \(element)")
    }
    
    func decreaseEventCounter(comment:String,element:MazeElementType)
    {
        
        self.eventCounter = self.eventCounter - 1
        print(" decrease!  events down at \(comment): \(self.eventCounter) because: \(element)")
        if self.eventCounter==0
        {
            print("All  Events done!")
            self.endOfAnimation()
            NotificationCenter.default.post(name: Notification.Name(rawValue: drawEndedNotificationKey), object: self)
            return
        }
        assert(self.eventCounter>=0,"event counter must be nonnegative ")
    }

}
