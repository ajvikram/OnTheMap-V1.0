//
//  ListViewController.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

import UIKit

class ListViewController : UITableViewController
{
    var parseClient:ParseClient!
    var udClient:UdacityClient!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let refresh = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(performRefresh))
        
        let addPin = UIBarButtonItem(image: UIImage(named: "addpin"), style: .plain, target: self, action:
            #selector(postMeView))
        
        navigationItem.rightBarButtonItems = [addPin, refresh]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(performLogout))
        
        
        navigationItem.title = "On The Map"
        self.tableView.flashScrollIndicators()   
        //Get the singleton instances of the API clients.
        parseClient = ParseClient.sharedInstance
        udClient = UdacityClient.sharedInstance
        tableView.delegate = self
    }
    
    @objc func postMeView() {
        let infoPostViewController = storyboard!.instantiateViewController(withIdentifier: "InfoPostVC") as! InfoPostViewController
        present(infoPostViewController, animated: true, completion: nil)
    }
    
    @objc func performRefresh() {
        loadData()
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @objc func performLogout()
    {
        //print(">>>ListViewController.performLogout")
        enableButtons(enable: false)
        udClient.logout { (success, errorMessage) in
            if success == true
            {
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.present(loginVC,animated: true, completion: nil)
            }
            else
            {
                self.enableButtons()
            }
        }
    }
    
    func enableButtons(enable:Bool = true)
    {
        navigationItem.leftBarButtonItem?.isEnabled = enable
        navigationItem.rightBarButtonItems![0].isEnabled = enable
        navigationItem.rightBarButtonItems![1].isEnabled = enable
        tabBarController?.tabBar.items![0].isEnabled = enable
        tabBarController?.tabBar.items![1].isEnabled = enable
    }
    
    func loadData()
    {
        parseClient.getStudentLocations { (success, errorMessage) in
            if success
            {
                DispatchQueue.main.async()
                {
                    self.tableView.reloadData()
                }
            }
            else
            {
                //Display error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(dismissAction)
                DispatchQueue.main.async()
                {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let student = StudentInformation.sharedInstance.studentLocations[indexPath.row]
        
        let app = UIApplication.shared
        if let url = NSURL(string: student.mediaURL!)
        {
            app.open(url as URL, options: [:], completionHandler: nil)
        }
        else
        {
            print("ERROR: Invalid url : " + student.mediaURL!)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return StudentInformation.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell", for: indexPath) as! StudentLocationTableViewCell
        let location = StudentInformation.sharedInstance.studentLocations[indexPath.row]
        cell.configureTableCell(student: location)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInformation.sharedInstance.studentLocations[indexPath.row]
        
        let app = UIApplication.shared
        if let url = NSURL(string: student.mediaURL!)
        {
            app.open(url as URL, options: [:], completionHandler: nil)
        }
        else
        {
            print("ERROR: Invalid url : " + student.mediaURL!)
        }
    }
}
