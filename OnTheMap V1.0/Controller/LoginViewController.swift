//
//  LoginViewController.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/11/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController
{
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var udClient : UdacityClient!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Get the singleton instances of the API clients.
        udClient = UdacityClient.sharedInstance
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
        udacityLoginButton.setTitleColor(UIColor.white, for: .normal)
        email.text=""
        password.text = ""
    }
    
    @IBAction func loginUdacity(sender: AnyObject)
    {
        //print(">>> loginUdacity ")
        loginStartActivity(started: true)
        udClient.loginWithCredentials(userName: email.text!, password: password.text!) { (success, errorMessage) in
            //print ("In loginWithCredentials completionHandler ")
            if (success)
            {
                DispatchQueue.main.async()
                {
                    self.loginStartActivity(started: false)
                    self.performSegue(withIdentifier: "ToTabController", sender: self)
                }
            }
            else
            {
                if errorMessage == UdacityClient.Errors.loginError
                {
                    self.displayAlert(message: "Login error, please try again.")
                    
                }
                    
                else if errorMessage == UdacityClient.Errors.connectionError
                {
                    //print ("Login Error Message : " + errorMessage!)
                    self.displayAlert(message: "Unable to connect to the internet.")
                    
                }
                
                DispatchQueue.main.async()
                {
                    self.loginStartActivity(started: false)
                }
            }
        }
    }

    func loginStartActivity(started:Bool) -> Void
    {
        udacityLoginButton.isHidden = started
        email.isUserInteractionEnabled = !started
        password.isUserInteractionEnabled = !started
        activityIndicator.isHidden = !started
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
            self.loginStartActivity(started: false)
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: completionHandler)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

