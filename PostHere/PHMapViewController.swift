//
//  PHMapViewController.swift
//  PostHere
//
//  Created by XunGong on 2015-08-16.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import ParseUI

class PHMapViewController: UIViewController, MKMapViewDelegate, PHNewPostCreatedProtocal  {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var mapTypeControl: UISegmentedControl!
    @IBOutlet var showMapTypeButton: UIButton!
    
    //@IBOutlet var tableView: UITableView!
//    @IBOutlet var tableView: UITableView!
    
    //@IBOutlet var mapListSwitch: UISegmentedControl!
//    @IBOutlet var mapListSwitch: UISegmentedControl!
    
    var allPosts : [PHPost]
    
    init() {
        allPosts = [PHPost]()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //var tableView : UITableView!
    
    var dataSource : PHTabBarController!
    

    var mapPannedSinceLocationUpdate = Bool()
    var mapTrackingMode = Bool()
    var circleOverlay : MKCircle?
    var fetchRadius : Double {
        return NSUserDefaults.standardUserDefaults().doubleForKey(PHUserDefaultsFetchRadiusKey)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        initializeMapView()
        initUIItems()

    }
   

    // MARK: Location Manager
    var currentLocation = CLLocation()
    
    

    // MARK: Mapview Delegate
    
    
    func initializeMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapPannedSinceLocationUpdate = false
        mapTrackingMode = true
//        mapView.scrollEnabled = false
        let mapTypeIndex = NSUserDefaults.standardUserDefaults().integerForKey(PHUserDefaultsMapTypeIndex)
        changeMapTypeTo(mapTypeIndex)
        let defaultLatitude = NSUserDefaults.standardUserDefaults().doubleForKey(PHUserDefaultsLatitudeKey)
        let defaultLongitude = NSUserDefaults.standardUserDefaults().doubleForKey(PHUserDefaultsLongitudeKey)
        currentLocation = CLLocation(latitude: defaultLatitude, longitude: defaultLongitude)
        backToCurrentLocation()
    }
    
