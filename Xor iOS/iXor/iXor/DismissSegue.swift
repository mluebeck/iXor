//
//  DismissSegue.swift
//  iXor
//
//  Created by OSX on 04.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
   
    override func perform()
    {
        let sourceViewController = self.source
        sourceViewController.presentingViewController?.dismiss(animated:true, completion:nil)
    }

}
