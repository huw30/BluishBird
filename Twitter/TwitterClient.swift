//
//  TwitterClient.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterbaseURL = URL(string: "https://api.twitter.com")
let twitterConsumerKey: String = "mqEMesZf1MCVOJlLoUzBHvOkF"
let twitterConsumerSecret: String = "SJvqOxFTQ3KzQLs3jGKZOBdtcSCp3uaRnL6bUkQZVlI4381joP"

class TwitterClient: BDBOAuth1SessionManager {
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterbaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }

    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?

    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()

        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "bluishbird://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            let authURL = URL(string: "\(twitterbaseURL!)/oauth/authorize?oauth_token=\(requestToken.token!)")
            UIApplication.shared.open(authURL!)
            
        }, failure: { (error: Error!) in
            self.loginFailure?(error)
        })
    }

    func handleLoginSuccess(with url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)

        fetchAccessToken(withPath: "oauth/access_token", method: "GET", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print(accessToken.token)
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

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

    func homeTimeline(maxId: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var parameters: [String: Any]?
        if let maxId = maxId {
            parameters = ["max_id": maxId]
        }

        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweetsDictionary = response as! [[String: Any]]
            let tweets = Tweet.tweets(with: tweetsDictionary)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func showTweet(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/show.json", parameters: ["id": id], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweetDictionary = response as! [String: Any]
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    func composeNew(content: String, replyTo: String?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var params = ["status": content]
        if let replyTo = replyTo {
            params["in_reply_to_status_id"] = replyTo
        }

        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweetDictionary = response as! [String: Any]
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }

    func favorite(id: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        post("1.1/favorites/create.json", parameters: ["id": id], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }) { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        }
    }
    func unFavorite(id: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        post("1.1/favorites/destroy.json", parameters: ["id": id], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }) { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        }
    }
    
    func retweet(id: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }) { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        }
    }
    func unRetweet(id: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }) { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        }
    }

    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogOut"), object: nil)
    }
}
