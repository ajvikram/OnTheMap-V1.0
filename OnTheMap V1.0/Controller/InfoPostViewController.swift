//
//  InfoPostViewController.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class InfoPostViewController:UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var mapURLText: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var parseClient : ParseClient!
    var udClient : UdacityClient!
    
    var placemark: CLPlacemark? = nil
    var studentObjectId:String? = nil
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Get the singleton instances of the API clients.
        parseClient = ParseClient.sharedInstance
        udClient = UdacityClient.sharedInstance
        
        initializeScreen()
        
        locationText.delegate = self
        mapURLText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func findAction(sender: AnyObject)
    {
        if (locationText.text == nil || locationText.text == "")
        {
            displayAlert(message: "Please enter a location.")
            return
        }
        else
        {
            startActivity()
            let LOC_NOT_FOUND = "Could not find location entered. Please retry."
            // put in a delay.
            let delayInSeconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                
                let geocoder = CLGeocoder()
                do
                {
                    geocoder.geocodeAddressString(self.locationText.text!, completionHandler: { (results, error) in
                        if error != nil
                        {
                            
                            self.displayAlert(message: LOC_NOT_FOUND)
                        }
                        else if (results!.isEmpty)
                        {
                            self.displayAlert(message: LOC_NOT_FOUND)
                        }
                        else
                        {
                            self.placemark = results![0]
                            self.initializeScreen(stageNumber: 2)
                            self.startActivity(started: false)
                            self.mapView.showAnnotations([MKPlacemark(placemark: self.placemark!)], animated: true)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func submitAction(sender: AnyObject)
    {
        startActivity()
        if (mapURLText.text == nil || mapURLText.text == "")
        {
            displayAlert(message: "Please enter URL.")
            startActivity(started: false)
            return
        }
        else
        {
            if let objectId = udClient.userObjectId
            {
                let updatedStud:[String:AnyObject] = [  "firstName" : self.udClient.userFirstName as AnyObject,
                                                        "lastName" : self.udClient.userLastName as AnyObject,
                                                        "uniqueKey" : self.udClient.userObjectId! as AnyObject,
                                                        "mediaURL" : self.mapURLText!.text! as AnyObject,
                                                        "mapString" : self.locationText!.text! as AnyObject,
                                                        "longitude" : (self.placemark!.location?.coordinate.longitude)! as AnyObject,
                                                        "latitude" : (self.placemark!.location?.coordinate.latitude)! as AnyObject]
                
                
                parseClient.findStudentLocation(uniqueKey: objectId, completionHandler: { (success, errorMessage) in
                    if (success && StudentInformation.sharedInstance.studentLocations.count > 0)
                    {
                        if let objectId = StudentInformation.sharedInstance.studentLocations[0].objectId
                        {
                            self.parseClient.updateStudentLocation(objectId: objectId, studentData: updatedStud, completionHandler: { (success, errorMessage) in
                                if (success)
                                {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                else
                                {
                                    self.displayAlert(message: "Error occurred when posting information." )
                                }
                            })
                        }
                    }
                    else
                    {
                        print ("Not able to find any parse record for the student, so posting one.")
                        self.parseClient.postStudentLocation(objectId: self.udClient.userObjectId!, studentData: updatedStud, completionHandler: { (success, errorMessage) in
                            if (success)
                            {
                                self.dismiss(animated: true, completion: nil)
                            }
                            else
                            {
                                print ("Error Occurred when posting information : " + errorMessage!)
                                self.displayAlert(message: "Error occurred when posting information. Please check your internet connection too." )
                            }
                        })
                        
                    }
                })
            }
            startActivity(started: false)
        }
    }
    
    func startActivity(started:Bool = true)
    {
        activityIndicator.isHidden = !started
        findButton.isEnabled = !started
        cancelButton.isEnabled = !started
        submitButton.isEnabled = !started
        if (started)
        {
            activityIndicator.startAnimating()
        }
        else
        {
            activityIndicator.stopAnimating()
        }
    }
    
    func displayAlert(message: String, completionHandler: ((UIAlertAction) -> Void)? = nil)
    {
        DispatchQueue.main.async()
            {
                self.startActivity(started: false)
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: completionHandler)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    func initializeScreen(stageNumber :Int = 1)
    {
        activityIndicator.isHidden = true
        switch (stageNumber)
        {
        case 1 :
            submitButton.isHidden = true
            findButton.isHidden = false
            locationText.isHidden = false
            middleView.isHidden = false
            mapURLText.isHidden = true
            topLabel.text = "Add your website link"
        case 2 :
            submitButton.isHidden = false
            findButton.isHidden = true
            locationText.isHidden = true
            middleView.isHidden = true
            mapURLText.isHidden = false
            topLabel.text = "Enter a URL for your location."
        default: break
        }
    }
   
}
