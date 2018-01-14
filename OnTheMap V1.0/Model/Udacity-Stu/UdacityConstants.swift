//
//  UdacityConstants.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/11/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

extension UdacityClient
{

    struct BaseURL
    {
        static var Host:String = "https://www.udacity.com"
        static let API:String = Host + "/api"
    }
    
    struct Methods
    {
        static let Session:String = "/session"
        static let Users:String = "/users"
    }
    
    struct HeaderKeys
    {
        static let Accept:String = "Accept"
        static let ContentType:String = "Content-Type"
    }
    
    struct HeaderValues
    {
        static let JSON:String = "application/json"
    }
    
    struct JSONBodyKeys
    {
        static let udacity:String = "udacity"
        static let username:String = "username"
        static let password:String = "password"
    }

    struct JSONResponseKey
    {
        static let account:String = "account"
        static let registered:String = "registered"
        static let key:String = "key"
        static let session:String = "session"
        static let id:String = "id"
        static let expiration:String = "expiration"
        
        static let user:String = "user"
        static let lastName:String = "last_name"
        static let firstName:String = "first_name"
        
        static let status:String = "status"
        static let error:String = "error"
        
    }

    struct Errors
    {
        static let loginError:String = "Udacity login has failed."
        static let connectionError:String = "Connection error."
    }
}

