//
//  TwitterClient.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "mqEMesZf1MCVOJlLoUzBHvOkF", consumerSecret: "SJvqOxFTQ3KzQLs3jGKZOBdtcSCp3uaRnL6bUkQZVlI4381joP")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?

    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "bluishbird://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")
            UIApplication.shared.open(authURL!)
            
        }, failure: { (error: Error!) in
            self.loginFailure?(error)
        })
    }

    func logout() {
        User.currentUser = nil
        deauthorize()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogOut"), object: nil)
    }

    func handleLoginSuccess(with url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "GET", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) -> Void in
            self.getCurrentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        }, failure: { (error: Error!) ->Void in
            self.loginFailure?(error)
        })
    }

    func getCurrentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary = response as! [String: Any]
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
}
