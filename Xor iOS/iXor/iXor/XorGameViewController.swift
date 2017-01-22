//
//  GameViewController.swift
//  iXor
//
//  Created by Mario Rotz on 04.12.16.
//  Copyright © 2016 MarioRotz. All rights reserved.
//

import UIKit
import SpriteKit

enum Orientation {
    case MyViewOrientationUnspecified
    case MyViewOrientationPortrait
    case MyViewOrientationLandscape
}


class XorGameViewController: UIViewController {
    @IBOutlet var playgroundViewConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewHeightConstraint : NSLayoutConstraint!
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
    
    var currentOrientation : Orientation!
    var scene: GameScene!
    var playgrounds : Array<Playground>?
    var currentPlayground : Playground?
    var playerkilled = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown, .landscape]
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
            if orientation == Orientation.MyViewOrientationPortrait {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height / CGFloat(2.25)
                
            } else {
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width - playgroundViewConstraint.constant - 15
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height
            }
            self.currentOrientation = orientation;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapLeftUp.alpha = 0.5
        mapLeftDown.alpha = 0.5
        mapRightUp.alpha = 0.5
        mapRightDown.alpha = 0.5
        
        let paths = Bundle.main.paths(forResourcesOfType: "xor", inDirectory: nil)
        playgrounds = Array<Playground>()
        for path in paths {
            let playground = PlaygroundBuilder.readLevelString(filepath:path)
            playgrounds?.append(playground)
        }
        presentPlayground()
    }
    
    
    func presentPlayground() {
        successView.isHidden = true
        collectedMasksLabel.text = String("0")
        
        currentPlayground = playgrounds?[Playground.currentPlaygroundLevel-1]
        if let gesMask = self.currentPlayground?.anzahl_masken {
            collectedMasksLabel!.text! = "0 of \(gesMask)"
        }
        playgroundView.isMultipleTouchEnabled = false
        
        scene = GameScene(size: playgroundView.bounds.size, playground:self.currentPlayground!)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.lightGray
        scene.updateViewController = {
            mazeElementType in
            switch(mazeElementType)
            {
            case MazeElementType.map_1:
                self.mapLeftUp.alpha = 1.0
                break;
            case MazeElementType.map_2:
                self.mapRightUp.alpha = 1.0
                break;
            case MazeElementType.map_3:
                self.mapLeftDown.alpha = 1.0
                break;
            case MazeElementType.map_4:
                self.mapRightDown.alpha = 1.0
                break;
            case MazeElementType.mask:
                break;
            case MazeElementType.exit:
                // Hier Erfolg animieren und Level freischalten
                self.successView.isHidden = false
                self.scene.removeAllChildren()
                Playground.currentPlaygroundLevel += 1
                self.currentPlayground?.justFinished = false
                break
            
            case MazeElementType.bad_mask:
                self.currentPlayground?.badMaskOperation()
                break
            case MazeElementType.death:
                self.playerKilled()
                break
            case MazeElementType.death_both:
                
                break
            default:
                break;
            }
            // always : one step further 
            if let zuege = self.currentPlayground?.anzahl_spielzuege {
                if zuege == 1 {
                    self.xorNavigationItem.title = String("One of 1000 Steps.")
                } else {
                    self.xorNavigationItem.title = String("\(zuege) of 1000 Steps.")
                }
            }
            if let masken = self.currentPlayground?.anzahl_gesammelter_masken {
                if let maskenTotal = self.currentPlayground?.anzahl_masken {
                    self.collectedMasksLabel!.text! = String("\(masken) of \(maskenTotal)")
                    
                }
            }
        }
        
        // Present the scene.
        playgroundView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        updateCurrentConstraintsToSize(size: self.view.bounds.size)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        if viewController is XorLevelTableViewController {
            let levelTableViewController = viewController as! XorLevelTableViewController
            levelTableViewController.playgrounds = self.playgrounds
            levelTableViewController.currentLevel = self.currentPlayground?.level_number
            levelTableViewController.selectionFinishedClosure = {
                selectedPlaygroundLevel in
                if selectedPlaygroundLevel >= 0 {
                    self.currentPlayground = self.playgrounds?[selectedPlaygroundLevel]
                    self.currentPlayground = PlaygroundBuilder.readLevel(number: selectedPlaygroundLevel+1,playground:self.currentPlayground)
                    Playground.currentPlaygroundLevel=selectedPlaygroundLevel+1
                    //self.scene = GameScene()
                    //self.scene.drawWholePlayground()
                    self.presentPlayground()
                }
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentPlayground?.map_flag == false
        {
            mapTextLabel.isHidden = true
        }
    }
    
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
    
    @IBAction func switchMaskButtonPressed(){
        if playerkilled == true {
            return
        }
        if currentPlayground?.akt_spieler_ist_playerOne == true
        {
            scene.switchToPlayerTwo()
            currentPlayground?.akt_spieler_ist_playerOne = false
            
            let playerOneImage = UIImage(named:"spieler1")
            playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage
        }
        else
        {
            scene.switchToPlayerOne()
            currentPlayground?.akt_spieler_ist_playerOne = true
            let playerOneImage = UIImage(named:"spieler2")
            playerChangeButton.setImage(playerOneImage, for: UIControlState.highlighted)
            playerChangeButton.setImage(playerOneImage, for: UIControlState.normal)
            playerChangeImage.image = playerOneImage

        }
    }
    
    func playerKilled() {
        switchMaskButtonPressed()
        playerkilled=true
    }
    
    
    @IBAction func replayButtonPressed(){}
    @IBAction func forwardButtonPressed(){}
    @IBAction func backButtonPressed(){}
    
    @IBAction func mapButtonPressed(){
        
        mapTextVisible()
        if currentPlayground?.map_flag==false {
            scene.showMap()
            currentPlayground?.map_flag = true
        }
        else
        {
            scene.hideMap()
            mapTextLabel.isHidden=true
            currentPlayground?.map_flag = false 
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
    
    @IBAction func nextLevelButtonPressed() {
        presentPlayground()
    }
}
