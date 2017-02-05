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
    @IBOutlet var view2:  UIView!
    
    @IBOutlet var webView : UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let views = Bundle.main.loadNibNamed("Views", owner: self, options: nil)
        print(views)
        
        
        //webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "html/intro", ofType: "htm")!)))


        // Do any additional setup after loading the view.
        //self.view1.addSubview(views?[0] as! UIView)
        //self.view2.addSubview(views?[1] as! UIView)
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
