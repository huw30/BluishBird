//
//  MenuViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/6/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var hamburgerViewController: HamburgerViewController! {
        didSet {
            hamburgerViewController.contentViewController = tweetsNavController
        }
    }

    private var profileNavController: UIViewController!
    private var tweetsNavController: UIViewController!
    private var mentionsNavController: UIViewController!
    private var viewControllers: [UIViewController] = []
    private var menuTitles = ["profile", "timeline", "mentions"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController")
        tweetsNavController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        mentionsNavController = storyboard.instantiateViewController(withIdentifier: "MentionsNavController")
        viewControllers.append(profileNavController)
        viewControllers.append(tweetsNavController)
        viewControllers.append(mentionsNavController)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuCell else {
            return MenuCell()
        }
        cell.menuTitleLabel.text = menuTitles[indexPath.row]
        return cell
    }
}
