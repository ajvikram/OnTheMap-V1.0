//
//  UdacityClient.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/11/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

class UdacityClient
{
    var userObjectId: String?
    var userFirstName: String = ""
    var userLastName: String = ""
    
    var session = URLSession.shared
    
    static let sharedInstance = UdacityClient()
    
    func setHeaders(request: NSMutableURLRequest) -> NSMutableURLRequest
    {
        request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.Accept)
        request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.ContentType)
        return request
    }
    
    func getMethodURL (resourceName: String) -> URL
    {
        return URL(string: BaseURL.API + resourceName)!;
    }
    
    func makeTaskCall (request:URLRequest , completionHandlerForTaskCall : @escaping (_ result : AnyObject? , _ error: NSError?) -> Void)
    {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil
            {
                //Success
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                Converter.parseJSONToAnyObject(response: newData! as NSData, completionHandler: completionHandlerForTaskCall)
            }
            else
            {
                //Failure
                completionHandlerForTaskCall(nil, error! as NSError)
            }
        }
        task.resume()
    }

    func loginWithCredentials (userName: String, password : String , completionHandlerForLogin : @escaping (_ success:Bool,  _ errorMessage:String? ) ->Void )
    {
        
        //Initialize the Request to invoke API.
        var request = URLRequest(url:getMethodURL(resourceName: Methods.Session) as URL)
   
        request.httpMethod = "POST"
        request = setHeaders(request: request as! NSMutableURLRequest) as URLRequest
        
        //Convert the apiRequest to NSData and assign it to request HTTP Body.
        
        let userDict = NSMutableDictionary()
        userDict.setValue(userName, forKey: JSONBodyKeys.username)
        userDict.setValue(password, forKey: JSONBodyKeys.password)
        let udacityDict = NSMutableDictionary()
        udacityDict.setValue(userDict, forKey: JSONBodyKeys.udacity)
        //creating data for httpBody
        let userData = Converter.toNSData(requestBody: udacityDict as? [String : AnyObject])
        
        request.httpBody = userData as Data
        
        makeTaskCall(request: request, completionHandlerForTaskCall: { (result, error) in

            if error == nil
            {
                //Success
                // Step 1. Get the Account Node.
               
                if let account = result?.value(forKey: JSONResponseKey.account) as? NSDictionary
                {
                    //Step 2. Parse out the Key Node (aka user-ID)
                    if let userId = account.value(forKey: JSONResponseKey.key) as? String
                    {
                        self.userObjectId = userId
                        
                        // Get User Info based on the user ID above.
                        self.getStudentInfo(userId: userId, completionHandlerForStudentInfo: { (success, errorMessage) in
                            if (success)
                            {
                                //print ("\n User Full Name =  \(self.userFirstName) \(self.userLastName)")
                                completionHandlerForLogin(true, nil)
                            }
                            else
                            {
                                //print("\n")
                                completionHandlerForLogin(false, Errors.connectionError)
                            }
                        })
                    }
                    else
                    {
                        //Failure when not able to get the user id in the response.
                        completionHandlerForLogin(false,Errors.loginError)
                    }
                }
                else
                {
                    //Failure when not able to get a key in the response.
                    completionHandlerForLogin(false,Errors.loginError)
                }
            }
            else
            {
                //Failure because not able to connect to the API
                completionHandlerForLogin(false,Errors.connectionError)
            }
        })
    }
    

    func logout (completionHandler : @escaping (_ success:Bool,  _ errorMessage:String? ) ->Void )
    {

        let request = NSMutableURLRequest(url:getMethodURL(resourceName: Methods.Session) as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie:HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!
        {
            if cookie.name == "XSRF-TOKEN"
            {
                xsrfCookie = cookie
            }
            if let xsrfCookie = xsrfCookie
            {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        }
        makeTaskCall(request: request as URLRequest) { (result, error) in
            if error == nil
            {
                //Success
                completionHandler(true, nil)
            }
            else
            {
                completionHandler(false,Errors.connectionError)
            }
        }
    }
    

    func getStudentInfo (userId : String, completionHandlerForStudentInfo : @escaping (_ success:Bool,  _ errorMessage:String? ) ->Void)
    {
        //Initialize the Request to invoke API.
        var request = NSMutableURLRequest(url:getMethodURL(resourceName: Methods.Users+"/"+userId) as URL)
        request.httpMethod = "GET"
        request = setHeaders(request: request)
        
        makeTaskCall(request: request as URLRequest) { (result, error) in

            if error == nil
            {
                //Success
                //Step 1. Get the user node.
                if let user = result?.value(forKey: JSONResponseKey.user) as? NSDictionary
                {
                    //Step 2. Parse out the first name of the user object.
                    if let fName = user.value(forKey: JSONResponseKey.firstName) as? String
                    {
                        self.userFirstName = fName
                    }
                    //Step 3. Parse out the last name of the user object.
                    if let lName = user.value(forKey: JSONResponseKey.lastName) as? String
                    {
                        self.userLastName = lName
                    }
                    //print("Student Name : \(userFirstName) \(userLastName)")
                    completionHandlerForStudentInfo(true, nil)
                }
            }
            else
            {
                completionHandlerForStudentInfo(false,Errors.connectionError)
            }
        }
    }
}

