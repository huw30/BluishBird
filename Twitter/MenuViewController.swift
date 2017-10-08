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
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagline: UILabel!

    var hamburgerViewController: HamburgerViewController! {
        didSet {
            hamburgerViewController.contentViewController = tweetsNavController
        }
    }

    private var profileNavController: UIViewController!
    private var tweetsNavController: UIViewController!
    private var mentionsNavController: UIViewController!
    private var viewControllers: [UIViewController] = []
    private var menuItems: [[String: String]]!

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

        menuItems = MenuItems.retrieve()
        headView.addBottomBorderWithColor(color: Colors.hexStringToUIColor(hex: "b3b5b7"), width: 0.5)

        setHeaderView()
    }
    func setHeaderView() {
        if let user = User.currentUser {
            avatarImageView.setImageWith(user.profileURL!)
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.clipsToBounds = true
            nameLabel.text = user.name
            tagline.text = user.tagline
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems[indexPath.row]
        if menuItem["title"] == "Logout" {
            TwitterClient.sharedInstance.logout()
        } else {
            hamburgerViewController.contentViewController = viewControllers[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuCell else {
            return MenuCell()
        }

        let menuItem = menuItems[indexPath.row] 
        cell.menuTitleLabel.text = menuItem["title"]
        cell.menuImageView.image = UIImage(named: menuItem["image"]!)

        return cell
    }
}
