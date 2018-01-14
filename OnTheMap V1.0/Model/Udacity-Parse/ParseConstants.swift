//
//  ParseConstants.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

extension ParseClient
{
    struct BaseURL
    {
        static let APIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let APIID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let API : String = "https://parse.udacity.com/parse/classes"
    }

    struct Methods
    {
        static let studentLocation = "/StudentLocation"
    }
    
    struct HeaderKeys
    {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        static let ApplicationId = "X-Parse-Application-Id"
        static let RestAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct HeaderValues
    {
        static let JSON = "application/json"
    }
    
    
    struct JSONResponseKey
    {
        static let results = "results"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct Errors
    {
        static let connectionError = "Connection error."
        static let UnexpectedSystemError = "Unexpected system error has occurred."
    }
    
}

