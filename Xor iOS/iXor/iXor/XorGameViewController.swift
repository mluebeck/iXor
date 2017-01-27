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
    @IBOutlet var mapLeftUp : UIView!
    @IBOutlet var mapLeftDown : UIView!
    @IBOutlet var mapRightUp : UIView!
    @IBOutlet var mapRightDown : UIView!
    @IBOutlet var mapTextLabel: UILabel! 
    @IBOutlet var xorNavigationItem: UINavigationItem!
    @IBOutlet var successView: UIView!
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var okButton : UIButton!
    @IBOutlet var countMovesView : UIView!
    @IBOutlet var countMovesLabel : UILabel!
    @IBOutlet var progressBar : UIProgressView!
    @IBOutlet var navigationBarTitle : UILabel!
    
    var movesString = "/1000"
    var currentOrientation : Orientation!
    var scene: GameScene!
    var map_visible = false
    var playgrounds = [Int: Playground]()
    var mazeEvent = MazeEvent.redraw
    var currentPlayground : Playground?
    var oldAcceleration : CMAcceleration?
    
    var motionManager: CMMotionManager!

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
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showPlayerIconOnButton(playerOne: false)

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
        
        mapLeftUp.alpha = 0.5
        mapLeftDown.alpha = 0.5
        mapRightUp.alpha = 0.5
        mapRightDown.alpha = 0.5
        
        let paths = Bundle.main.paths(forResourcesOfType: "xor", inDirectory: nil)
        for path in paths {
            let playground = PlaygroundBuilder.readLevelString(filepath:path)
            playgrounds[playground.level_number]=playground
        }
        
        
        presentPlayground()
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
            mapTextLabel.isHidden = true
        }
    }
    
    // present the playground
    func presentPlayground() {
        
        successView.isHidden = true
        collectedMasksLabel.text = String("0")
        
        currentPlayground = playgrounds[1]
        
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
                self.successView.isHidden = false
                self.messageLabel.text = "Du hast es geschafft!\n\nBereit für den nächsten Level?"
                self.okButton.setTitle("OK, weiter geht's!", for: UIControlState.normal)
                
                self.scene.removeAllChildren()
                Playground.currentPlaygroundLevel += 1
                self.currentPlayground?.finished = true
                self.currentPlayground?.justFinished = true
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
                self.successView.isHidden = false
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
    }
    
    func resetMaps() {
        self.mapLeftUp.alpha = 0.5
        self.mapRightUp.alpha = 0.5
        self.mapLeftDown.alpha = 0.5
        self.mapRightDown.alpha = 0.5
        self.currentPlayground?.mapsFound.removeAll()
    }
    
    // segue
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
                    Playground.currentPlaygroundLevel=selectedPlaygroundLevel
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
                self.resetToBegin()
                self.resetMaps()
            }
        }
    }
    
    
    
    
    
    // Direction controls
    @IBAction func leftGameButtonPressed(){
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.LEFT)
    }
    @IBAction func rightGameButtonPressed(){
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.RIGHT)
    }
    @IBAction func upGameButtonPressed(){
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.UP)
    }
    @IBAction func downGameButtonPressed(){
        currentPlayground?.movePlayer(direction: PlayerMoveDirection.DOWN)
    }
    
    // Switch Player
    @IBAction func switchMaskButtonPressed(){
        if (currentPlayground?.numberOfKilledPlayer)!>0 {
            return
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
        let playerOneImage = UIImage(named:"verbot")
        playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
        playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
        playerChangeImage.image = nil
        playerChangeButton.isEnabled = false
        
    }
    
    @IBAction func replayButtonPressed(){}
    @IBAction func forwardButtonPressed(){}
    @IBAction func backButtonPressed(){}
    
    
    // Reset Button
    @IBAction func resetToBegin()
    {
        map_visible = false
        showPlayerIconOnButton(playerOne: false)
        currentPlayground = PlaygroundBuilder.readFromString(playground: currentPlayground)
        scene.resetGameScene(playground: currentPlayground!)
        
        presentPlayground()
        self.navigationBarTitle.text = self.currentPlayground?.level_name
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
            mapTextLabel.isHidden=true
            map_visible = false
        }
    }
    
    func mapTextVisible(){
        if currentPlayground?.mapsFound.count == 0
        {
            mapTextLabel.isHidden = false
        }
        else
        {
            mapTextLabel.isHidden = true
        }

    }
    // Successful Level finished, show next level
    @IBAction func nextLevelButtonPressed() {
        if mazeEvent == MazeEvent.death_both {
            resetToBegin()
        }
        else {
            presentPlayground()
        }
    }
    
    
}
