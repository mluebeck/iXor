//
//  InfoViewController.swift
//  iXor
//
//  Created by OSX on 04.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var imageView : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let secs = 2.0
        AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
            self.imageView.image = UIImage.init(named: "xanadoo_1.png")
            AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                self.imageView.image = UIImage.init(named: "xanadoo_2.png")
                AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                    self.imageView.image = UIImage.init(named: "xanadoo_3.png")
                    AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                        self.imageView.image = UIImage.init(named: "xanadoo_4.png")
                        AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                            self.imageView.image = UIImage.init(named: "xanadoo_5.png")
                            AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                                self.imageView.image = UIImage.init(named: "xanadoo_6.png")
                                AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                                    self.imageView.image = UIImage.init(named: "xanadoo_7.png")
                                    AppDelegate.delay(bySeconds: secs, dispatchLevel: .main) {
                                        self.imageView.image = UIImage.init(named: "xanadoo_8.png")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func doneButtonPressed()
    {
        self.dismiss(animated: false)
    }

}