    func changeMapTypeTo(index : Int) {
        switch index {
        case 0: mapView.mapType = .Standard
        case 1: mapView.mapType = .Satellite
        case 2: mapView.mapType = .Hybrid
        default: break
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        currentLocation = userLocation.location!
        if mapTrackingMode == true {
            mapView.setCenterCoordinate(userLocation.coordinate, animated: false)
        }
        if circleOverlay != nil {
            mapView.removeOverlay(circleOverlay!)
        }
        circleOverlay = MKCircle(centerCoordinate: userLocation.coordinate, radius: self.fetchRadius)
        mapView.addOverlay(circleOverlay!)
        self.queryForPostsNearLocation(self.currentLocation.coordinate, nearByDistance: self.fetchRadius)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRender = MKCircleRenderer(circle: circleOverlay!)
            switch mapView.mapType {
            case .Standard:
                circleRender.fillColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.1)
                circleRender.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
            default:
                circleRender.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.05)
                circleRender.strokeColor = UIColor.greenColor().colorWithAlphaComponent(0.7)
            }
            circleRender.lineWidth = 1.0
            return circleRender
        }
        let overlayRender = MKOverlayRenderer(overlay: overlay)
        return overlayRender
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinIdentifier = "CustomPinIdentifier"
        if annotation is PHPost {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            } else {
                pinView?.annotation = annotation
            }
            pinView?.pinColor = (annotation as! PHPost).pinColor
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            
            return pinView
        }
        return nil
    }
    // MARK: UI Elements Action
    
    func initUIItems() {
        // initialize UI controls
        let moveTrans = CGAffineTransformMakeTranslation(95, 0)
        mapTypeControl.transform = CGAffineTransformScale(moveTrans, 0.1, 1)
        mapTypeControl.hidden = true
        mapTypeControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey(PHUserDefaultsMapTypeIndex)
        

//        self.tableView.transform = CGAffineTransformMakeTranslation(self.tableView.frame.width, 0)

    }
    
    @IBAction func currentButtonTapped(sender: UIButton) {
        let moveTrans = CGAffineTransformMakeTranslation(95, 0)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.mapTypeControl.transform = CGAffineTransformScale(moveTrans, 0.1, 1)
            }) { (succeeded) -> Void in
                self.mapTypeControl.hidden = true
                self.showMapTypeButton.hidden = false
        }
        backToCurrentLocation()
    }
    
    
    func backToCurrentLocation() {
        let newRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, self.fetchRadius * 4.0, self.fetchRadius * 4.0)
        mapView.setRegion(newRegion, animated: true)
    }
    
    @IBAction func showMapType(sender: AnyObject) {

        self.mapTypeControl.hidden = false
        self.showMapTypeButton.hidden = true
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.mapTypeControl.transform = CGAffineTransformMakeTranslation(0, 0)
            })
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.hideMapType()
    }
    
    private func hideMapType() {
        let moveTrans = CGAffineTransformMakeTranslation(95, 0)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.mapTypeControl.transform = CGAffineTransformScale(moveTrans, 0.1, 1)
            }) { (succeeded) -> Void in
                self.mapTypeControl.hidden = true
                self.showMapTypeButton.hidden = false
        }
    }
    
    @IBAction func changeMapType(sender: UISegmentedControl) {
        changeMapTypeTo(sender.selectedSegmentIndex)
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: PHUserDefaultsMapTypeIndex)
    }
    

    
    // MARK: fetch nearby posts
    
    func queryForPostsNearLocation( currenrCoordinate : CLLocationCoordinate2D, nearByDistance : Double) {
        
        let query = PFQuery(className: PHParsePostClassKey)
//        if (self.allPosts.count == 0 ) {
//            query.cachePolicy = PFCachePolicy.CacheThenNetwork
//        }
        
        let point = PFGeoPoint(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
        query.whereKey(PHParsePostLocationKey, nearGeoPoint: point, withinKilometers: PHPostMaximumSearchRadius)
        query.includeKey(PHParsePostUserKey)
        
        query.limit = PHNeabyPostsMaxQuantity
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error != nil) {
                print("error in geo query \(error!.description)")
            } else {
                if let pfObjects = objects as? [PFObject] {
                    self.mapView.removeAnnotations(self.allPosts)
                    self.allPosts.removeAll()
                    for object in pfObjects {
                        let fetchedPost = PHPost(object: object)
                        let objectLocation = CLLocation(latitude: fetchedPost.coordinate.latitude, longitude: fetchedPost.coordinate.longitude)
                        let distance = self.currentLocation.distanceFromLocation(objectLocation)
                        if distance > nearByDistance {
                            fetchedPost.hidePostInfoOutside()
                        }
                        self.allPosts.append(fetchedPost)
                    }
                }
                
                self.mapView.addAnnotations(self.allPosts)
            }
        }
    }
    
    // new Post add to map

    func updateMapForNewPost(post: PFObject) {
        let newPost = PHPost(object: post)
        self.allPosts.append(newPost)
        self.mapView.addAnnotation(newPost)
    }
    
    
    
    // MARK: test
    /*
    @IBAction func switchMapListView(sender: UISegmentedControl) {
//    @IBAction func switchViewTest(sender: UISegmentedControl) {
        self.hideMapType()
        if sender.selectedSegmentIndex == 0 {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.mapView.transform = CGAffineTransformMakeTranslation(0, 0)
                self.tableView.transform = CGAffineTransformMakeTranslation(0, 0)
                self.currentLocationButton.transform = CGAffineTransformMakeTranslation(0, 0)
                self.showMapTypeButton.transform = CGAffineTransformMakeTranslation(0, 0)
            })
//            self.tableView?.hidden = true
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.mapView.transform = CGAffineTransformMakeTranslation(self.mapView.frame.width * (-1.0), 0)
                self.tableView.transform = CGAffineTransformMakeTranslation(self.mapView.frame.width * (-1.0), 0)
                self.currentLocationButton.transform = CGAffineTransformMakeTranslation(self.mapView.frame.width * (-1.0), 0)
                self.showMapTypeButton.transform = CGAffineTransformMakeTranslation(self.mapView.frame.width * (-1.0), 0)
            })
//            self.tableView?.hidden = false
        }
    }
}



extension PHMapViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPosts.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        let thisPost = self.allPosts[indexPath.row]
        cell!.textLabel!.text = thisPost.title!
        return cell!
    }
    
*/
    
    
}


