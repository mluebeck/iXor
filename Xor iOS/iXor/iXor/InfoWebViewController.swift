//
//  InfoWebViewController.swift
//  iXor
//
//  Created by OSX on 05.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class InfoWebViewController: UIViewController {

    @IBOutlet var view1:  UIView!
    //@IBOutlet var view2:  UIView!
    @IBOutlet var contentHeight : NSLayoutConstraint!
    @IBOutlet var webView : UIWebView!
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
   
    @IBAction func doneButtonPressed() {
        self.navigationController?.dismiss(animated:true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let views = Bundle.main.loadNibNamed("Views", owner: self, options: nil)
        let v = views?[0] as! UIView
        v.frame.size.width = self.view.frame.size.width
        self.view1.addSubview(v)
        contentHeight.constant = v.frame.size.height
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

}
