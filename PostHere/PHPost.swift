//
//  PHPost.swift
//  PostHere
//
//  Created by XunGong on 2015-08-25.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import MapKit
import Parse

class PHPost: NSObject, MKAnnotation {
    
    var user : PFUser?
    var object : PFObject?
    var title : String?
    var subtitle : String?
    var postCoordinate : CLLocationCoordinate2D
    var pinColor = MKPinAnnotationColor.Green
    
    init(coordinate : CLLocationCoordinate2D, title : String, subtitle : String?) {
        self.postCoordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    var coordinate : CLLocationCoordinate2D {
        return self.postCoordinate
    }
    
    
    convenience init(object: PFObject) {
        let geoPoint = object[PHParsePostLocationKey]
        let coordinate = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
        let title = object[PHParsePostTextKey] as! String
        var subtitle = "Anonymous"
        if (object[PHParsePostUserKey] != nil) {
            let user = object[PHParsePostUserKey] as? PFUser
            subtitle = user![PHParseUserNameKey] as! String
        }
        
        self.init(coordinate: coordinate, title: title, subtitle: subtitle)
        self.object = object
        if (object[PHParsePostUserKey] != nil) {
            self.user = object[PHParsePostUserKey] as? PFUser
        }
    }
    func hidePostInfoOutside() {
        self.title = "Too far to read"
        self.subtitle = nil
        self.pinColor = .Red
    }
}
