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

enum Orientation
{
    case MyViewOrientationUnspecified
    case MyViewOrientationPortrait
    case MyViewOrientationLandscape
}

enum ButtonPressed
{
    case NONE
    case LEFT
    case RIGHT
    case UP
    case DOWN
}

class XorGameViewController: UIViewController
{
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var longButtonPressMode = ButtonPressed.NONE
    
    @IBOutlet var musicButton : UIButton!
    @IBOutlet var playgroundViewConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var countMovesViewWidthConstraint : NSLayoutConstraint!
    
    @IBOutlet var gameControllerViewHeightConstraint :  NSLayoutConstraint!
    @IBOutlet var gameControllerViewWidthConstraint :  NSLayoutConstraint!
    @IBOutlet var controllerView  :  UIView!
    
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
    @IBOutlet var verbotImage : UIImageView!
    
    @IBOutlet var fastForwardButton : UIButton!
    @IBOutlet var replayButton : UIButton!
    @IBOutlet var replayLabel : UILabel!
    @IBOutlet var scrollView : UIScrollView!
    
    var currentOrientation : Orientation!
    var reloadFlag = false
    
    var levelButtonPressed = false
    
    // Game Scene
    var scene: GameScene!
    
    // for game logic
    var movesString = "/"+String(PlaygroundBuilder.Constants.maximumMoves)
    static var currentPlaygroundLevel = 1
    var map_visible = false
    var mazeEvent = MazeEvent.redraw

    
    // motion
    var oldAcceleration : CMAcceleration?
    var motionManager: CMMotionManager!
    
    // Replay
    var replays = [String : Array<Playground>]()
    var replayTime = 2.0
    var replayMode = false
    var replayStopPressed = false
    var currentNumberOfReplayMove = 0
    
