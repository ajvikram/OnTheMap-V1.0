//
//  MapViewController.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate
{
    
    @IBOutlet weak var mapview: MKMapView!

    
    var parseClient : ParseClient!
    var udClient : UdacityClient!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let refresh = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(performRefresh))
  
        let addPin = UIBarButtonItem(image: UIImage(named: "addpin"), style: .plain, target: self, action:
            #selector(postMeView))
        
        navigationItem.rightBarButtonItems = [addPin, refresh]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(performLogout))
        
        navigationItem.title = "On The Map"
        mapview.delegate = self
        //Get the singleton instances of the API clients.
        parseClient = ParseClient.sharedInstance
        udClient = UdacityClient.sharedInstance
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        loadData()
    }
    
    @objc func postMeView() {
        let infoPostViewController = storyboard!.instantiateViewController(withIdentifier: "InfoPostVC") as! InfoPostViewController
        present(infoPostViewController, animated: true, completion: nil)
    }
    
    @objc func performLogout()
    {
        //print(">>> MapViewController.performLogout")
        enableButtons(enable: false)
        
        udClient.logout { (success, errorMessage) in
            if success
            {
                DispatchQueue.main.async {
                    self.dismiss( animated: true )
                }
            }
            else
            {
                self.enableButtons()
            }
        }
    }
    
    @objc func performRefresh()
    {
        //print(">>> MapViewController.performRefresh")
        loadData()
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
        mapview.removeAnnotations(mapview.annotations)
        parseClient.getStudentLocations() { success, errorMessage in
            
            // We will create an MKPointAnnotation for each dictionary in "locations". The
            // point annotations will be stored in this array, and then provided to the map view.
            var annotations = [MKPointAnnotation]()
            
            if success
            {
                //On Success
                for location in StudentInformation.sharedInstance.studentLocations
                {
                    //Assign the co-ordinates.
                    let lat = CLLocationDegrees(location.latitude!)
                    let long = CLLocationDegrees(location.longitude!)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = "\(location.firstName!) \(location.lastName!)"
                    annotation.subtitle = location.mediaURL
                    annotation.coordinate = coordinate
                    annotations.append(annotation)
                }
            }
            else
            {
                //Failure
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                let dismissAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                alert.addAction(dismissAction)
                
                DispatchQueue.main.async()
                    {
                        self.present(alert, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async()
                {
                    self.mapview.addAnnotations(annotations)
                    self.mapview.alpha = 1.0
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            let app = UIApplication.shared
            let mediaURL = NSURL(string:((view.annotation?.subtitle)!)!)
            if app.canOpenURL(mediaURL! as URL)
            {
                app.open(mediaURL! as URL , options: [:], completionHandler: nil)
            }
        }
    }
    
}

