//
//  MenuItem.swift
//  Twitter
//
//  Created by Raina Wang on 10/7/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import Foundation

struct MenuItems {
    static func retrieve() -> [[String: String]] {
        return
            [
                ["title" : "Profile", "image": "profile"],
                ["title" : "Timeline", "image": "home"],
                ["title" : "Mentions", "image": "mentions"],
                ["title" : "Logout", "image": "logout"]
            ]
    }
}
