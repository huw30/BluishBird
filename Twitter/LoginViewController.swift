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

    @IBOutlet weak var getStarted: UIButton!
    @IBAction func onLogin(_ sender: Any) {
        TwitterClient.sharedInstance.login(success: {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }, failure: { (error: Error) in
            Dialog.show(controller: self, title: "Login Error", message: error.localizedDescription, buttonTitle: "Okay", image: nil)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getStarted.layer.cornerRadius = 15
    }
}

