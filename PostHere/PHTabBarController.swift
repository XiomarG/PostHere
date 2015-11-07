//
//  PHTabBarController.swift
//  PostHere
//
//  Created by XunGong on 2015-08-20.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import CoreLocation

class PHTabBarController: UITabBarController, CLLocationManagerDelegate,
                           PHCreatePostControllerDataSource, PHPostsTableViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Location Manager
    var currentLocation = CLLocation()
    var locationManager = CLLocationManager()
    
    private func initializeLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter  = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last!
//        print("Current location changed to \(self.currentLocation.coordinate)")
        
        
    }
    
    
    // MARK: Data Source
    
    func currentLocationForMapView(controller: PHMapViewController) -> CLLocation {
        return self.currentLocation
    }
    func currentLocationForCreatePost(contoller: PHCreatePostController) -> CLLocation {
        return self.currentLocation
    }
    func currentLocationForPostsTable(contoller: PHPostsTableViewController) -> CLLocation {
        return self.currentLocation
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
