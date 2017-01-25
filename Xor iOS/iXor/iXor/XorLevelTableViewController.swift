//
//  LevelTableViewController.swift
//  iXor
//
//  Created by Mario Rotz on 11.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class XorLevelTableViewController: UITableViewController {

    private var playgrounds : [Int:Playground]?
    var playgroundIndices = Array<Int>()
    var currentLevel : Int?
    var selectionFinishedClosure : ((Int) -> ())?
    var resetPressedClosure : (() ->())?
    
    var selectedItem : NSIndexPath = NSIndexPath(row: -1, section: 0)
    
    func setPlaygrounds(playgrounds:[Int:Playground]?){
        self.playgrounds = playgrounds
        for i in (playgrounds?.keys)! {
            playgroundIndices.append(i)
        }
        playgroundIndices.sort{$0<$1}
    }
    
    @IBAction func backButtonPressed()
    {
        self.dismiss(animated: true, completion: {});
        //self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func resetPressed()
    {
        if let s = resetPressedClosure {
            s()
        }
        self.dismiss(animated: true, completion: {});
        //self.navigationController?.popViewControllerAnimated(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playgrounds!.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let playground = playgrounds?[playgroundIndices[indexPath.row]]
        print("adding playground \(playground?.level_name) to Cell")
        if indexPath.row == 0 || playground?.finished == true || indexPath.row==currentLevel!-1
        {
            cell.textLabel?.text = "Level \(playgroundIndices[indexPath.row]) - "+(playground?.level_name)!
            cell.textLabel?.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
            if playground?.finished == true
            {
                cell.detailTextLabel?.text = "Completed!"
            } else {
                cell.detailTextLabel?.text = "Pending"
            }
        }
        else {
            cell.textLabel?.text = "Level \(playgroundIndices[indexPath.row]) - "+(playground?.level_name)!
            cell.textLabel?.font = UIFont(name: "TrebuchetMS-Italic", size: 18)
            if playground?.finished == true
            {
                cell.detailTextLabel?.text = "Completed!"
            } else {
                cell.detailTextLabel?.text = "Locked!"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isEnabled = enabled(level: self.playgroundIndices[indexPath.row])
        if isEnabled == true {
            self.selectedItem = indexPath as NSIndexPath
            if let s = selectionFinishedClosure {
                s((self.playgroundIndices[selectedItem.row]))
            }
            self.dismiss(animated: true, completion: {});
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func enabled(level:Int) -> Bool {
        var previousLevelFinished=false
        if level>1 && level<(playgrounds?.count)!
        {
            let playground = playgrounds?[self.playgroundIndices[level-1]]
            if playground?.finished==false
            {
                previousLevelFinished = false
            }
        }
        else
        if level == 1 {
                return true
        }
        return previousLevelFinished
    }

}
