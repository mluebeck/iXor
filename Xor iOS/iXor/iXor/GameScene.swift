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
    
    var path : UIBezierPath?

    
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
    
    var panGestureRecognizer  : UIPanGestureRecognizer?
    var longPressGestureRecognizer  : UILongPressGestureRecognizer?
    var oldcoordinates : CGPoint?
    var lines = Array<SKShapeNode>()
    
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
        self.isUserInteractionEnabled = true
        initWithPlayerOne()
        prepareAcidAnimation()
        prepareBombAnimation()
        prepareSkullAnimation()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action:#selector(GameScene.handleLongPressFrom(recognizer:)))
        longPressGestureRecognizer?.minimumPressDuration=0.01
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action:#selector(GameScene.handlePanFrom(recognizer:)))
        panGestureRecognizer?.minimumNumberOfTouches = 1
    }
    
    func handleLongPressFrom(recognizer:UILongPressGestureRecognizer)
    {
        if recognizer.state==UIGestureRecognizerState.ended {
            oldcoordinates=nil
            for line in lines {
                line.removeFromParent()
            }
            lines.removeAll()
            return
        }
        
        
        let height = self.size.height
        let coordinates = recognizer.location(in: self.view)
        let x = round40(Double(coordinates.x))+40.0/2.0
        let y = round40(Double(height-coordinates.y))+40.0/2.0
        print("handleLongPressFrom Tapped! \(x), \(y) ")
        
        if lines.count==0 {
            // begin drawing
            print("Begin drawing!")
            let e = playground.element(position: PlaygroundPosition(x:Int(x/40),y:Int(round(40.0*(coordinates.y))/40.0)/40 + 1 ))
            print("element : \(e!)")
            if e?.mazeElementType == MazeElementType.player_1 || e?.mazeElementType == MazeElementType.player_2
            {
                
            }
            else
            {
                return
            }
            
        }
        else
        {
            print("continue drawing!")
            let e = playground.element(position: PlaygroundPosition(x:Int(x/40),y:Int(round(40.0*(coordinates.y))/40.0)/40 + 1 ))
            print("element : \(e!)")
            if e?.mazeElementType == MazeElementType.wall
            {
                return

            }
            else
            {
                
            }
        }
        
        let pathToDraw:CGMutablePath = CGMutablePath()
        let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
        
        if let ocoord = oldcoordinates
        {
            let old_x = round40(Double(ocoord.x))+40.0/2.0
            let old_y = round40(Double(height-ocoord.y))+40.0/2.0
            
            pathToDraw.move(to:CGPoint(x: old_x,y:old_y))
            pathToDraw.addLine(to: CGPoint(x: x,y:y))
            
            myLine.path = pathToDraw
            myLine.strokeColor = SKColor.red
            myLine.lineWidth = 10.0
            myLine.glowWidth = 2.0
            self.addChild(myLine)
            myLine.zPosition = 1.0
            lines.append(myLine)
        }
        oldcoordinates = coordinates
    }
    
    func round40(_ x:Double)->Double {
        return round(x/40.0)*40.0
    }
    
    func handlePanFrom(recognizer:UIPanGestureRecognizer)
    {
        let coordinates = recognizer.translation(in: self.view)
        print("handlePanFrom Tapped! \(coordinates) ")
        
       
    }
    
    override func didMove(to view: SKView) {
         super.didMove(to: view)
        view.addGestureRecognizer(longPressGestureRecognizer!)
        view.addGestureRecognizer(panGestureRecognizer!)
        
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
        self.playground.sceneDelegate = SceneDelegateImplementation(scene:self)
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
        self.playground.sceneDelegate = SceneDelegateImplementation(scene: self)
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
    
    func initWithPlayerOne()
    {
        self.playground.akt_spieler_ist_playerOne = true
        let position = PlaygroundPosition(x:playground.positionPlayerOne.x-4,
                                          y:playground.positionPlayerOne.y-4)
        self.playground.playerPosition = self.playground.positionPlayerOne
        self.playground.oldPlayerPosition = self.playground.positionPlayerOne
        print("player one:\(self.playground.positionPlayerOne)")
        print("player two:\(self.playground.positionPlayerTwo)")
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func switchToPlayerOne()
    {
        self.playground.positionPlayerTwo = self.playground.playerPosition
        initWithPlayerOne()
    }
    
    func switchToPlayerTwo()
    {
        let position = PlaygroundPosition(x:playground.positionPlayerTwo.x-4,
                                          y:playground.positionPlayerTwo.y-4)
        self.playground.positionPlayerOne = self.playground.playerPosition
        self.playground.playerPosition = self.playground.positionPlayerTwo
        self.playground.oldPlayerPosition = self.playground.positionPlayerTwo
        print("player one:\(self.playground.positionPlayerOne)")
        print("player two:\(self.playground.positionPlayerTwo)")
        moveCameraToPlaygroundCoordinates(position:position)
    }
    
    func moveCameraToPlaygroundCoordinates(position:PlaygroundPosition)
    {
        var coord = position
        if coord.x<0
        {
            coord.x = 0
        }
        if coord.y<0
        {
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
        let point = CGPoint(x: CGFloat(position.x)*segmentX!+segmentX!/2.0, y: self.size.height - CGFloat(position.y)*segmentY!-segmentY!/2.0)
        if beamed==true
        {
            // change size to zero to make sprite disappear -> beam effect!
            let scaleActionZero = SKAction.resize(toHeight: 0.0,duration:0.5)
            sprite.run(scaleActionZero, completion: {
                self.moveAction(point: point, sprite: sprite, completition: completition, beamed: true)
            })
        }
        else
        {
            self.moveAction(point: point, sprite: sprite, completition: completition, beamed: false)
        }
    }
    
    
    func moveAction(point:CGPoint,sprite:SKSpriteNode,completition:(()->Void)?,beamed:Bool)
    {
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
            if beamed == true {
                let scaleActionFull = SKAction.resize(toHeight: 40.0 ,duration:0.5)
                sprite.run(scaleActionFull,completion:{
                    if let compe = completition {
                        compe()
                    }
                })
            }
            else {
                if let compe = completition {
                    compe()
                }
            }
            
            print(" sprite size: \(sprite.size)")
        })
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
                if let sprite2 = mazeElement.sprite
                {
                    let sprite = sprite2.copy() as! SKSpriteNode
                    mapMode.addChild(sprite)
                    sprite.xScale = tinySegmentX / CGFloat(10.0)
                    sprite.yScale = tinySegmentY / CGFloat(10.0)
                    let point = CGPoint(x: CGFloat(x)*tinySegmentX+tinySegmentX/2.0,y: self.size.height - CGFloat(y)*tinySegmentY-tinySegmentY/2.0)
                    
                    let scaleAction = SKAction.scale(by: 0.25, duration: 0.0)
                    sprite.run(scaleAction, completion: {
                        let moveAction = SKAction.move(to: point, duration: 0.0)
                        sprite.run(moveAction)
                    })
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