    // MARK: Rotation and Status Bar
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return [.portrait, .portraitUpsideDown, .landscape]
    }
    
    // MARK: view constraints
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        updateCurrentConstraintsToSize(size: self.view.bounds.size)
    }
    
    func updateCurrentConstraintsToSize(size:CGSize)
    {
        var  orientation : Orientation!
        if size.width > size.height
        {
            orientation = Orientation.MyViewOrientationLandscape
            playgroundViewConstraint.constant = self.view.frame.height-20
        }
        else
        {
            orientation = Orientation.MyViewOrientationPortrait
            playgroundViewConstraint.constant = self.view.frame.width-20
        }
        if self.currentOrientation != orientation && orientation != Orientation.MyViewOrientationUnspecified
        {
            var zuege = 0
            if self.scene != nil
            {
                zuege = self.scene.playground.anzahl_spielzuege
            }
            if orientation == Orientation.MyViewOrientationPortrait
            {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height / CGFloat(2.25)
                movesString="/"+String(PlaygroundBuilder.Constants.maximumMoves)
                self.countMovesLabel.text = String("\(zuege)")
            }
            else
            {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width - playgroundViewConstraint.constant - 15
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height
                movesString=""
                self.countMovesLabel.text = String("\(zuege)")
            }
            self.currentOrientation = orientation;
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switchAndShowPlayerIconOnButton(playerOne: false,reorientCamera: true)
        self.playerChangeNotAllowedImageOverPlayerChangeButton(visible:false)
        if self.scene != nil
        {
            self.navigationBarTitle.text = self.scene.playground.level_name
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(XorGameViewController.updateNotificationSent),
                                               name: NSNotification.Name(rawValue: drawEndedNotificationKey), object: nil)

        //drawCircleSegment(index:2)
    }
    
    func updateNotificationSent()
    {
        print("notifcation end event!")
        switch(self.longButtonPressMode)
        {
        case ButtonPressed.LEFT:
            self.leftGameButtonPressed()
            break
        case ButtonPressed.RIGHT:
            self.rightGameButtonPressed()
            break
        case ButtonPressed.UP:
            self.upGameButtonPressed()
            break
        case ButtonPressed.DOWN:
            self.downGameButtonPressed()
            break
        default:
            break
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
       
        super.viewWillAppear(animated)
        
        //                
        if map_visible == false
        {
            mapTextView.show(visible: map_visible)
        }
        replayControllerView(active: false)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if self.levelButtonPressed==true
        {
            self.levelButtonPressed=false
            if self.mazeEvent==MazeEvent.exit_found
            {
                levelSuccessfulFinished()
            }
        }
        else
        {
            self.resetMaps()
            self.replayLabel.isHidden = true
            self.presentPlayground()
        }
        /*
        if self.scene.playground.akt_spieler_ist_playerOne == true
        {
            self.scene.playground.positionPlayerOne = self.scene.playground.playerPosition
        }
        else
        {
            self.scene.playground.positionPlayerTwo = self.scene.playground.playerPosition
        }
         */
        if self.reloadFlag == true
        {
            self.scene.updateViewController!(MazeEvent.reloadAll)
            self.reloadFlag = false
            
        }
    }
    
    func resetLabels()
    {
        successView.show(visible: false)
        collectedMasksLabel.text = String("0")
        let gesMask = self.scene.playground.masken_gesamtanzahl
        collectedMasksLabel!.text! = "0/\(gesMask)"
        
        self.playerChangeNotAllowedImageOverPlayerChangeButton(visible:!(self.scene.playground.numberOfKilledPlayer == 0))
        
        let zuege = self.scene.playground.anzahl_spielzuege
        self.progressBar.setProgress(Float(zuege)/Float(PlaygroundBuilder.Constants.maximumMoves), animated: true)
        self.countMovesLabel.text = String("\(zuege)")
        let maskenTotal = self.scene.playground.masken_gesamtanzahl
        let masken = self.scene.playground.masken_gesammelt
        self.collectedMasksLabel!.text! = String("\(masken)/\(maskenTotal)")
        
    }
    
    // MARK:  present the playground
    func presentPlayground() {
        //self.playgroundView.isHidden=true

        successView.show(visible: false)
        collectedMasksLabel.text = String("0")
        
        
        
        self.scene = GameScene(size: playgroundView.bounds.size, playground:XorGameViewController.appDelegate.playgroundList.playgrounds[XorGameViewController.currentPlaygroundLevel]!)

        let gesMask = self.scene.playground.masken_gesamtanzahl
        collectedMasksLabel!.text! = "0/\(gesMask)"
        playgroundView.isMultipleTouchEnabled = false
        self.scene.scaleMode = .aspectFill
        self.scene.backgroundColor = UIColor.lightGray
        self.scene.updateViewController = {
            mazeEvent in
            self.mazeEvent = mazeEvent
            switch(mazeEvent)
            {
            case MazeEvent.switchPlayer:
                self.switchPlayerPressedWithoutCameraReorientation()
                break
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

                if Playground.finalLevel == self.scene.playground.level_number
                {
                    self.successView.show(visible: true)
                    self.messageLabel.text = "Du hast ALLE LEVEL geschafft!\n\nGratulation!"
                    self.okButton.setTitle("OK!", for: UIControlState.normal)
                    self.scene.isHidden=true
                    XorGameViewController.currentPlaygroundLevel = 1
                    self.scene.playground.finished = true
                    self.scene.playground.justFinished = false
                }
                else
                {
                    self.successView.show(visible: true)
                    self.messageLabel.text = "Du hast es geschafft!\n\nBereit für den nächsten Level?"
                    self.okButton.setTitle("OK, weiter geht's!", for: UIControlState.normal)
                    self.scene.isHidden=true
                    XorGameViewController.currentPlaygroundLevel += 1
                    self.scene.playground.finished = true
                    self.scene.playground.justFinished = false
                }
                
                break
            case MazeEvent.bad_mask_found:
                self.scene.playground.badMaskOperation()
                break
            case MazeEvent.movesExceeded:
                    self.successView.show(visible: true)
                    self.messageLabel.text = "Oh nein! Du bist zu viele Schritte gegangen!\n\nVersuch' es gleich nochmal!"
                    self.okButton.layer.borderWidth=2.0
                    self.okButton.layer.borderColor=UIColor.gray.cgColor
                    self.okButton.setTitle("OK, weiter geht's!", for: UIControlState.normal)
                    self.scene.playground.justFinished = false
                    self.scene.isHidden=true
                    //self.currentPlayground?.finished = false
                break
            case MazeEvent.death_player1:
                self.replayLabel.isHidden = false
                self.replayLabel.text="Spieler 1 getötet!"
                //self.switchAndShowPlayerIconOnButton(playerOne:true)
                self.playerChangeNotAllowedImageOverPlayerChangeButton(visible: true)
                AppDelegate.delay(bySeconds: 2.0, dispatchLevel: .main) {
                    self.replayLabel.isHidden = true
                    self.switchAndShowPlayerIconOnButton(playerOne: true,reorientCamera: true)
                }
                
                //let sprite = SKSpriteNode.init(imageNamed: "skull")
                //let mazeElement = MazeElement(mazeElementType: MazeElementType.skull, sprite:sprite)
                //self.scene.drawSprite(element: mazeElement, position: (self.currentPlayground?.playerPosition)!, duration: 1.0, completed: nil)
                
                /*
                let zoomInAction = SKAction.scale(to: 2, duration: 5)
                
                sprite.run(
                    
                    SKAction.repeat(
                        zoomInAction,//SKAction.animate(with: self.scene.skullFrames,timePerFrame: 0.1,resize: true,restore: true),
                        count:1
                    ),completion:
                    {
                     })
                */
                break
                case MazeEvent.death_player2:
                self.replayLabel.isHidden = false
                self.replayLabel.text="Spieler 2 getötet!"
                //self.switchAndShowPlayerIconOnButton(playerOne:false)
                self.playerChangeNotAllowedImageOverPlayerChangeButton(visible:true)
                AppDelegate.delay(bySeconds: 1.5, dispatchLevel: .main) {
                    self.replayLabel.isHidden = true
                    self.switchAndShowPlayerIconOnButton(playerOne: false,reorientCamera: true)
                }
                break
            case MazeEvent.death_both:
                AppDelegate.delay(bySeconds: 1.5, dispatchLevel: .main) {
                    self.successView.show(visible: true)
                    self.messageLabel.text = "Oh nein! Beide Spieler sind tot!\n\nVersuch' es gleich nochmal!"
                    self.okButton.setTitle("OK, weiter geht's!", for: UIControlState.normal)
                    self.scene.playground.justFinished = false
                    self.scene.isHidden=true

                    //self.currentPlayground?.finished = false
                }
                break
            case MazeEvent.reloadAll:
                
                self.successView.show(visible: true)
                self.messageLabel.text = "Resetting all..."
                self.okButton.isHidden=true
                self.scene.isHidden = true
                
                DispatchQueue.global().async {

                        XorGameViewController.appDelegate.playgroundList = PlaygroundBuilder.playgrounds(levelsToLoad, fromArchive: false)
                        let playgroundDict  = XorGameViewController.appDelegate.playgroundList.playgrounds
                    
                        self.scene.playground = playgroundDict[1]!
                    
                    DispatchQueue.main.async(execute: {
                        self.resetToBegin(clearReplay: true)
                        self.resetMaps()
                        self.okButton.isHidden=false
                        self.scene.isHidden = false
                        self.countMovesLabel.text = "0"

                    })
                    
                }
                
                
                
                break
                
            default:
                break;
            }
            
            // always : one step further 
            let zuege = self.scene.playground.anzahl_spielzuege
            self.progressBar.setProgress(Float(zuege)/Float(PlaygroundBuilder.Constants.maximumMoves), animated: true)
            self.countMovesLabel.text = String("\(zuege)")
            let maskenTotal = self.scene.playground.masken_gesamtanzahl
            let masken = self.scene.playground.masken_gesammelt
            self.collectedMasksLabel!.text! = String("\(masken)/\(maskenTotal)")
        }

        // Present the scene.

        self.playgroundView.presentScene(self.scene) //, transition: transition)

        AppDelegate.delay(bySeconds: 0.5, dispatchLevel: .main) {
            self.playgroundView.isHidden=false
            self.scene.playground.testChickenAcidFishBomb()

        }
    }
    
    // MARK: MAPS
    
    func resetMaps() {
        self.mapLeftUp.alpha = 0.5
        self.mapRightUp.alpha = 0.5
        self.mapLeftDown.alpha = 0.5
        self.mapRightDown.alpha = 0.5
        if self.scene != nil {
            self.scene.playground.mapsFound.removeAll()
        }
    }
    
    // Show Map Button
    @IBAction func mapButtonPressed()
    {
        mapTextView.show(visible: (self.scene.playground.mapsFound.count == 0))
        if map_visible==false {
            self.scene.showMap()
            map_visible = true
        }
        else
        {
            self.scene.hideMap()
            mapTextView.show(visible: false)
            map_visible = false
        }
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        if viewController is XorLevelTableViewController {
            self.levelButtonPressed = true
            let levelTableViewController = viewController as! XorLevelTableViewController
            levelTableViewController.setPlaygrounds(playgrounds:XorGameViewController.appDelegate.playgroundList.playgrounds)
            levelTableViewController.currentLevel = self.scene.playground.level_number
            levelTableViewController.selectionFinishedClosure = {
                selectedPlaygroundLevel in
                if selectedPlaygroundLevel >= 0 {
                    self.scene.playground =  XorGameViewController.appDelegate.playgroundList.playgrounds[selectedPlaygroundLevel]!
                    //self.scene.resetGameScene(playground: self.scene.playground)
                    XorGameViewController.currentPlaygroundLevel=selectedPlaygroundLevel
                    self.countMovesLabel.text = "0"
                    self.navigationBarTitle.text = self.scene.playground.level_name
                    Playground.replay.removeAll()
                    self.resetToBegin(clearReplay: true)
                    self.resetMaps()
                    print(self.scene.playground)
                    
                }
                return
            }
            levelTableViewController.resetPressedClosure = {
                if self.replayMode==true
                {
                    self.replayButtonPressed()
                }
                self.countMovesLabel.text = "0"
                self.resetToBegin(clearReplay: true)
                self.resetMaps()
                
            }
            levelTableViewController.resetAllPressedClosure = {
                self.reloadFlag = true
            }
        }
        else
        if viewController is UINavigationController
        {
            self.levelButtonPressed = true
        }
    }
    
    
    
    
    func reloadAll()
    {
        self.successView.show(visible: true)
        self.view.bringSubview(toFront: self.successView)
        self.messageLabel.text = "Reload all..."
        self.okButton.isHidden=true
        self.scene.isHidden=true
        
        
        XorGameViewController.appDelegate.playgroundList = PlaygroundBuilder.playgrounds(levelsToLoad, fromArchive: false)
        self.countMovesLabel.text = "0"
        let playgroundDict  = XorGameViewController.appDelegate.playgroundList.playgrounds
        self.scene.playground = playgroundDict[1]!
        
        self.resetToBegin(clearReplay: true)
        self.resetMaps()
        
        self.successView.show(visible: false)
        self.okButton.isHidden=false
        self.scene.isHidden=false
    }
    
    
    // MARK: Direction controls
    @IBAction func leftGameButtonPressed(){
        if mazeEvent==MazeEvent.exit_found
        {
            return
        }
        self.scene.playground.movePlayer(direction: PlayerMoveDirection.LEFT,replaying:false)
    }
    
    @IBAction func rightGameButtonPressed(){
        if mazeEvent==MazeEvent.exit_found
        {
            return
        }
        self.scene.playground.movePlayer(direction: PlayerMoveDirection.RIGHT,replaying:false)
    }
    @IBAction func upGameButtonPressed(){
        if mazeEvent==MazeEvent.exit_found
        {
            return
        }
        self.scene.playground.movePlayer(direction: PlayerMoveDirection.UP,replaying:false)
    }
    @IBAction func downGameButtonPressed(){
        if mazeEvent==MazeEvent.exit_found
        {
            return
        }
        self.scene.playground.movePlayer(direction: PlayerMoveDirection.DOWN,replaying:false)
    }
    
    // MARK: Switch Player
    @IBAction func switchPlayerPressed()
    {
        if mazeEvent==MazeEvent.exit_found
        {
            return
        }
        if (self.scene.playground.numberOfKilledPlayer)==0
        {
            let previousPlayground = self.scene.playground.copy() as! Playground
            previousPlayground.moveDirection=PlayerMoveDirection.PLAYERCHANGED
            if self.replayMode==false
            {
                Playground.replay.append(previousPlayground)
            }
            switchAndShowPlayerIconOnButton(playerOne: (self.scene.playground.akt_spieler_ist_playerOne),reorientCamera: true)
        }
    }
    
    func switchPlayerPressedWithoutCameraReorientation()
    {
        if (self.scene.playground.numberOfKilledPlayer)==0
        {
            switchAndShowPlayerIconOnButton(playerOne: (self.scene.playground.akt_spieler_ist_playerOne),reorientCamera: false)
        }
    }
    
    
    func switchAndShowPlayerIconOnButton(playerOne:Bool,reorientCamera:Bool)
    {
        playerChangeButton.isEnabled = true
        if playerOne == true
        {
            if !(self.scene==nil)
            {
                self.scene.switchToPlayerTwo(reorientCamera:reorientCamera)
                self.scene.playground.akt_spieler_ist_playerOne = false
            }
        }
        else
        {
            if !(self.scene==nil)
            {
                self.scene.switchToPlayerOne(reorientCamera:reorientCamera)
                self.scene.playground.akt_spieler_ist_playerOne = true
            }
        }
        self.changePlayerIconOnButton(playerOne: playerOne)
    }
    
    func changePlayerIconOnButton(playerOne:Bool) {
        if playerOne == true
        {
            let playerOneImage = UIImage(named:"spieler1")
            //playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            //playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage
        }
        else
        {
            let playerOneImage = UIImage(named:"spieler2")
            //playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            //playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage
        }
    }
    
    func playerChangeNotAllowedImageOverPlayerChangeButton(visible:Bool)
    {
        verbotImage.isHidden = !visible
        playerChangeButton.isEnabled = !visible
    }
    
    
    // MARK: UNDO AND REPLAY
    
    func gotoFirst()
    {
        if Playground.replay.count>0
        {
            self.changePlayerIconOnButton(playerOne: !(Playground.replay.first?.akt_spieler_ist_playerOne)!)
            self.scene.playground = Playground.replay.first!
            self.scene.resetGameScene(playground: self.scene.playground)
            self.scene.playground.setCameraPositionToPlayerOne()// updateCameraPosition(PlayerMoveDirection.UP)
            self.resetLabels()
            Playground.replay.removeAll()
            if self.scene.playground.numberOfKilledPlayer>0
            {
                self.playerChangeNotAllowedImageOverPlayerChangeButton(visible:true)
            }
        }
    }
    
    @IBAction func undoButtonPressed()
    {
        let counter = Playground.replay.count
        if counter<1
        {
            return
        }
        self.replayStopPressed = false
        self.changePlayerIconOnButton(playerOne: !(Playground.replay.last?.akt_spieler_ist_playerOne)!)
        
        self.scene.playground = Playground.replay.last!
        self.scene.resetGameScene(playground: self.scene.playground)
        self.scene.playground.updateCameraPosition(PlayerMoveDirection.UP)
        self.resetLabels()
        if Playground.replay.count>0
        {
            Playground.replay.removeLast()
        }
        if self.scene.playground.invisible==true
        {
            self.scene.playground.badMaskOperation()
        }
    }

    @IBAction func replayButtonPressed()
    {
        if Playground.replay.count==0
        {
            return
        }
        if self.replayMode==true
        {
            self.replayLabel.isHidden = true
            self.replayMode = false
            self.gameControllerView(active: true)
            self.replayControllerView(active: false)
            self.replayButton.setTitle("Replay", for: UIControlState.normal)
            self.replayButton.setTitle("Replay", for: UIControlState.highlighted)
            var diff = Playground.replay.count-self.currentNumberOfReplayMove
            while !(diff == 0)
            {
                self.scene.playground = Playground.replay.last!
                Playground.replay.removeLast()
                diff -= 1
            }
        }
        else
        {
            self.replayLabel.isHidden = false
            self.replayBlink()
            Playground.replay.append(self.scene.playground)
            self.scene.playground = Playground.replay.first!
            self.gameControllerView(active: false)
            self.replayControllerView(active: true)
            self.replayButton.setTitle("EXIT", for: UIControlState.normal)
            self.replayButton.setTitle("EXIT", for: UIControlState.highlighted)
            self.replayMode = true
            self.replayTime = 0.5
            self.currentNumberOfReplayMove = 0
            self.resetToBegin(clearReplay: false)
        }
    }

    func replayBlink()
    {
        if self.replayLabel.isHidden==false
        {
            if self.replayLabel.text == "REPLAY MODE"
            {
                self.replayLabel.text = ""
            }
            else
            {
                self.replayLabel.text = "REPLAY MODE"
            }
            AppDelegate.delay(bySeconds: 0.5, dispatchLevel: .main)
            {
                self.replayBlink()
            }
        }
    }
    
    func fastForward(position:Int,recursive:Bool)
    {
        if Playground.replay.count<=position || self.replayStopPressed == true
        {
            fastForwardButton.setTitle("FF", for: UIControlState.normal)
            fastForwardButton.setTitle("FF", for: UIControlState.highlighted)
            self.replayStopPressed = true
            return
        }
        
        let changePlayer = Playground.replay[position].moveDirection==PlayerMoveDirection.PLAYERCHANGED
            
        self.changePlayerIconOnButton(playerOne: changePlayer)
        self.scene.playground = Playground.replay[position]
        
        //self.scene.playground.movePlayer(queue:[self.scene.playground.moveDirection])
        
        
        self.scene.resetGameScene(playground: self.scene.playground)
        
        //self.scene.playground.updateCameraPosition(self.scene.playground.moveDirection)
        print(self.scene.playground)
        self.resetLabels()
        
        self.currentNumberOfReplayMove += 1
        print("currentNumberOfReplayMove:\(self.currentNumberOfReplayMove)")
        print("position:\(position)")
        
        self.scene.moveCameraToPlaygroundCoordinates(position: self.scene.playground.cameraLeftTopPosition)
        
        
        
        AppDelegate.delay(bySeconds: self.replayTime, dispatchLevel: .main)
        {
            if recursive==true
            {
                self.fastForward(position:position+1,recursive: recursive)
            }
        }
    }
    
    func fastForward2(position:Int,recursive:Bool)
    {
        if position>=Playground.replay.count-1  || self.replayStopPressed == true
        {
            fastForwardButton.setTitle("FF", for: UIControlState.normal)
            fastForwardButton.setTitle("FF", for: UIControlState.highlighted)
            self.replayStopPressed = true
            self.scene.playground.endOfAnimation = {}
            return
        }
       
        self.changePlayerIconOnButton(playerOne: !(Playground.replay[position].akt_spieler_ist_playerOne))
        self.scene.playground = Playground.replay[position]
        self.scene.resetGameScene(playground: self.scene.playground)
        if recursive==true
        {
            self.scene.playground.endOfAnimation =
            {
                if self.scene.playground.playerJustKilled==false
                {
                    self.fastForward2(position: position+1, recursive: true)
                }
                else
                {
                    self.scene.playground.playerJustKilled = false
                }
            }
        }
        if self.scene.playground.moveDirection == PlayerMoveDirection.PLAYERCHANGED
        {
            self.scene.playground.changePlayer()
        }
        else
        if self.scene.playground.moveDirection != PlayerMoveDirection.NONE
        {
            self.scene.playground.movePlayer(direction: self.scene.playground.moveDirection,replaying:true)
        }
        else
        {
           self.fastForward2(position: position+1, recursive: true)
        }
        
    }
    
    func fastForwardButtonState()
    {
        if fastForwardButton.titleLabel?.text == "FF"
        {
            self.replayStopPressed = false
            fastForwardButton.setTitle("STOP", for: UIControlState.normal)
            fastForwardButton.setTitle("STOP", for: UIControlState.highlighted)
            
        }
        else {
            fastForwardButton.setTitle("FF", for: UIControlState.normal)
            fastForwardButton.setTitle("FF", for: UIControlState.highlighted)
            self.replayStopPressed = true
        }
    }
    
    @IBAction func fastforwarButtonPressed()
    {
        if fastForwardButton.titleLabel?.text == "STOP"
        {
            fastForwardButton.setTitle("FF", for: UIControlState.normal)
            fastForwardButton.setTitle("FF", for: UIControlState.highlighted)
            self.replayStopPressed = true
            return
        }
        self.fastForwardButtonState()
        self.replayStopPressed = false
        self.currentNumberOfReplayMove=0
        self.resetToBegin(clearReplay: false)
        AppDelegate.delay(bySeconds: self.replayTime, dispatchLevel: .main)
        {
            self.fastForward(position:0,recursive: true)
        }
    }
    
    @IBAction func forwardButtonPressed()
    {
        if Playground.replay.count>self.currentNumberOfReplayMove
        {
            fastForward(position: self.currentNumberOfReplayMove+1,recursive: false)
        }
    }
    
    @IBAction func stopButtonPressed()
    {
        self.replayStopPressed = true
    }
    
    // MARK: Reset
    
    func resetToBegin(clearReplay:Bool)
    {
        if Playground.replay.count > 0 {
            self.scene.playground = Playground.replay.first!
        }
        self.replayStopPressed = false
        if clearReplay==true
        {
            Playground.replay.removeAll()
        }
        self.scene.playground.anzahl_spielzuege = 0
        self.scene.updateWithNewPlayground(self.scene.playground)
        self.scene.resetGameScene(playground: self.scene.playground)
        self.scene.initWithPlayerOne(reorientCamera: true)
        self.resetLabels()
        map_visible = false
        playerChangeNotAllowedImageOverPlayerChangeButton(visible:false)
        self.changePlayerIconOnButton(playerOne: false)
        self.navigationBarTitle.text = self.scene.playground.level_name
        self.scene.playground.testChickenAcidFishBomb()
        print(self.scene.playground)

    }
    
    func reset(level:Int)
    {
        if let playground =  XorGameViewController.appDelegate.playgroundList.playgrounds[level]
        {
            self.scene.playground = playground
            self.replayStopPressed = false
            Playground.replay.removeAll()
            self.scene.updateWithNewPlayground(self.scene.playground)
            self.scene.resetGameScene(playground: self.scene.playground)
            self.scene.initWithPlayerOne(reorientCamera: true)
            self.resetLabels()
            map_visible = false
            playerChangeNotAllowedImageOverPlayerChangeButton(visible:false)
            self.changePlayerIconOnButton(playerOne: false)
            self.navigationBarTitle.text = self.scene.playground.level_name
            print(playground)
            self.scene.playground.testChickenAcidFishBomb()

        }
    }
    
    // MARK: Level finished, show next level
    @IBAction func nextLevelButtonPressed()
    {
        switch(mazeEvent)
        {
        case MazeEvent.death_both:
            successView.show(visible: false)
            //AppDelegate.delay(bySeconds: 0.5, dispatchLevel: .main, closure: {
                //self.resetToBegin()
                self.scene.isHidden=false
                self.gotoFirst()
            //})
            
            break
        case  MazeEvent.movesExceeded:
        
            successView.show(visible: false)
            //self.resetToBegin()
            self.scene.isHidden=false
            self.gotoFirst()
            break
        case MazeEvent.exit_found:
            self.levelSuccessfulFinished()
            break
        default:
            break
        }
        
    }
    
    func levelSuccessfulFinished()
    {
        successView.show(visible: false)
        self.scene.isHidden=false
        self.resetToBegin(clearReplay: true)
        self.scene.playground.finished = true
        self.scene.playground.justFinished = false
        XorGameViewController.appDelegate.playgroundList.playgrounds[self.scene.playground.level_number] = self.scene.playground
        
        self.reset(level: self.scene.playground.level_number+1)
        mazeEvent = MazeEvent.none
    }

    func gameControllerView(active:Bool)
    {
        for view in self.controllerView.subviews
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
    
    @IBAction func musicButtonPressed()
    {
        if XorGameViewController.appDelegate.musicBox.isPlaying()
        {
            XorGameViewController.appDelegate.musicBox.pause()
            musicButton.setImage(UIImage.init(named: "music_off"), for: UIControlState.normal)
            
        }
        else
        {
            XorGameViewController.appDelegate.musicBox.play()
            musicButton.setImage(UIImage.init(named: "music"), for: UIControlState.normal)
            
        }
    }
    
    func replayControllerView(active:Bool)
    {
        for view in self.replayButtonsView.subviews
        {
            if view.tag==1
            {
                view.isUserInteractionEnabled = active
                if active == false
                {
                    view.alpha = 0.5
                }
                else
                {
                    view.alpha = 1.0
                }
            }
        }
    }
    
    @IBAction func longButtonPressedGestureUp(guesture: UILongPressGestureRecognizer)
    {
        if guesture.state == UIGestureRecognizerState.ended
        {
            self.longButtonPressMode=ButtonPressed.NONE
        }
        else
        {
            self.longButtonPressMode=ButtonPressed.UP
            self.upGameButtonPressed()
        }
        //   let button = sender
     //   print("Sender:\(button.accessibilityIdentifier)")
    }
    @IBAction func longButtonPressedGestureDown(guesture: UILongPressGestureRecognizer)
    {
        if guesture.state == UIGestureRecognizerState.ended
        {
            self.longButtonPressMode=ButtonPressed.NONE
        }
        else
        {
            self.longButtonPressMode=ButtonPressed.DOWN
            self.downGameButtonPressed()
        }
        //   let button = sender
        //   print("Sender:\(button.accessibilityIdentifier)")
    }
    @IBAction func longButtonPressedGestureLeft(guesture: UILongPressGestureRecognizer)
    {
        if guesture.state == UIGestureRecognizerState.ended
        {
            self.longButtonPressMode=ButtonPressed.NONE
        }
        else
        {
            self.longButtonPressMode=ButtonPressed.LEFT
            self.leftGameButtonPressed()
        }
        //   let button = sender
        //   print("Sender:\(button.accessibilityIdentifier)")
    }
    @IBAction func longButtonPressedGestureRight(guesture: UILongPressGestureRecognizer)
    {
        if guesture.state == UIGestureRecognizerState.ended
        {
            self.longButtonPressMode=ButtonPressed.NONE
        }
        else
        {
            self.longButtonPressMode=ButtonPressed.RIGHT
            self.rightGameButtonPressed()
        }
        //   let button = sender
        //   print("Sender:\(button.accessibilityIdentifier)")
    }
    
    @IBAction func buttonReleased()
    {
        
    }
    
    
}
