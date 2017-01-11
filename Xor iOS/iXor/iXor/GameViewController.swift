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


class GameViewController: UIViewController {
    @IBOutlet var playgroundViewConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet var playerButtonsViewHeightConstraint : NSLayoutConstraint!
    var currentOrientation : Orientation!
    var scene: GameScene!
    var playgrounds : Array<Playground>?
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
            //self.currentLayoutConstriants.autoRemoveConstraints()
            if orientation == Orientation.MyViewOrientationPortrait {
                print("orientation Portrait")
                
                print(self.view.bounds.width)
                print(self.view.bounds.height)
                
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width-20
                playerButtonsViewHeightConstraint.constant = 286
                
                //self.currentLayoutConstriants = self.constraintsForPortrait()
            } else {
                print("orientation Landscape")
                
                print(self.view.bounds.width)
                print(self.view.bounds.height)
                
                playerButtonsViewWidthConstraint.constant = self.view.bounds.width - playgroundViewConstraint.constant - 30
                playerButtonsViewHeightConstraint.constant = self.view.bounds.height - 20
                //self.currentLayoutConstriants = self.constraintsForLandscape();
            }
            self.currentOrientation = orientation;
            /*
            if (coordinator) {
                self.swipeView.hidden = true
                let swipeViewPage = self.swipeView.currentPage
    
                [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [self.currentLayoutConstriants autoInstallConstraints];
                    [self.view layoutIfNeeded];
                } completion:nil];
            } else {
                [self.currentLayoutConstriants autoInstallConstraints];
                [self.view layoutIfNeeded];
                [self.swipeView reloadData];
            }
             */
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playground = Playground()
        playground.readLevel(number: 1)
        
        playgrounds = Array<Playground>()

        playgrounds?.append(playground)
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        updateCurrentConstraintsToSize(size: self.view.bounds.size)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        if viewController is LevelTableViewController {
            let levelTableViewController = viewController as! LevelTableViewController
            levelTableViewController.playgrounds = self.playgrounds
        }
    }
}
