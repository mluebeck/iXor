//
//  InfoViewController.swift
//  iXor
//
//  Created by OSX on 04.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    var hintNr = 1
    @IBOutlet var imageView : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let secs = 4.0 as Double
        self.showHints(secs:secs)
        self.title = "Controller Übersicht (1/7)"
    }
    @IBAction func nextHint()
    {
        hintNr += 1
        self.title = "Controller Übersicht (\(hintNr)/7)"

        switch hintNr {
        case 1:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_4.png")
            break
        case 4:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_7.png")
            break
        case 2:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_6.png")
            break
        case 3:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_1.png")
            break
        case 5:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_2.png")
            break
        case 6:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_3.png")
            break
        case 7:
            self.imageView.image = UIImage.init(named: "Xanadoo Anleitung_5.png")
            hintNr = 0
            break
        default:
            break
            

        }
    }
    
    func showHints(secs:Double)
    {
        return
            /*
        AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
            self.nextHint()
            self.showHints(secs: secs)
        }*/

    }
    
    @IBAction func doneButtonPressed()
    {
        self.dismiss(animated: false)
    }

}
