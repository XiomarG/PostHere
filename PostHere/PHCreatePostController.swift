//
//  PHCreatePostController.swift
//  PostHere
//
//  Created by XunGong on 2015-08-23.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class PHCreatePostController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate     {

    @IBOutlet var mainScrollView: UIScrollView!
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var pictureBtn: UIButton!
    @IBOutlet var photoView: UIImageView!

    @IBOutlet var photoViewHeightConstraint: NSLayoutConstraint!
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    let insetMargin = CGFloat(20)
    var dataSource : PHTabBarController!
    var hasPicture = false
    var tempContent : String?
    var mapDelegate : PHMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTextView.delegate = self
        postTextView.text = "Write your post here !"
        postTextView.textColor = UIColor.lightGrayColor()   
        self.hasPicture = false
        setNaviItems()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        postTextView.text = "Write some post!"
//        postTextView.textColor = UIColor.lightGrayColor()
//        postTextView.becomeFirstResponder()
    }
    
    @IBAction func addOrDelelePicture(sender: UIButton) {
        if (hasPicture == false) {
            if UIImagePickerController.isSourceTypeAvailable(.Camera)
            {
                let optionMenu = UIAlertController(title: "Choose Image From", message: "", preferredStyle: .ActionSheet)
                let fromCamera = UIAlertAction(title: "Camera", style: .Default)
                    {   _ -> Void in
                        self.takePhoto()
                }
                let fromLibrary = UIAlertAction(title: "Library", style: .Default)
                    {   _ -> Void in
                        self.chooseFromLibrary()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel)
                    {    _ -> Void in
                }
                
                optionMenu.addAction(fromCamera)
                optionMenu.addAction(fromLibrary)
                optionMenu.addAction(cancelAction)
                self.presentViewController(optionMenu, animated: true, completion: nil)
            } else {
                self.chooseFromLibrary()
            }
        } else {
            for view in self.view.subviews {
                if view is UIImageView {
                    view.removeFromSuperview()
                }
            }
            self.hasPicture = false
            self.photoView.frame = CGRectMake(self.photoView.frame.origin.x, self.photoView.frame.origin.y, self.photoView.frame.width, 0)
            self.pictureBtn.setTitle("Attach Picture", forState: .Normal)
            self.pictureBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    // MARK: add/remove picture
    
    private func takePhoto() {
//        self.tempContent = self.postTextView.text
        
        let picker = UIImagePickerController()
        picker.sourceType = .Camera
        picker.delegate = self
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
    private func chooseFromLibrary() {
//        self.tempContent = self.postTextView.text
        
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var photo = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if photo == nil {
            photo = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        let photoFrame = CGRectMake(self.postTextView.frame.origin.x, self.pictureBtn.frame.origin.y + 40, self.postTextView.frame.size.width, photo!.size.height / photo!.size.width * self.postTextView.frame.size.width)
        
        self.photoView.frame = photoFrame
        self.photoView.image = photo
        
        
//        let imageView = UIImageView(frame: imageFrame)
//        imageView.image = picture
        
//        self.view.addSubview(imageView)
        self.hasPicture = true
        self.pictureBtn.setTitle("Remove Picture", forState: UIControlState.Normal)
        self.pictureBtn.setTitleColor(UIColor.redColor(), forState: .Normal)
//        self.pictureBtn.titleLabel!.text = "Remove Picture"
//        self.pictureBtn.setNeedsLayout()
        dismissViewControllerAnimated(true, completion: nil)
//        self.postTextView.text = self.tempContent   
    }
    
    override func viewDidLayoutSubviews() {
        self.photoViewHeightConstraint.constant = self.photoView.frame.height
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func setNaviItems() {
        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "didCancel")
        let postBtn = UIBarButtonItem(title: "Post", style: .Done, target: self, action: "didPost")
        self.navigationItem.leftBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem = postBtn
        self.navigationItem.title = "New"
    }
    func didCancel() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func didPost() {
        self.postTextView.resignFirstResponder()
        // data prep
        let location = self.dataSource.currentLocationForCreatePost(self)
        //let coordinate = location.coordinate
        let currentGeoPoint = PFGeoPoint(location: location)
        let user = PFUser.currentUser()
        
        // make PFObject
        // test to save 100 posts
        //var allnewposts = [PFObject]()
        
        //for _ in 0 ... 1{
        let postObject = PFObject(className: PHParsePostClassKey)
        
        
        // add picture to post
        if self.hasPicture == true {
//            for view in self.view.subviews {
//                if view is UIImageView {
//                    let photo = (view as! UIImageView).image!
            let photo = (self.photoView.image)
                    let photoData = UIImageJPEGRepresentation(photo!, 0.5)
                    let photoFile = PFFile(data: photoData!)
                    let photoRatio = photo!.size.height / photo!.size.width
    //                let thumbnailSize = CGSize(width: 20.0, height: photoRatio * 20.0)
    //                UIGraphicsBeginImageContext(thumbnailSize)
    //                photo.drawInRect(CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height))
    //                let thumbnailPhoto = UIGraphicsGetImageFromCurrentImageContext()
                    let thumbnailPhotoData = UIImageJPEGRepresentation(photo!, 0.05)
                    let thumbnailPhotoFile = PFFile(data: thumbnailPhotoData!)
                    postObject[PHParsePostPhotoKey] = photoFile
                    postObject[PHParsePostPhotoThumbnail] = thumbnailPhotoFile
            print("original size \(photoData?.length)  thunmbnail size \(thumbnailPhotoData?.length)")
                    postObject[PHParsePostPhotoRatio] = photoRatio
//                }
//            }
        
        }
        
        
        
        postObject[PHParsePostTextKey] = self.postTextView.text
        postObject[PhParsePostCommentCountKey] = 0
        
            //let upper : UInt32 = 100
        let randomLatitude = Double((rand()) % 100 - 50) / Double(5000)
        let randomLongitude = Double((rand()) % 100 - 50) / Double(5000)
        let randomGeopoint = PFGeoPoint(latitude: currentGeoPoint.latitude + randomLatitude, longitude: currentGeoPoint.longitude + randomLongitude)
        postObject[PHParsePostLocationKey] = randomGeopoint
        if(user != nil){
            postObject[PHParsePostUserKey] = user

        }
        
        let readOnlyACL = PFACL()
        readOnlyACL.setPublicReadAccess(true)
        readOnlyACL.setPublicWriteAccess(false)
        postObject.ACL = readOnlyACL
            
            //allnewposts.append(postObject)
        
        postObject.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if ((error) != nil) {
                print("couldn't save")
                print(error)
                let alertView = UIAlertController(title: "error code \(error!.code)", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alertView, animated: true, completion: nil)
                return
            }
            if (succeeded) {
                print(postObject)
                print("saved")
                self.mapDelegate.updateMapForNewPost(postObject)
            } else {
                print("failed to save")
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

protocol PHCreatePostControllerDataSource {
    func currentLocationForCreatePost(contoller : PHCreatePostController) -> CLLocation
}

protocol PHNewPostCreatedProtocal {
    func updateMapForNewPost(post : PFObject)
}