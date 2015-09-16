//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 05/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

import Foundation
import MapKit

struct OnTheMapUser {
    
    var objectID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: CLLocationDegrees? = nil
    var longitude: CLLocationDegrees? = nil
    var hasPosted: Bool! = false
    
    init() {
        
    }
    
    init(dictionary: [String : AnyObject]) {
        
        if let objectID = dictionary["objectId"] as? String {
            self.objectID = objectID
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        
    }
    
    static func getOnTheMapUser(results: [[String : AnyObject]]) -> [OnTheMapUser] {
        
        var users = [OnTheMapUser]()
        
        for result in results {
            users.append(OnTheMapUser(dictionary: result))
        }
        
        return users
    }
}
