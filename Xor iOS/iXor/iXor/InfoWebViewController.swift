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
    @IBOutlet var scrollView : UIScrollView!
    var v : UIView?
    
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
        v = views?[0] as! UIView?
        v?.frame.size.width = self.view.frame.size.width
        self.view1.addSubview(v!)
        contentHeight.constant = (v?.frame.size.height)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "infowebviewcontrollerscrollingatbeginning") == false
        {
            UIView.animate(withDuration:12.0,delay:0,options:UIViewAnimationOptions.curveLinear,
                           animations:{
                            self.scrollView.contentOffset = CGPoint(x:0, y:(self.v?.frame.size.height)!-self.view.frame.size.height)
            },completion:nil)
            defaults.set(true, forKey: "infowebviewcontrollerscrollingatbeginning")
        }
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
