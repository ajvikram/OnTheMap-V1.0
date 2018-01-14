//
//  ParseClient.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

class ParseClient
{
    static let sharedInstance = ParseClient()

    func setHeaders(request: NSMutableURLRequest, setJson:Bool) -> NSMutableURLRequest
    {
        if (setJson)
        {
            request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.Accept)
            request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.ContentType)
        }
        request.addValue(BaseURL.APIID, forHTTPHeaderField: HeaderKeys.ApplicationId)
        request.addValue(BaseURL.APIKey, forHTTPHeaderField: HeaderKeys.RestAPIKey)
        return request
    }
    
    func getMethodURL(resourceName: String) -> NSURL
    {
        return NSURL(string: BaseURL.API + resourceName)!;
    }
    
    func getMethodURL (resourceName: String, id:String) -> NSURL
    {
        return NSURL(string: BaseURL.API + resourceName + "?where=%7B%22uniqueKey%22%3A%22" + id + "%22%7D")!;
    }
    
    func getMethodURLToPutInfo (resourceName: String, id:String) -> NSURL
    {
        return NSURL(string: BaseURL.API + resourceName + "/" + id)!;
    }
    
    func getMethodURLToPostInfo (resourceName: String) -> NSURL
    {
        return NSURL(string: BaseURL.API + resourceName)!;
    }
    
    func getMethodURLForOrderedLocations (resourceName : String) -> NSURL
    {
        return NSURL(string: BaseURL.API + resourceName + "?limit=100&order=-updatedAt" )!;
    }
    
    func makeTaskCall (request:URLRequest , completionHandlerForTaskCall : @escaping (_ result : AnyObject? , _ error: NSError?) -> Void)
    {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error == nil
            {
                //Success
                Converter.parseJSONToAnyObject(response: data! as NSData, completionHandler: completionHandlerForTaskCall)
            }
            else
            {
                //Failure
                completionHandlerForTaskCall(nil, error! as NSError)
            }
        }
        task.resume()
    }
    
    func getStudentLocations (completionHandlerForStudentLocations: @escaping (_ success: Bool,_ errorMessage : String?)->Void)
    {
        var request = URLRequest(url:getMethodURLForOrderedLocations(resourceName: Methods.studentLocation) as URL)
        request = setHeaders(request: request as! NSMutableURLRequest, setJson: false) as URLRequest
        makeTaskCall(request: request as URLRequest) { (result, error) in
            if error == nil
            {
                //Success
                if let results = result?.value(forKey: JSONResponseKey.results) as? [[String:AnyObject]]
                {
                    StudentInformation.sharedInstance.studentLocations = StudentInformation.getLocationsFromResults(results: results)
                    completionHandlerForStudentLocations(true,nil)
                }
                else
                {
                    //Failure
                    completionHandlerForStudentLocations(false, Errors.UnexpectedSystemError)
                }
            }
            else
            {
                //Failure
                completionHandlerForStudentLocations(false, Errors.connectionError)
            }
        }
    }
    
    func findStudentLocation (uniqueKey : String, completionHandler: @escaping (_ success:Bool, _ errorMessage: String?) -> Void)
    {
        //Initialize the Request to invoke API.
        var request = URLRequest(url:getMethodURL(resourceName: Methods.studentLocation,id: uniqueKey) as URL)

        request = setHeaders(request: request as! NSMutableURLRequest, setJson: true) as URLRequest
        makeTaskCall(request: request) { (result, error) in
            if error == nil
            {
                //Success
                if let results = result?.value(forKey: JSONResponseKey.results) as? [[String:AnyObject]]
                {
                    StudentInformation.sharedInstance.studentLocations = StudentInformation.getLocationsFromResults(results: results)
                    completionHandler(true,nil)
                }
                else
                {
                    //Failure
                    completionHandler(false, Errors.UnexpectedSystemError)
                }
            }
            else
            {
                //Failure
                completionHandler(false, Errors.connectionError)
            }
        }
    }
    
    func postStudentLocation (objectId: String, studentData: [String:AnyObject], completionHandler:@escaping (_ success: Bool, _ errorMessage  : String?) -> Void)
    {
        //Initialize the Request to invoke API.
        var request = URLRequest(url:getMethodURLToPostInfo(resourceName: Methods.studentLocation) as URL)
        request = setHeaders(request: request as! NSMutableURLRequest, setJson: true) as URLRequest
        request.httpMethod = "POST"
        request.httpBody = Converter.toNSData(requestBody: studentData) as Data
        makeTaskCall(request: request as URLRequest) { (result, error) in
            if error == nil
            {
                //Success
                completionHandler(true, nil)
            }
            else
            {
                //Failure
                completionHandler(false, Errors.UnexpectedSystemError)
            }
        }
    }
    
    func updateStudentLocation (objectId: String, studentData : [String:AnyObject], completionHandler:@escaping (_ success: Bool, _ errorMessage: String?) -> Void)
    {
        //Initialize the Request to invoke API.
        var request = URLRequest(url:getMethodURLToPutInfo(resourceName: Methods.studentLocation, id: objectId) as URL)
        request = setHeaders(request: request as! NSMutableURLRequest, setJson: true) as URLRequest
        request.httpMethod = "PUT"
        request.httpBody = Converter.toNSData(requestBody: studentData) as Data
        makeTaskCall(request: request as URLRequest) { (result, error) in
            if error == nil
            {
                //Success
                completionHandler(true, nil)
            }
            else
            {
                //Failure
                completionHandler(false, Errors.UnexpectedSystemError)
            }
        }
    }
}

