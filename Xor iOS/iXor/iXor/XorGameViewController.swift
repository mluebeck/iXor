//
//  GameViewController.swift
//  iXor
//
//  Created by Mario Rotz on 04.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

enum Orientation {
    case MyViewOrientationUnspecified
    case MyViewOrientationPortrait
    case MyViewOrientationLandscape
}


class XorGameViewController: UIViewController {
    @IBOutlet var playgroundViewConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var countMovesViewWidthConstraint : NSLayoutConstraint!
    
    @IBOutlet var playerChangeButton : UIButton!
    @IBOutlet var playerChangeImage: UIImageView!
    
    @IBOutlet var playgroundView : SKView!
    
    @IBOutlet var collectedMasksLabel : UILabel!
    @IBOutlet var gameControllerView: UIView!
    @IBOutlet var mapLeftUp : UIView!
    @IBOutlet var mapLeftDown : UIView!
    @IBOutlet var mapRightUp : UIView!
    @IBOutlet var mapRightDown : UIView!
    @IBOutlet var replayButtonsView :UIView!
    @IBOutlet var mapTextView: FrostedView!
    
    @IBOutlet var xorNavigationItem: UINavigationItem!
    @IBOutlet var successView: FrostedView!
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var okButton : UIButton!
    @IBOutlet var countMovesView : UIView!
    @IBOutlet var countMovesLabel : UILabel!
    @IBOutlet var progressBar : UIProgressView!
    @IBOutlet var navigationBarTitle : UILabel!
    @IBOutlet var replayButton : UIButton!
    
    static var currentPlaygroundLevel = 1

    var movesString = "/1000"
    var currentOrientation : Orientation!
    var scene: GameScene!
    var map_visible = false
    var playgrounds = [Int: Playground]()
    var mazeEvent = MazeEvent.redraw
    var currentPlayground : Playground?
    var oldAcceleration : CMAcceleration?
    var replays = [String : Array<ReplayPlayerMove>]()
    var currentReplay = Array<ReplayPlayerMove>()
    var motionManager: CMMotionManager!
    
    var replayMode = false
    var replayStopPressed = false
    
    var currentNumberOfReplayMove = 0
    
