//
//  User.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileURL: URL?
    var tagline: String?
    
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String
        screenname = dictionary["screenname"] as? String
        let profileURLString = dictionary["profile_image_url_https"] as? String
        if let profileURLString = profileURLString {
            profileURL = URL(string: profileURLString)
        }
        tagline = dictionary["description"] as? String
    }
}
