//
//  StudentInformation.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

struct StudentInformation
{
    static var studentLocations : [StudentInformation] = []
    static let sharedInstance = StudentInformation.self
    
    var objectId : String?
    var uniqueId : String?
    var firstName : String?
    var lastName : String?
    var mapString : String?
    var mediaURL : String?
    var longitude : Double?
    var latitude : Double?
    var fullname : String {return "\(firstName!) \(lastName!)"}
    
    init(parseResult: [String:AnyObject])
    {
        objectId = parseResult["objectId"] as? String
        uniqueId = parseResult["uniqueKey"] as? String
        firstName = parseResult["firstName"] as? String
        lastName = parseResult["lastName"] as? String
        mapString = parseResult["mapString"] as? String
        mediaURL = parseResult["mediaURL"] as? String
        longitude = parseResult["longitude"] as? Double
        latitude = parseResult["latitude"] as? Double
    }
    
    static func getLocationsFromResults(results: [[String:AnyObject]]) -> [StudentInformation]
    {
        var returnLocations = [StudentInformation]()
        for result in results
        {
            if !StudentInformation.studentHasNilValues(studentInfo: StudentInformation(parseResult: result))
            {
                returnLocations.append(StudentInformation(parseResult: result))
            }
        }
        return returnLocations
    }

    static func studentHasNilValues(studentInfo:StudentInformation) -> Bool
    {
        var hasNil:Bool = false
        if  studentInfo.latitude == nil ||
            studentInfo.longitude == nil ||
            studentInfo.objectId == nil ||
            studentInfo.firstName == nil ||
            studentInfo.lastName == nil
        {
            hasNil = true
        }
        return hasNil
    }
    
    
}

