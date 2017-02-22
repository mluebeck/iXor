//
//  LevelTableViewController.swift
//  iXor
//
//  Created by Mario Rotz on 11.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class XorLevelTableViewController: UITableViewController
{

    private var playgrounds : [Int:Playground]?
    var playgroundIndices = Array<Int>()
    var currentLevel : Int?
    var selectionFinishedClosure : ((Int) -> ())?
    var resetPressedClosure : (() ->())?
    var lastPlayground : Playground?
    
    var selectedItem : NSIndexPath = NSIndexPath(row: -1, section: 0)
    
    func setPlaygrounds(playgrounds:[Int:Playground]?)
    {
        self.playgrounds = playgrounds
        for i in (playgrounds?.keys)!
        {
            playgroundIndices.append(i)
        }
        playgroundIndices.sort{$0<$1}
    }
    
    @IBAction func backButtonPressed()
    {
        self.dismiss(animated: true, completion: {});
    }
    
    @IBAction func resetPressed()
    {
        if let s = resetPressedClosure
        {
            s()
        }
        self.dismiss(animated: true, completion: {});
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return playgrounds!.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelTableViewCell", for: indexPath) as! LevelTableViewCell

        let playground = playgrounds?[playgroundIndices[indexPath.row]]
        print("adding playground \(playground?.level_name) to Cell")
        if indexPath.row == 0 || playground?.finished == true || indexPath.row==currentLevel!-1
        {
            
            cell.levelLabel?.text = "Level \(playgroundIndices[indexPath.row])"
            cell.descriptionLabel?.text = playground?.level_name
            //cell.textLabel?.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
            if playground?.finished == true
            {
                cell.finishedImageView.image = UIImage(named: "green")
                //cell.detailTextLabel?.text = NSLocalizedString("Completed!", comment: "")
            } else {
                cell.finishedImageView.image = UIImage(named: "yellow")
                //cell.detailTextLabel?.text = NSLocalizedString("Pending", comment: "")
            }
        }
        else
        {
            let lastPlayground = playgrounds?[playgroundIndices[indexPath.row-1]]
            cell.levelLabel?.text = "Level \(playgroundIndices[indexPath.row])"
            cell.descriptionLabel?.text = playground?.level_name
            //cell.textLabel?.font = UIFont(name: "TrebuchetMS-Italic", size: 18)
            if playground?.finished == true
            {
                cell.finishedImageView.image = UIImage(named: "green")
                //cell.detailTextLabel?.text = NSLocalizedString("Completed!", comment: "")
            }
            else
            {
                if !(lastPlayground == nil) && lastPlayground?.finished == true && playground?.finished==false
                {
                    cell.finishedImageView.image = UIImage(named: "yellow")
                }
                else
                {
                    cell.finishedImageView.image = UIImage(named: "red")
                    //                cell.detailTextLabel?.text = NSLocalizedString("Locked!", comment: "")
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let isEnabled = enabled(level: self.playgroundIndices[indexPath.row])
        if isEnabled == true
        {
            self.selectedItem = indexPath as NSIndexPath
            if let s = selectionFinishedClosure
            {
                s((self.playgroundIndices[selectedItem.row]))
            }
            self.dismiss(animated: true, completion: {});
        }
    }
    
    func enabled(level:Int) -> Bool
    {
        var previousLevelFinished=true
        if level>1 && level<(playgrounds?.count)!
        {
            let playground = playgrounds?[level-1]
            if playground?.finished==false
            {
                previousLevelFinished = false
            }
        }
        else
        if level == 1
        {
                return true
        }
        return previousLevelFinished
    }

}
