//
//  GameScene.swift
//  iXor
//
//  Created by Mario Rotz on 04.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import SpriteKit

enum SceneEvent : Int {
    case step_done = 0,
    map1_found,
    map2_found,
    map3_found,
    map4_found,
    exit_found,
    transporter_found,
    mask_found,
    bad_mask_found,
    death_player1,
    death_player2,
    death_both,
    redraw
}


class GameScene: SKScene {
    
    var segmentX : CGFloat?
    var segmentY : CGFloat?
    var exitDone = false
    var updateViewController : ((MazeEvent)->Void)?
    
    var acidFrames : [SKTexture]!
    var bombFrames : [SKTexture]!
    var skullFrames : [SKTexture]!

    let factorX = CGFloat(PlaygroundBuilder.Constants.groesseX-PlaygroundBuilder.Constants.sichtbareGroesseX)*CGFloat(-1.0)
    let factorY = CGFloat(PlaygroundBuilder.Constants.groesseY-PlaygroundBuilder.Constants.sichtbareGroesseY)

    var playground : Playground
    
    var spritesToRemove = Array<SKSpriteNode?>()
    
    let worldNode : SKNode = SKNode()
    let mapMode : SKNode = SKNode()
    
    var animationCompleted : ((MazeElement,PlaygroundPosition)->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, playground:Playground) {
        self.playground = playground
        super.init(size:size)
        segmentX = self.size.width / CGFloat(PlaygroundBuilder.Constants.sichtbareGroesseX)
        segmentY = self.size.height / CGFloat(PlaygroundBuilder.Constants.sichtbareGroesseY)
        addChild(worldNode)
        self.updateWithNewPlayground(self.playground)
        initWithPlayerOne()
        prepareAcidAnimation()
        prepareBombAnimation()
        prepareSkullAnimation()
    }
    
    func remove_all_children(){
        self.worldNode.removeAllChildren()
        
        let sprite = SKSpriteNode.init(color: UIColor.black, size: CGSize(width:self.size.width*8.0,height:self.size.height*8.0))
        
        //let sprite2 = SKSpriteNode.init(imageNamed: "xanadoo.png")
        //sprite2.scale(to: CGSize(width:self.size.width*8.0,height:self.size.height*8.0))
        
        self.worldNode.addChild(sprite)
        
    }
    func updateWithNewPlayground(_ playground:Playground) {
        self.playground = playground
        self.playground.scene = self
        remove_all_children()
        for x in 0..<PlaygroundBuilder.Constants.groesseX {
            for y in 0..<PlaygroundBuilder.Constants.groesseY {
                if let mazeType = spriteNode(position: PlaygroundPosition(x: y, y: x)) {
                    if let sprite = mazeType.sprite {
                        sprite.removeFromParent()
                        worldNode.addChild(sprite)
                        sprite.xScale = segmentX! / CGFloat(40.0)
                        sprite.yScale = segmentY! / CGFloat(40.0)
                        drawSprite(element:mazeType,position:PlaygroundPosition(x:x,y:y),duration:0.25,completed:nil)
                    }
                    else {
                        
                    }
                }
            }
        }
    }
    
    func prepareAcidAnimation()
    {
        let acidAnimatedAtlas = SKTextureAtlas(named: "acid")
        var acidCorrosiveFrames = [SKTexture]()
        
        let numImages = acidAnimatedAtlas.textureNames.count
        for i in 1...(numImages)
        {
            let acidTextureName = "saeure_\(i)"
            acidCorrosiveFrames.append(acidAnimatedAtlas.textureNamed(acidTextureName))
        }
        
        acidFrames = acidCorrosiveFrames
    }
    
    func doAcidAnimation(sprite:SKSpriteNode,block:@escaping ()->Void )
    {
        sprite.run(SKAction.repeat(
            SKAction.animate(with: acidFrames,timePerFrame: 0.2,resize: true,restore: true),
            count:1), completion: block
        )
    }
    
    func prepareBombAnimation()
    {
        let bombAnimatedAtlas = SKTextureAtlas(named: "bombs")
        var bombCorrosiveFrames = [SKTexture]()
        
        let numImages = bombAnimatedAtlas.textureNames.count
        for i in 1...(numImages)
        {
            let bombTextureName = "bomb_\(i)"
            bombCorrosiveFrames.append(bombAnimatedAtlas.textureNamed(bombTextureName))
        }
        
        bombFrames = bombCorrosiveFrames
    }
    
    func prepareSkullAnimation()
    {
        let bombAnimatedAtlas = SKTextureAtlas(named: "skull")
        var bombCorrosiveFrames = [SKTexture]()
        
        let numImages = bombAnimatedAtlas.textureNames.count
        for i in 1...(numImages)
        {
            let bombTextureName = "skull_\(i)"
            bombCorrosiveFrames.append(bombAnimatedAtlas.textureNamed(bombTextureName))
        }
        
        skullFrames = bombCorrosiveFrames
    }
    
