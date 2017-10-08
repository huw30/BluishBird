//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/6/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!

    private var originalLeftMargin: CGFloat!

    var menuViewController: MenuViewController! {
        didSet {
            removeInactiveVC(inactiveVC: oldValue)
            updateActiveVC(activeVC: menuViewController, parentView: menuView)
        }
    }

    var contentViewController: UIViewController! {
        didSet {
            removeInactiveVC(inactiveVC: oldValue)
            updateActiveVC(activeVC: contentViewController, parentView: contentView)
            // close the menu view and show the content view full screen
            UIView.animate(withDuration: 0.3) {
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.hamburgerViewController = self
    }

    func updateActiveVC(activeVC: UIViewController, parentView: UIView) {
        activeVC.willMove(toParentViewController: self)
        parentView.addSubview(activeVC.view)
        activeVC.didMove(toParentViewController: self)
        activeVC.viewDidLoad()
    }
    func removeInactiveVC(inactiveVC: UIViewController?) {
        inactiveVC?.willMove(toParentViewController: nil)
        inactiveVC?.view.removeFromSuperview()
        inactiveVC?.didMove(toParentViewController: nil)
    }

    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
        } else if sender.state == .changed {
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7,initialSpringVelocity: 0.0, options: [], animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 50
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
