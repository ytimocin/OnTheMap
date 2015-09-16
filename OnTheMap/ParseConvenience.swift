//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 07/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

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

extension ParseClient {
    
    func getCurrentUser(currentUser: OnTheMapUser, completionHandler: (result: OnTheMapUser?, error: NSError?) -> Void) {
        
        /* Parameters */
        let methodParameters = [
            ParameterKeys.Where: "{\"uniqueKey\":\"\(currentUser.uniqueKey!)\"}"
        ]
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + UdacityClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            
            if error != nil {
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(result: nil, error: errorObject)
            }
            else {
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let results = parsedJSON.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    if results.count > 0 {
                        var currentUser = OnTheMapUser(dictionary: results[0])
                        completionHandler(result: currentUser, error: nil)
                    }
                    else {
                        
                        let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "Student does not exist"]
                        
                        var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                        
                        completionHandler(result: nil, error: errorObject)
                        
                    }
                } else {
                    
                    let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "Could not parse Student information"]
                    
                    var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(result: nil, error: errorObject)
                    
                }
            }
            
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getUsers(skip: Int = 0, completionHandler: (result: [OnTheMapUser]?, error: NSError?) -> Void) {
        
        /* Parameters */
        let methodParameters = [
            ParameterKeys.Limit: "100",
            ParameterKeys.Skip: "\(skip)",
            ParameterKeys.Order: "-updatedAt"
        ]
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + UdacityClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(result: nil, error: errorObject)
                
            }
            else {
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let results = parsedJSON.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    var students = OnTheMapUser.getOnTheMapUser(results)
                    completionHandler(result: students, error: nil)
                } else {
                    let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "No students exist"]
                    
                    var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(result: nil, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
    func updateUserData(user: OnTheMapUser, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* Build the URL */
        var objectID = user.objectID!
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectID)"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] =
        [
            JSONBodyKeys.UniqueKey: user.uniqueKey!,
            JSONBodyKeys.FirstName: user.firstName!,
            JSONBodyKeys.LastName: user.lastName!,
            JSONBodyKeys.MapString: user.mapString!,
            JSONBodyKeys.MediaURL: user.mediaURL!,
            JSONBodyKeys.Latitude: user.latitude!,
            JSONBodyKeys.Longitude: user.longitude!
        ]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, error: errorObject)
            }
            else {
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let createdAt = parsedJSON.valueForKey(JSONResponseKeys.UpdatedAt) as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    
                    let userInfo: NSDictionary = [NSLocalizedDescriptionKey: "StudentLocation not updated"]
                    
                    var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
    func saveUserData(user: OnTheMapUser, completionHandler: (success: Bool, objectID: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] =
        [
            JSONBodyKeys.UniqueKey: user.uniqueKey!,
            JSONBodyKeys.FirstName: user.firstName!,
            JSONBodyKeys.LastName: user.lastName!,
            JSONBodyKeys.MapString: user.mapString!,
            JSONBodyKeys.MediaURL: user.mediaURL!,
            JSONBodyKeys.Latitude: user.latitude!,
            JSONBodyKeys.Longitude: user.longitude!
        ]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                let userInfo: NSDictionary = [NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Network.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, objectID: nil, error: errorObject)
                
            }
            else {
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let objectID = parsedJSON.valueForKey(JSONResponseKeys.ObjectID) as? String {
                    completionHandler(success: true, objectID: objectID, error: nil)
                } else {
                    
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "StudentLocation not created"]
                    
                    var errorObject = NSError(domain: Error.ParseDomainError, code: ErrorTypes.Server.rawValue, userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, objectID: nil, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
}

