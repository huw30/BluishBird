//
//  DialogBox.swift
//  Twitter
//
//  Created by Raina Wang on 10/1/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//
import Foundation
import UIKit
import PopupDialog

struct Dialog {
    static func show(controller: UIViewController, title: String, message: String, buttonTitle: String?, image: UIImage?, dismissAfter: Int?, completion: (() -> Void)?) {
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image, gestureDismissal: true)

        // Create buttons
        if let buttonTitle = buttonTitle {
            let buttonOne = CancelButton(title: buttonTitle) {
                print("You canceled the dialog.")
            }
            popup.addButtons([buttonOne])
        }
        // Present dialog
        controller.present(popup, animated: true, completion: completion)

        if let dismissAfter = dismissAfter {
            let when = DispatchTime.now() + .seconds(dismissAfter)
            DispatchQueue.main.asyncAfter(deadline: when) {
                popup.dismiss(animated: true, completion: nil)
            }
        }
    }
}
