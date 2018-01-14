//
//  Converter.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/11/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

class Converter
{

    static func toNSData(requestBody : [String:AnyObject]? = nil) -> NSData
    {
        var jsonData:NSData! = nil
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: requestBody!, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
        }
        catch let error as NSError
        {
            print(error)
        }
        parseJSONToAnyObject(response: jsonData) { (result, error) in}
        return jsonData
    }

    static func parseJSONToAnyObject(response: NSData, completionHandler: (_ result:AnyObject?, _ error:NSError?)-> Void)
    {
        var parsedResponse:AnyObject! = nil
        do
        {
            parsedResponse = try JSONSerialization.jsonObject(with: response as Data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            completionHandler(parsedResponse, nil)
        }
        catch let error as NSError
        {
            //Failure has occurred, don't return any results.
            completionHandler(nil, error)
        }
    }
}