    func doBombAnimation(sprite:SKSpriteNode,block:@escaping ()->Void )
    {
        sprite.run(SKAction.repeat(
            SKAction.animate(with: bombFrames,timePerFrame: 0.1,resize: true,restore: true),
            count:1), completion: block
        )
    }
    
    func doSkullAnimation()
    {
        
    }
    
    
    func resetGameScene(playground:Playground?) {
        remove_all_children()
        if let playgrnd = playground {
            self.playground = playgrnd
        }
        self.playground.scene = self
        segmentX = self.size.width / CGFloat(PlaygroundBuilder.Constants.sichtbareGroesseX)
        segmentY = self.size.height / CGFloat(PlaygroundBuilder.Constants.sichtbareGroesseY)
        for x in 0..<PlaygroundBuilder.Constants.groesseX {
            for y in 0..<PlaygroundBuilder.Constants.groesseY {
                if let mazeType = spriteNode(position: PlaygroundPosition(x: y, y: x)) {
                    if let sprite = mazeType.sprite {
                        sprite.alpha=1.0
                        sprite.removeFromParent()
                        worldNode.addChild(sprite)
                        sprite.xScale = segmentX! / CGFloat(40.0)
                        sprite.yScale = segmentY! / CGFloat(40.0)
                        drawSprite(element:mazeType,position:PlaygroundPosition(x:x,y:y),duration:0.25,completed:nil)
                    }
                }
            }
        }
    }
    
    
    
