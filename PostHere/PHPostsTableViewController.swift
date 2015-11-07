//
//  PHPostsTableViewController.swift
//  PostHere
//
//  Created by XunGong on 2015-09-09.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PHPostsTableViewController: PFQueryTableViewController {

    var cellOffsetLeft = CGFloat(30)
    var cellOffsetRight = CGFloat(5)
    
    
    var dataSource : PHTabBarController!
    var fetchRadius : Double {   // in meters
        return NSUserDefaults.standardUserDefaults().doubleForKey(PHUserDefaultsFetchRadiusKey)
    }
    
    
    // MARK: initializer
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
        self.parseClassName = className
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 10
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "All Posts"
        self.navigationController?.navigationBar.backgroundColor = UIColor.yellowColor()
        self.loadObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadObjects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        let point = PFGeoPoint(latitude: self.dataSource.currentLocation.coordinate.latitude, longitude: self.dataSource.currentLocation.coordinate.longitude)
        
        query.whereKey(PHParsePostLocationKey, nearGeoPoint: point, withinKilometers: self.fetchRadius / 1000)
        
        return query

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let identifier = "post list cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PHPostTableCell
        if cell == nil {
            cell = PHPostTableCell(style: .Default, reuseIdentifier: identifier)
        }
        
        for view in cell!.contentView.subviews {
            view.removeFromSuperview()
        }
        
        
        cell!.setPost(object!)
        
//        let thispostgeopoint = object?[PHParsePostLocationKey] as? PFGeoPoint
//        let location = CLLocation(latitude: (thispostgeopoint?.latitude)!, longitude: (thispostgeopoint?.longitude)!)
//        let distance = self.dataSource.currentLocation.distanceFromLocation(location)
//        let text = object?[PHParsePostTextKey] as? String
//        let user = object?[PHParsePostUserKey] as? PFUser
//        var name = "Anonymous"
//        if (user != nil) {
//            name = user![PHParseUserNameKey] as! String
//        }
//        cell?.textLabel?.text = text
//        cell?.detailTextLabel?.text = name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let nameHeight = CGFloat(20)
        
        let post = objectAtIndexPath(indexPath)
        if post != nil {
            if post![PHParsePostPhotoKey] != nil {
                let photoRatio = post![PHParsePostPhotoRatio] as! CGFloat
                return nameHeight + CGFloat(50) + (self.tableView.frame.width - cellOffsetLeft - cellOffsetRight) * photoRatio
            } else {
                return nameHeight + CGFloat(100)
            }
        }
        return CGFloat(0)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = objectAtIndexPath(indexPath)
        let detailViewController = PHPostDetailViewController(post: post!)
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
        
    }
    
    
}

protocol PHPostsTableViewControllerDataSource {
    func currentLocationForPostsTable(contoller : PHPostsTableViewController) -> CLLocation
}
