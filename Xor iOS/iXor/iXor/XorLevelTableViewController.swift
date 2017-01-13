//
//  LevelTableViewController.swift
//  iXor
//
//  Created by Mario Rotz on 11.01.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class XorLevelTableViewController: UITableViewController {

    var playgrounds : Array<Playground>?
    var selectionFinishedClosure : ((Int) -> ())?
    var selectedItem : NSIndexPath = NSIndexPath(row: -1, section: 0)
    
    @IBAction func backButtonPressed()
    {
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

        let playground = playgrounds?[indexPath.row]
        print("adding playground \(playground?.level_name) to Cell")
        cell.textLabel?.text = "Level \(indexPath.row) - "+(playground?.level_name)!
        if playground?.successfulFinished == true {
            cell.detailTextLabel?.text = "Completed!"
        } else {
            cell.detailTextLabel?.text = "Unfinished!"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isEnabled = enabled(level: indexPath.row)
        if isEnabled == true {
            self.selectedItem = indexPath as NSIndexPath
            if let s = selectionFinishedClosure {
                s((self.selectedItem.row))
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
        var previousLevelFinished=true
        if level>1 && level<(playgrounds?.count)! {
            let playground = playgrounds?[level-1]
            if playground?.successfulFinished==false {
                previousLevelFinished = false
            }
        }
        return previousLevelFinished
    }

}