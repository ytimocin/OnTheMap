//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 04/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "53458e624397a1be92da00f2ecdd0de9"
        
        // MARK: URLs
        static let BaseURL : String = "http://api.themoviedb.org/3/"
        static let BaseURLSecure : String = "https://api.themoviedb.org/3/"
        static let AuthorizationURL : String = "https://www.themoviedb.org/authenticate/"
        
        static let UdacityURLSecure : String = "https://www.udacity.com/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // Udacity
        static let UdacitySession = "api/session"
        static let UdacityUser = "api/users/{uniqueKey}"
        
        // MARK: Account
        static let Account = "account"
        static let AccountIDFavoriteMovies = "account/{id}/favorite/movies"
        static let AccountIDFavorite = "account/{id}/favorite"
        static let AccountIDWatchlistMovies = "account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "search/movie"
        
        // MARK: Config
        static let Config = "configuration"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        static let UniqueKey = "uniqueKey"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
        static let Dummy = "dummy"
        
    }
    
    struct Error {
        
        static let UdacityDomainError = "UdacityDomainError"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let FacebookMobile = "facebook_mobile"
        
        static let AccessToken = "access_token"
        
        static let Udacity = "udacity"
        static let UdacityUsername = "username"
        static let UdacityPassword = "password"
        static let UdacityUserUniqueKey = "uniqueKey"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let UdacityStatus = "status"
        
        static let UdacityUser = "user"
        static let UdacityUserFirstName = "first_name"
        static let UdacityUserLastName = "last_name"
        
        static let UdacityAccount = "account"
        static let UdacityAccountRegistered = "registered"
        static let UdacityAccountKey = "key"
        
        static let UdacitySession = "session"
        static let UdacitySessionID = "id"
        static let UdacitySessionExpiration = "expiration"
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let Account = "account"
        static let Key = "key"
        static let Status = "status"
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
    }
}