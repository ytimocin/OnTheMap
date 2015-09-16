//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 06/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

extension ParseClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ParseURLSecure : String = "https://api.parse.com/1/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // Parse
        static let GetStudentLocations = "classes/StudentLocation"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        
    }
    
    struct Error {
        
        static let ParseDomainError = "ParseDomainError"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let StatusMessage = "status_message"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Account = "account"
        static let Key = "key"
        static let Status = "status"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        
    }
}
