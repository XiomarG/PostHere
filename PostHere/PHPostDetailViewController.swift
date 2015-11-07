//
//  PHPostDetailViewController.swift
//  PostHere
//
//  Created by XunGong on 2015-09-13.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class PHPostDetailViewController: PFQueryTableViewController, UITextFieldDelegate {

    static var timeFormatter : TTTTimeIntervalFormatter!
    
    var headerView : UIView!
    var footerView : UIView!
    var commentField : UITextField!
    var timeLabel : UILabel?
    var commentCount = Int(0)
    
    var thisPost : PFObject?
    
    var user : PFUser?
    var postBy : String!
    var postText : String!
    var postID : String!
    
    var cellInsetWidth = CGFloat(5)
    var cellInsetHeight = CGFloat(5)
    
    init(post : PFObject) {
        super.init(style: .Plain, className: PHParseActivityClassKey)
        if (PHPostDetailViewController.timeFormatter == nil) {
            PHPostDetailViewController.timeFormatter = TTTTimeIntervalFormatter()
        }
        self.parseClassName = PHParseActivityClassKey
        self.thisPost = post
        self.postBy = "Anonymous"
        self.paginationEnabled = true
        self.objectsPerPage = 5
        if (post[PHParsePostUserKey] != nil) {
            self.user = post[PHParsePostUserKey] as? PFUser
            self.postBy = self.user![PHParseUserNameKey] as! String
        }
        self.postText = post[PHParsePostTextKey] as! String
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBarItems()
        self.createHeaderView()
        self.createFooterView()
    }
    
    private func setUpNavBarItems() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.yellowColor()
        self.navigationItem.title = "Post"
    }
    
        // MARK: set header and footer view
    private func createHeaderView() {
        
        var currentHeight = CGFloat(0)
        self.headerView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, 0))
        
        // for poster name
        let nameLabel = UILabel(frame: CGRectMake(0, 0 ,self.tableView.frame.width,50))
        nameLabel.text = self.postBy
        nameLabel.backgroundColor = UIColor.grayColor()
        nameLabel.textAlignment = NSTextAlignment.Center
        currentHeight += nameLabel.frame.height
        self.headerView.addSubview(nameLabel)
        
        // for post content
        let textLabel = UILabel(frame: CGRectMake(0,currentHeight, self.tableView.frame.width, 200))
        textLabel.text = self.postText
        textLabel.sizeToFit()
        textLabel.textAlignment = NSTextAlignment.Center
        if (self.thisPost![PHParsePostPhotoKey] != nil) {  // if has photo, text shrink
            textLabel.frame = CGRectMake(0, 50, self.tableView.frame.width, textLabel.frame.height + CGFloat(20))
        } else {
            textLabel.frame = CGRectMake(0, 50, self.tableView.frame.width, textLabel.frame.height + CGFloat(150))
        }
        textLabel.backgroundColor = UIColor.orangeColor()
        currentHeight += textLabel.frame.height
        self.headerView.addSubview(textLabel)
        
        // for post picture
        var originalLoaded = false
        if (self.thisPost![PHParsePostPhotoKey] != nil) {
            // set image view first
            let photoRatio = self.thisPost![PHParsePostPhotoRatio] as! CGFloat
            let photoFrame = CGRectMake(textLabel.frame.origin.x, currentHeight, textLabel.frame.size.width, textLabel.frame.size.width * photoRatio)
            let photoView = UIImageView(frame: photoFrame)
            photoView.tag = 100
            currentHeight += photoFrame.height
            self.headerView.addSubview(photoView)
            
            // load thumbnail
            let photoThumbnailFile = self.thisPost![PHParsePostPhotoThumbnail] as? PFFile
            photoThumbnailFile?.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                if (error == nil && !originalLoaded) {
                    let photoThumnail = UIImage(data: photoData!)
                    for view in self.tableView.tableHeaderView!.subviews {
                        if (view is UIImageView) && (view as! UIImageView).tag == 100 {
                            (view as! UIImageView).image = photoThumnail
                        }
                    }
                }
            })
            
            // load original photo
            let photoFile = self.thisPost![PHParsePostPhotoKey] as? PFFile
            photoFile?.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                if error == nil {
                    originalLoaded = true
                    let photo = UIImage(data: photoData!)
                    for view in self.tableView.tableHeaderView!.subviews {
                        if (view is UIImageView) && (view as! UIImageView).tag == 100 {
                            (view as! UIImageView).image = photo
                        }
                    }
                }
            })
        }
        // add time label
        let timeString = PHPostDetailViewController.timeFormatter.stringForTimeIntervalFromDate(NSDate(), toDate: self.thisPost?.createdAt)
        self.timeLabel = UILabel(frame: CGRectMake(0, currentHeight, self.tableView.frame.width, 20))
        self.timeLabel!.textAlignment = NSTextAlignment.Right
        self.timeLabel!.backgroundColor = UIColor.lightGrayColor()
        self.timeLabel!.text = timeString
        self.headerView.addSubview(self.timeLabel!)
        currentHeight += self.timeLabel!.frame.height

        // add comment count label
        let commentCountString = "Comment(\(self.commentCount))"
        let commentCountLabel = UILabel(frame: self.timeLabel!.frame)
        commentCountLabel.textAlignment = NSTextAlignment.Left
        commentCountLabel.text = commentCountString
        self.headerView.addSubview(commentCountLabel)
        // load headview
        self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.width, currentHeight)
        self.tableView.tableHeaderView = self.headerView
    }
    
    private func renewCommentCountLabel() {
        self.commentCount++
        self.thisPost![PhParsePostCommentCountKey] = self.commentCount
        self.thisPost!.saveInBackground()
        for view in self.tableView.tableHeaderView!.subviews {
            if (view as? UILabel) != nil {
                if ((view as! UILabel).tag == 200 ){ // comment label
                    let theLabel = view as! UILabel
                    theLabel.text = "Comment(\(self.commentCount))"
                }
            }
        }
    }
    
    private func createFooterView() {
        
        self.footerView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
        //self.footerView.backgroundColor = UIColor.blueColor()

        let commentLabel = UILabel(frame: CGRectZero)
        commentLabel.text = "comment: "
        commentLabel.textAlignment = NSTextAlignment.Center
        commentLabel.sizeToFit()
        commentLabel.frame = CGRectMake(0, 0, commentLabel.frame.width, self.footerView.frame.height)
        
        self.footerView.addSubview(commentLabel)
        
        let textField = UITextField(frame: CGRectMake(commentLabel.frame.width + 10, 10, (self.tableView.frame.width - commentLabel.frame.width - 20), self.footerView.frame.height - 20))
        
        textField.layer.cornerRadius = 8.0;
        textField.layer.masksToBounds = true;
        textField.layer.borderColor = UIColor.orangeColor().CGColor
        textField.layer.borderWidth = 1.0;
        textField.returnKeyType = .Send
        self.commentField = textField
        self.commentField.delegate = self
        self.footerView.addSubview(textField)
        self.tableView.tableFooterView = self.footerView
    }
    
    // MARK: textFiledDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let trimmedComment = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (trimmedComment != "") {
            let comment = PFObject(className: PHParseActivityClassKey)
            comment[PHParseActivityTypeKey] = PHParseActivityTypeComment
            if (PFUser.currentUser() != nil ) {
                comment[PHParseActivityFromUserKey] = PFUser.currentUser()
            }
            if (self.thisPost![PHParsePostUserKey] != nil) {
                comment[PHParseActivityToUserKey] = self.thisPost![PHParsePostUserKey]
            }
            comment[PHParseActivityCommentContentKey] = trimmedComment
            comment[PHParseActivityObjectID] = self.thisPost!.objectId
            
            var ACL : PFACL?
            if (PFUser.currentUser() != nil) {
                ACL = PFACL(user: PFUser.currentUser()!)
            } else {
                ACL = PFACL()
            }
            
            ACL!.setPublicReadAccess(true)
            ACL!.setPublicWriteAccess(false)
            
            comment.ACL = ACL
            
            let commentingProgress = MBProgressHUD.showHUDAddedTo(self.tableView.superview, animated: true)
            commentingProgress.mode = MBProgressHUDMode.Indeterminate
            // save comment
            comment.saveEventually({ (succeeded, error) -> Void in
                
                if (error != nil) {
                    let alert = UIAlertController(title: "something wrong", message: error?.description, preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    print("comment succeeded")
                }
                commentingProgress.hide(true)
                self.commentField.text = ""
                self.paginationEnabled = false
                self.renewCommentCountLabel()
                self.loadObjects()
            })
        } else {
            print("empty comment")
        }
        self.tableView.reloadData()
        return textField.resignFirstResponder()
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.commentField.resignFirstResponder()
    }
    
    // MARK: PFQueryTable

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellIdentifier = "commentcell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PHCommentCell
        if (cell == nil) {
            cell = PHCommentCell(style: .Default, reuseIdentifier: cellIdentifier)
            cell!.cellInsetWidth = self.cellInsetWidth
            cell!.cellInsetHeight = self.cellInsetHeight
        }
        for view in cell!.contentView.subviews {
            view.removeFromSuperview()
        }
        cell?.setComment(object!)
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        let identifier = "NextPage"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PHLoadMoreCommentCell
        if (cell == nil) {

            cell = PHLoadMoreCommentCell(style: .Default, reuseIdentifier: identifier)
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row >= self.objects!.count {
            return 50.0
        }
        var name = "Anonymous"
        let comment = objectAtIndexPath(indexPath)
        if (comment![PHParseActivityFromUserKey] != nil) {
            name = (comment![PHParseActivityFromUserKey] as! PFUser )[PHParseUserNameKey] as! String
        }
        let str = name + ": " + (comment![PHParseActivityCommentContentKey] as! String)
        let textLabel = UILabel(frame: CGRectMake(self.cellInsetWidth, 0, self.tableView.frame.size.width - 2 * self.cellInsetWidth, CGFloat.max))
        
        textLabel.text = str
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        textLabel.sizeToFit()
        
        return textLabel.frame.size.height + 2 * cellInsetHeight
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey(PHParseActivityObjectID, equalTo: self.thisPost!.objectId!)
        query.whereKey(PHParseActivityTypeKey, equalTo: PHParseActivityTypeComment)
        query.orderByAscending("createdAt")
        return query
    }
}