    // MARK: Rotation and Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Rotation
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown, .landscape]
    }
    
    // view constraints
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        updateCurrentConstraintsToSize(size: self.view.bounds.size)
    }
    
    func updateCurrentConstraintsToSize(size:CGSize)
    {
        var  orientation : Orientation!
        if size.width > size.height {
            orientation = Orientation.MyViewOrientationLandscape
        } else {
            orientation = Orientation.MyViewOrientationPortrait
        }
        if self.currentOrientation != orientation && orientation != Orientation.MyViewOrientationUnspecified {
            var z = 0
            if let zuege = self.currentPlayground?.anzahl_spielzuege
            {
                z=zuege
            }
            if orientation == Orientation.MyViewOrientationPortrait {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height / CGFloat(2.25)
                //countMovesViewWidthConstraint.constant=50
                movesString="/1000"
                self.countMovesLabel.text = String("\(z)")
            } else {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width - playgroundViewConstraint.constant - 15
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height
                //countMovesViewWidthConstraint.constant=10
                movesString=""
                self.countMovesLabel.text = String("\(z)")
            }
            self.currentOrientation = orientation;
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showPlayerIconOnButton(playerOne: false)

        /*
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates(to:OperationQueue(),withHandler:  {
            data, error in
            if let accelerometerData = self.motionManager.accelerometerData {
                if let oldAcData = self.oldAcceleration {
                    let x = accelerometerData.acceleration.x
                    let y = accelerometerData.acceleration.y
                    let oldX = oldAcData.x
                    let oldY = oldAcData.y
                    print("Data X :\(oldX-x) \(x)")
                    //print("Data Y :\(y-oldY)")
                    self.oldAcceleration = accelerometerData.acceleration
                }
                else
                {
                    self.oldAcceleration = accelerometerData.acceleration
                }
            }
            return
        })
        */
        
        self.resetMaps()

        self.playgrounds = PlaygroundBuilder.playgrounds()
        
        self.presentPlayground()
        self.navigationBarTitle.text = self.currentPlayground?.level_name

        //drawCircleSegment(index:2)
    }
    
    /*
    func drawCircleSegment(index:Int) {
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 5, y: 5, width: self.countMovesView.frame.height-10, height: self.countMovesView.frame.height-10))
        var segments: [CAShapeLayer] = []
        let numberOfAngles = 100
        let segmentAngle: CGFloat = (360 * 1.0/CGFloat(numberOfAngles)) / 360
        
        for i in 0 ..< numberOfAngles {
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            
            // start angle is number of segments * the segment angle
            circleLayer.strokeStart = segmentAngle * CGFloat(i)
            
            // end angle is the start plus one segment, minus a little to make a gap
            // you'll have to play with this value to get it to look right at the size you need
            let gapSize: CGFloat = 0.008
            circleLayer.strokeEnd = circleLayer.strokeStart + segmentAngle - gapSize
            
            circleLayer.lineWidth = 10
            if i>11 && i<11+index
            {
                print("i:\(i)")
                circleLayer.strokeColor = UIColor(red:0,  green:0.004,  blue:0.549, alpha:1).cgColor
            }
            else
            {
                circleLayer.strokeColor = UIColor.yellow.cgColor
            }
            circleLayer.fillColor = UIColor.clear.cgColor
            
            // add the segment to the segments array and to the view
            segments.insert(circleLayer, at: i)
            self.countMovesView.layer.addSublayer(segments[i])
        }
    }*/
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if map_visible == false
        {
            mapTextView.show(visible: map_visible)
        }
        replayControllerView(active: false)
    }
    
    // MARK:  present the playground
    func presentPlayground() {
        
        successView.show(visible: false)
        collectedMasksLabel.text = String("0")
        
        currentPlayground = playgrounds[XorGameViewController.currentPlaygroundLevel]
        
        if let gesMask = self.currentPlayground?.masken_gesamtanzahl {
            collectedMasksLabel!.text! = "0/\(gesMask)"
        }
        playgroundView.isMultipleTouchEnabled = false
        
        scene = GameScene(size: playgroundView.bounds.size, playground:self.currentPlayground!)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.lightGray
        scene.updateViewController = {
            mazeEvent in
            self.mazeEvent = mazeEvent
            switch(mazeEvent)
            {
            case MazeEvent.map1_found:
                self.mapLeftUp.alpha = 1.0
                break;
            case MazeEvent.map2_found:
                self.mapRightUp.alpha = 1.0
                break;
            case MazeEvent.map3_found:
                self.mapLeftDown.alpha = 1.0
                break;
            case MazeEvent.map4_found:
                self.mapRightDown.alpha = 1.0
                break;
            case MazeEvent.mask_found:
                break;
            case MazeEvent.exit_found:
                // Hier Erfolg animieren und Level freischalten
                self.successView.show(visible: true)
                self.messageLabel.text = "Du hast es geschafft!\n\nBereit für den nächsten Level?"
                self.okButton.layer.borderWidth=2.0
                self.okButton.layer.borderColor=UIColor.gray.cgColor
                //[[myButton layer] setBorderWidth:2.0f];
                //[[myButton layer] setBorderColor:[UIColor greenColor].CGColor];
                self.okButton.setTitle("OK, weiter geht's!", for: UIControlState.normal)
                
                self.scene.removeAllChildren()
                XorGameViewController.currentPlaygroundLevel += 1
                self.currentPlayground?.finished = true
                self.currentPlayground?.justFinished = false

                break
            case MazeEvent.bad_mask_found:
                self.currentPlayground?.badMaskOperation()
                break
            case MazeEvent.death_player1:
                self.showPlayerIconOnButton(playerOne:true)
                self.showForbiddenImage()
                break
                case MazeEvent.death_player2:
                self.showPlayerIconOnButton(playerOne:false)
                self.showForbiddenImage()
                break
            case MazeEvent.death_both:
                self.successView.show(visible: true)
                self.messageLabel.text = "Oh nein! Beide Spieler sind tot!\n\nVersuch' es gleich nochmal!"
                self.okButton.setTitle("OK, gleich nochmal versuchen!", for: UIControlState.normal)
                self.scene.removeAllChildren()
                self.currentPlayground?.justFinished = false
                self.currentPlayground?.finished = false
                break
            default:
                break;
            }
            
            // always : one step further 
            if let zuege = self.currentPlayground?.anzahl_spielzuege {
                self.progressBar.setProgress(Float(zuege)/1000.0, animated: true)
                self.countMovesLabel.text = String("\(zuege)")
            }
            if let maskenTotal = self.currentPlayground?.masken_gesamtanzahl {
                if let masken = self.currentPlayground?.masken_gesammelt {
                    self.collectedMasksLabel!.text! = String("\(masken)/\(maskenTotal)")
                    
                }
            }
        }
        
        // Present the scene.
        playgroundView.presentScene(scene)
        currentPlayground?.testChickenAcidFishBomb()
    }
    
    // MARK: MAPS 
    
    func resetMaps() {
        self.mapLeftUp.alpha = 0.5
        self.mapRightUp.alpha = 0.5
        self.mapLeftDown.alpha = 0.5
        self.mapRightDown.alpha = 0.5
        self.currentPlayground?.mapsFound.removeAll()
    }
    
    // Show Map Button
    @IBAction func mapButtonPressed(){
        
        mapTextVisible()
        if map_visible==false {
            scene.showMap()
            map_visible = true
        }
        else
        {
            scene.hideMap()
            mapTextView.show(visible: false)
            map_visible = false
        }
    }
    
    func mapTextVisible(){
        if currentPlayground?.mapsFound.count == 0
        {
            mapTextView.show(visible: true)
        }
        else
        {
            mapTextView.show(visible: false)
        }
        
    }

    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        if viewController is XorLevelTableViewController {
            let levelTableViewController = viewController as! XorLevelTableViewController
            levelTableViewController.setPlaygrounds(playgrounds:self.playgrounds)
            levelTableViewController.currentLevel = self.currentPlayground?.level_number
            levelTableViewController.selectionFinishedClosure = {
                selectedPlaygroundLevel in
                if selectedPlaygroundLevel >= 0 {
                    self.currentPlayground = self.playgrounds[selectedPlaygroundLevel]
                    self.currentPlayground = PlaygroundBuilder.readLevel(number: selectedPlaygroundLevel,playground:self.currentPlayground)
                    XorGameViewController.currentPlaygroundLevel=selectedPlaygroundLevel
                    
                    self.resetReplay()
                    
                    //self.scene = GameScene()
                    //self.scene.drawWholePlayground()
                    self.countMovesLabel.text = "0"
                    self.navigationBarTitle.text = self.currentPlayground?.level_name
                    self.presentPlayground()
                    self.resetMaps()
                    
                }
                return
            }
            levelTableViewController.resetPressedClosure = {
                self.countMovesLabel.text = "0"
                self.resetReplay()
                self.resetToBegin()
                self.resetMaps()
            }
        }
    }
    
    
    
    
    
    // MARK: Direction controls
    @IBAction func leftGameButtonPressed(){
        
        if self.replayMode == false {
            self.currentReplay.append(ReplayPlayerMove(playerChanged:false,
                                                       moveDirection: PlayerMoveDirection.LEFT))
        }
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.LEFT)
    }
    
    @IBAction func rightGameButtonPressed(){
        if self.replayMode == false {
            self.currentReplay.append(ReplayPlayerMove(playerChanged:false,
                                                       moveDirection: PlayerMoveDirection.RIGHT))
        }
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.RIGHT)
    }
    @IBAction func upGameButtonPressed(){
        if self.replayMode == false {
            self.currentReplay.append(ReplayPlayerMove(playerChanged:false,
                                                       moveDirection: PlayerMoveDirection.UP))
        }
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.UP)
    }
    @IBAction func downGameButtonPressed(){
        if self.replayMode == false {
            self.currentReplay.append(ReplayPlayerMove(playerChanged:false,
                                                       moveDirection: PlayerMoveDirection.DOWN))
        }
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.DOWN)
    }
    
    // MARK: Switch Player
    @IBAction func switchMaskButtonPressed(){
        if (currentPlayground?.numberOfKilledPlayer)!>0 {
            return
        }
        if self.replayMode == false {
            self.currentReplay.append(ReplayPlayerMove(playerChanged:true,
                                                       moveDirection:PlayerMoveDirection.UP))
        }
        
        showPlayerIconOnButton(playerOne: (currentPlayground?.akt_spieler_ist_playerOne)!)
    }
    
    func showPlayerIconOnButton(playerOne:Bool) {
        playerChangeButton.isEnabled = true
        if playerOne == true
        {
            if !(scene==nil) {
                scene.switchToPlayerTwo()
            }
            currentPlayground?.akt_spieler_ist_playerOne = false
            let playerOneImage = UIImage(named:"spieler1")
            playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage
        }
        else
        {
            if !(scene==nil) {
                scene.switchToPlayerOne()
            }
            currentPlayground?.akt_spieler_ist_playerOne = true
            let playerOneImage = UIImage(named:"spieler2")
            playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage
        }
    }
    
    func showForbiddenImage() {
        let playerOneImage = UIImage(named:"verbot_weiss")
        playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
        playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
        playerChangeImage.image = nil
        playerChangeButton.isEnabled = false
    }
    
    func hideForbiddenImage() {
        let playerOneImage = UIImage(named:"spieler2")
        playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
        playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
        playerChangeImage.image = playerOneImage
        playerChangeButton.isEnabled = true
    }
    
    // MARK: Replay 
    
    @IBAction func replayButtonPressed()
    {
        if self.replayMode==true {
            self.replayMode = false
            self.gameControllerView(active: true)
            self.replayControllerView(active: false)
            self.replayButton.setTitle("Replay", for: UIControlState.normal)
            self.replayButton.setTitle("Replay", for: UIControlState.highlighted)
        }
        else
        {
            self.gameControllerView(active: false)
            self.replayControllerView(active: true)
            self.replayButton.setTitle("EXIT", for: UIControlState.normal)
            self.replayButton.setTitle("EXIT", for: UIControlState.highlighted)
            self.replayMode = true
        
            self.currentNumberOfReplayMove = 0
            self.resetToBegin()
        }
    }

    func fastForward(queue:Array<ReplayPlayerMove>)
    {
        if queue.count==0 || self.replayStopPressed == true
        {
            return
        }
        var newQueue = queue
        if let first = queue.first {
            newQueue.remove(at: 0)
        
            if first.playerChanged==true {
                switchMaskButtonPressed()
            }
            else
            {
                switch(first.moveDirection)
                {
                case PlayerMoveDirection.UP:
                    upGameButtonPressed()
                    break
            
                case PlayerMoveDirection.DOWN:
                    downGameButtonPressed()
                    break
            
                case PlayerMoveDirection.LEFT:
                    leftGameButtonPressed()
                    break
            
                case PlayerMoveDirection.RIGHT:
                    rightGameButtonPressed()
                    break
                }
            }
            
            self.currentNumberOfReplayMove += 1
            AppDelegate.delay(bySeconds: 0.1, dispatchLevel: .main) {
                self.fastForward(queue: newQueue)
            }
        }
       
    }
    
    @IBAction func fastforwarButtonPressed() {
        let queue = self.currentReplay
        if self.currentNumberOfReplayMove>0 {
            self.replayStopPressed = false
            self.resetToBegin()
            AppDelegate.delay(bySeconds: 0.1, dispatchLevel: .main) {
                self.fastForward(queue:queue)
            }
        }
        else
        {
            self.fastForward(queue:queue)
        }
    }
    
    @IBAction func forwardButtonPressed(){
        
        if self.currentReplay.count<=self.currentNumberOfReplayMove {
            return
        }
        
        let replayPlayerMove = self.currentReplay[self.currentNumberOfReplayMove]
        if replayPlayerMove.playerChanged==true {
            switchMaskButtonPressed()
        }
        else
        {
            switch(replayPlayerMove.moveDirection)
            {
            case PlayerMoveDirection.UP:
                upGameButtonPressed()
                break
            
            case PlayerMoveDirection.DOWN:
                downGameButtonPressed()
                break
            
            case PlayerMoveDirection.LEFT:
                leftGameButtonPressed()
                break
            
            case PlayerMoveDirection.RIGHT:
                rightGameButtonPressed()
                break
            }
        }
        self.currentNumberOfReplayMove += 1
    }
    
    @IBAction func backButtonPressed(){}
    
    @IBAction func stopButtonPressed()
    {
        self.replayStopPressed = true
    }
    
    // MARK: Reset
    @IBAction func resetToBegin()
    {
        map_visible = false
        showPlayerIconOnButton(playerOne: false)
        currentPlayground = PlaygroundBuilder.readFromString(playground: currentPlayground)
        scene.resetGameScene(playground: currentPlayground!)
        presentPlayground()
        self.navigationBarTitle.text = self.currentPlayground?.level_name
    }
    
    func resetReplay()
    {
        self.currentReplay.removeAll()
        self.replays[(currentPlayground?.level_name)!] = self.currentReplay
    }
    
    // MARK: Successful Level finished, show next level
    @IBAction func nextLevelButtonPressed() {
        if mazeEvent == MazeEvent.death_both {
            resetToBegin()
        }
        else {
            self.hideForbiddenImage()
            presentPlayground()
        }
    }
    
    func gameControllerView(active:Bool)
    {
        for view in self.gameControllerView.subviews
        {
            view.isUserInteractionEnabled = active
            if active == true
            {
                view.alpha = 1.0
            }
            else
            {
                view.alpha = 0.5
            }
        }
        
    }
    
    func replayControllerView(active:Bool){
        for view in self.replayButtonsView.subviews {
            if view.tag==1 {
                view.isUserInteractionEnabled = active
                if active == false {
                    view.alpha = 0.5
                }
                else
                {
                    view.alpha = 1.0
                }
            }
        }
    }
}
