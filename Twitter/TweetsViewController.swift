//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/27/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