    func drawSprite(element:MazeElement,position:PlaygroundPosition,duration:TimeInterval, completed:(()->())?) {
        if let sprite = element.sprite {
            let point = CGPoint(x: CGFloat(position.x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(position.y)*segmentY!-segmentY!/2.0)
            let moveAction = SKAction.move(to: point, duration: duration)
            sprite.run(moveAction, completion: {
                
                for sprite in self.spritesToRemove
                {
                    sprite?.removeFromParent()
                }
                self.spritesToRemove.removeAll()
                if self.playground.justFinished == true {
                    self.updateViewController!(MazeEvent.exit_found)
                }
                if let animationCompleted = self.animationCompleted {
                    animationCompleted(element,position)
                }
                if let compl = completed {
                    compl()
                }
            })
        }
    }
    
    func spriteNode(position:PlaygroundPosition) -> MazeElement?
    {
        let mazeElement = playground.playgroundArray[position.x][position.y]
        return mazeElement
    }
    
    func initWithPlayerOne() {

        self.playground.akt_spieler_ist_playerOne = true
        let position = PlaygroundPosition(x:playground.positionPlayerOne.x-4,
                                          y:playground.positionPlayerOne.y-4)
        self.playground.playerPosition = self.playground.positionPlayerOne
        self.playground.oldPlayerPosition = self.playground.positionPlayerOne
        print("player one:\(self.playground.positionPlayerOne)")
        print("player two:\(self.playground.positionPlayerTwo)")
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func switchToPlayerOne() {
        self.playground.positionPlayerTwo = self.playground.playerPosition
        initWithPlayerOne()
    }
    
    func switchToPlayerTwo() {
        let position = PlaygroundPosition(x:playground.positionPlayerTwo.x-4,
                                          y:playground.positionPlayerTwo.y-4)
        self.playground.positionPlayerOne = self.playground.playerPosition
        self.playground.playerPosition = self.playground.positionPlayerTwo
        self.playground.oldPlayerPosition = self.playground.positionPlayerTwo
        print("player one:\(self.playground.positionPlayerOne)")
        print("player two:\(self.playground.positionPlayerTwo)")
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition){
        var coord = position
        if coord.x<0 {
            coord.x = 0
        }
        if coord.y<0 {
            coord.y = 0
        }
        if coord.x>(PlaygroundBuilder.Constants.groesseX-PlaygroundBuilder.Constants.sichtbareGroesseX)
        {
            coord.x = PlaygroundBuilder.Constants.groesseX - PlaygroundBuilder.Constants.sichtbareGroesseX
        }
        if coord.y>(PlaygroundBuilder.Constants.groesseY-PlaygroundBuilder.Constants.sichtbareGroesseY)
        {
            coord.y = PlaygroundBuilder.Constants.groesseY - PlaygroundBuilder.Constants.sichtbareGroesseY
        }
        let xCoord = (CGFloat(coord.x)*CGFloat(segmentX!))*CGFloat(-1)
        let yCoord = CGFloat(coord.y)*segmentY!
        worldNode.position = CGPoint(x:xCoord,y:yCoord)
        print("Camera position:\(coord)")
        self.playground.cameraLeftTopPosition = coord
    }
    
    func drawPlayer(position:PlaygroundPosition,previousPosition:PlaygroundPosition,beamed:Bool,completition:(()->Void)?)
    {
        print("zeichne player an position \(position)  ")
        let sprite = (playground.element(position: position)?.sprite)!// (playground.playerOneMazeElement?.sprite)!
//        if player==true
//        {
//            playground.positionPlayerOne = position
//        }
//        else
//        {
//            playground.positionPlayerTwo = position
//            sprite = (playground.playerTwoMazeElement?.sprite)!
//        }
        let point = CGPoint(x: CGFloat(position.x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(position.y)*segmentY!-segmentY!/2.0)
        if beamed==true
        {
            let scaleActionZero = SKAction.resize(toHeight: 0.0,duration:0.5)
            let scaleActionFull = SKAction.resize(toHeight: 40.0 ,duration:0.5)
            sprite.run(scaleActionZero, completion: {
                let moveAction = SKAction.move(to: point, duration: 0.25)
                sprite.run(moveAction, completion: {
                    for sprite in self.spritesToRemove
                    {
                        sprite?.removeFromParent()
                    }
                    self.spritesToRemove.removeAll()
                    if self.playground.justFinished == true {
                        self.updateViewController!(MazeEvent.exit_found)
                    }
                    sprite.run(scaleActionFull,completion:{
                        if let compe = completition {
                            compe()
                        }
                        print(" sprite size: \(sprite.size)")
                    })
                })
            })
        }
        else
        {
//            let scaleActionZero = SKAction.resize(toWidth: 0.0,duration:0.5)
//            let scaleActionFull = SKAction.resize(toWidth: 40.0 ,duration:0.5)
//            sprite.run(scaleActionZero)
            let moveAction = SKAction.move(to: point, duration: 0.25)
            sprite.run(moveAction, completion: {
                for sprite in self.spritesToRemove
                {
                    sprite?.removeFromParent()
                }
                self.spritesToRemove.removeAll()
                if self.playground.justFinished == true {
                    self.updateViewController!(MazeEvent.exit_found)
                }
            
                    if let compe = completition {
                        compe()
                    }
                    print(" sprite size: \(sprite.size)")
            })

            //sprite.run(scaleActionFull)
            
        }
    }
    
    func showMap() {
        mapMode.removeAllChildren()
        let tinySegmentX = self.size.width / CGFloat(PlaygroundBuilder.Constants.groesseX)
        let tinySegmentY = self.size.height / CGFloat(PlaygroundBuilder.Constants.groesseY)
        for x in 0..<PlaygroundBuilder.Constants.groesseX
        {
            for y in 0..<PlaygroundBuilder.Constants.groesseY
            {
                if (x <= PlaygroundBuilder.Constants.groesseX / 2) {
                    
                    if (y <= PlaygroundBuilder.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_1) == nil)
                    {
                        continue
                    }
                    if ( y > PlaygroundBuilder.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_3) == nil)
                    {
                        continue
                    }
                }
                else
                {
                    if (y <= PlaygroundBuilder.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_2) == nil)
                    {
                        continue
                    }
                
                    if (y > PlaygroundBuilder.Constants.groesseY/2 && playground.mapsFound.index(of:MazeElementType.map_4) == nil)
                    {
                        continue
                    }
                }
                
                let mazeElement = playground.playgroundArray[y][x]
                var sprite : SKSpriteNode?
                if let type = mazeElement.mazeElementType {
                    switch(type) {
                    
                    case MazeElementType.player_1:
                        sprite = SKSpriteNode(color: UIColor.darkGray, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.player_2:
                        sprite = SKSpriteNode(color: UIColor.darkGray, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.wall:
                        sprite = SKSpriteNode(color: UIColor.red, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.mask:
                        sprite = SKSpriteNode(color: UIColor.blue, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.bad_mask:
                        sprite = SKSpriteNode(color: UIColor.blue, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.v_wave:
                        sprite = SKSpriteNode(color: UIColor.yellow, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.h_wave:
                        sprite = SKSpriteNode(color: UIColor.white, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.exit:
                        sprite = SKSpriteNode(color: UIColor.green, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.bomb:
                        sprite = SKSpriteNode(color: UIColor.black, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.chicken:
                        sprite = SKSpriteNode(color: UIColor.purple, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.fish:
                        sprite = SKSpriteNode(color: UIColor.brown, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.puppet:
                        sprite = SKSpriteNode(color: UIColor.orange, size:CGSize(width:10.0,height:10.0))
                        break
                    case MazeElementType.transporter:
                        sprite = SKSpriteNode(color: UIColor.magenta, size:CGSize(width:10.0,height:10.0))
                        break
                    default:
                        break
                    }
                }
                if !(sprite == nil) {
                    mapMode.addChild(sprite!)
                    sprite?.xScale = tinySegmentX / CGFloat(10.0)
                    sprite?.yScale = tinySegmentY / CGFloat(10.0)
                    let point = CGPoint(x: CGFloat(x)*tinySegmentX+tinySegmentX/2.0,y: self.size.height - CGFloat(y)*tinySegmentY-tinySegmentY/2.0)
                    let moveAction = SKAction.move(to: point, duration: 0.0)
                    sprite?.run(moveAction)
                }
                
            }
        }
        removeAllChildren()
        addChild(mapMode)
    }
    
    func hideMap() {
        removeAllChildren()
        addChild(worldNode)
    }
}
