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
    var friendsCount: Int = 0
    var followersCount: Int = 0
    var statusesCount: Int = 0
    var location: String?
    var profileBackgroundColor: String?
    var profileBackgroundURL: URL?

    var dictionary: [String: Any]?
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        friendsCount = (dictionary["friends_count"] as? Int) ?? 0
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        statusesCount = (dictionary["statuses_count"] as? Int) ?? 0
        location = dictionary["location"] as? String
        profileBackgroundColor = dictionary["profile_background_color"] as? String

        let profileURLString = dictionary["profile_image_url_https"] as? String
        if let profileURLString = profileURLString {
            profileURL = URL(string: profileURLString)
        }

        let profileBackgroundURLString = dictionary["profile_background_image_url_https"] as? String
        if let profileBackgroundURLString = profileBackgroundURLString {
            profileBackgroundURL = URL(string: profileBackgroundURLString)
        }
    }

    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "twitterCurrentUserData") as? Data
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as? [String : Any]
                    _currentUser = User(dictionary: dictionary!)
                }
                
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard

            if let user = user {
                let userData = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(userData, forKey: "twitterCurrentUserData")
            } else {
                defaults.removeObject(forKey: "twitterCurrentUserData")
            }

            defaults.synchronize()
        }
    }
}
