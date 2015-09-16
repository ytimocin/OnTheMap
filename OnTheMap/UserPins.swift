//
//  UserPins.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 07/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

import Foundation

class UserPins {
    
    var users: [OnTheMapUser] = [OnTheMapUser]()
    
    class func sharedInstance() -> UserPins {
        struct Singleton {
            static var sharedInstance = UserPins()
        }
        
        return Singleton.sharedInstance
    }
    
}
