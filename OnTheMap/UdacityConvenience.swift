//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 04/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    func authenticateWithCompletionHandler(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        self.getAccountKey(email, password: password) { (success, uniqueKey, error) in
            
            if success {
                
                if (self.currentUser == nil) { self.currentUser = OnTheMapUser() }
                
                self.currentUser?.uniqueKey = uniqueKey
                
                self.getCurrentUserName() { (success, firstName, lastName, error) in
                    
                    if success {
                        
                        self.currentUser?.firstName = firstName
                        
                        self.currentUser?.lastName = lastName
                        
                        completionHandler(success: success, error: nil)
                        
                    } else {
                        completionHandler(success: success, error: error)
                    }
                    
                }
                
            } else {
                completionHandler(success: success, error: error)
            }
        }
    }
    
    func authenticateWithCompletionHandler(token: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        self.getAccountKey(token) { (success, uniqueKey, error) in
            
            if success {
                
                if (self.currentUser == nil) { self.currentUser = OnTheMapUser() }
                
                self.currentUser?.uniqueKey = uniqueKey
                
                self.getCurrentUserName() { (success, firstName, lastName, error) in
                    
                    if success {
                        
                        self.currentUser?.firstName = firstName
                        
                        self.currentUser?.lastName = lastName
                        
                        completionHandler(success: success, error: nil)
                        
                    } else {
                        completionHandler(success: success, error: error)
                    }
                    
                }
                
            } else {
                completionHandler(success: success, error: error)
            }
        }
        
    }
    
    func getAccountKey(email: String, password: String, completionHandler: (success: Bool, uniqueKey: String?, error: NSError?) -> Void) {
        
        let parameters = Dictionary<String, String>()
        let mutableMethod : String = Methods.UdacitySession
        
        let jsonBody : [String:AnyObject] = [UdacityClient.JSONBodyKeys.Udacity: [UdacityClient.JSONBodyKeys.UdacityUsername: email, UdacityClient.JSONBodyKeys.UdacityPassword: password]]
        
        let task = taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error.localizedDescription]
                
                let errorObject = NSError(domain: UdacityClient.Error.UdacityDomainError, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, uniqueKey: nil, error: errorObject)
            } else {

                if let account = JSONResult.valueForKey(JSONResponseKeys.UdacityAccount) as? NSDictionary {
                    let key = account.valueForKey(JSONResponseKeys.UdacityAccountKey) as? String
                    completionHandler(success: true, uniqueKey: key, error: nil )
                } else {
                    if let status = JSONResult.valueForKey(JSONResponseKeys.UdacityStatus) as? Int {
                        if status == 403 {
                            let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "Invalid Credentials"]
                            
                            let errorObject = NSError(domain: UdacityClient.Error.UdacityDomainError, code: ErrorTypes.Server.rawValue,
                                userInfo: userInfo as [NSObject : AnyObject])
                            
                            completionHandler(success: false, uniqueKey: nil, error: errorObject)
                        }
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getAccountKey(token: String, completionHandler: (success: Bool, uniqueKey: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody : [String:AnyObject] = [JSONBodyKeys.FacebookMobile: [JSONBodyKeys.AccessToken: token]]
        do {
            request.HTTPBody = try (NSJSONSerialization.dataWithJSONObject(jsonBody, options: []))
        } catch {
            request.HTTPBody = nil
            print("exhaustiveness - udacity")
        }
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, respose, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error!.localizedDescription]
                
                let errorObject = NSError(domain: Error.UdacityDomainError, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, uniqueKey: nil, error: errorObject)
                
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                /* Parse the data */
                let parsedJSON = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                if let account = parsedJSON[JSONResponseKeys.Account] as? NSDictionary {
                    let key = account.valueForKey(JSONResponseKeys.Key) as? String
                    completionHandler(success: true, uniqueKey: key, error: nil)
                } else {
                    if let status = parsedJSON[JSONResponseKeys.Status] as? Int {
                        if status == 403 {
                            let userInfo: NSDictionary = [
                                NSLocalizedDescriptionKey: "Invalid Credentials"]
                            
                            let errorObject = NSError(domain: Error.UdacityDomainError, code: ErrorTypes.Server.rawValue,
                                userInfo: userInfo as [NSObject : AnyObject])
                            
                            completionHandler(success: false, uniqueKey: nil, error: errorObject)
                        }
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getCurrentUserName(completionHandler: (success: Bool, firstName: String?, lastName: String?, error: NSError?) -> Void) {
        
        let parameters = Dictionary<String, String>()
        
        var mutableMethod : String = Methods.UdacityUser
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UniqueKey, value: self.currentUser!.uniqueKey!)!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error.localizedDescription]
                
                let errorObject = NSError(domain: UdacityClient.Error.UdacityDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, firstName: nil, lastName: nil, error: errorObject)
                
            } else {
                
                if let user = JSONResult.valueForKey(JSONResponseKeys.UdacityUser) as? NSDictionary {
                    let firstName = user[JSONResponseKeys.UdacityUserFirstName] as? String
                    let lastName = user[JSONResponseKeys.UdacityUserLastName] as? String
                    completionHandler(success: true, firstName: firstName, lastName: lastName, error: nil)
                } else {
                    
                    let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "Account not found"]
                    
                    let errorObject = NSError(domain: Error.UdacityDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, firstName: nil, lastName: nil, error: errorObject)
                    
                }
            }
        }
        
    }
    
    func login(username:String, password: String, completionHandler: (result: Int?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = Dictionary<String, String>()
        let mutableMethod : String = Methods.UdacitySession
        
        /*
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.UdacityPassword: password,
            UdacityClient.JSONBodyKeys.UdacityUsername: username
        ]
        */
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 2. Make the request */
        taskForPOSTMethodJSONString(mutableMethod, parameters: parameters, jsonBody: jsonBody!) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = (JSONResult.valueForKey(UdacityClient.JSONResponseKeys.UdacityAccount))!.valueForKey(UdacityClient.JSONResponseKeys.UdacityAccountRegistered)  as? Int {
                    completionHandler(result: results, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "udacityLogin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse udacityLogin"]))
                }
            }
        }
    }
    
    func logout(completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies as? [NSHTTPCookie]!)! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error!.localizedDescription]
                
                let errorObject = NSError(domain: Error.UdacityDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, error: errorObject)
                
            }
            else {
                
                completionHandler(success: true, error: nil)
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
}
