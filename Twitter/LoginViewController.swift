//
//  ViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class LoginViewController: UIViewController {

    @IBAction func onLogin(_ sender: Any) {
        TwitterClient.sharedInstance.login(success: {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }, failure: { (error: Error) in
            print(error)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

