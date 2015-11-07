//
//  PHPostTableCell.swift
//  PostHere
//
//  Created by XunGong on 2015-09-18.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class PHPostTableCell: PFTableViewCell {

    var thisPost : PFObject?
    var offsetLeft = CGFloat(30)
    var offsetRight = CGFloat(5)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPost(post : PFObject) {
        self.thisPost = post
        createViews()
    }
    
    func setOffset(l : CGFloat, r : CGFloat) {
        self.offsetLeft = l
        self.offsetRight = r
    }
    
    private func createViews() {
        
        var currentHeight = CGFloat(0)
        
        var name = "Anonymous"
        if self.thisPost![PHParsePostUserKey] != nil {
            name = (self.thisPost![PHParsePostUserKey] as! PFUser)[PHParseUserNameKey] as! String
        }
        let nameLabel = UILabel(frame: CGRectMake(offsetLeft, 0, self.contentView.frame.width - offsetLeft - offsetRight, 20))
        nameLabel.text = name
        nameLabel.backgroundColor = UIColor.greenColor()
        self.contentView.addSubview(nameLabel)
        currentHeight += nameLabel.frame.height
        
        let postText = self.thisPost![PHParsePostTextKey] as! String
        var textFrame : CGRect?
        if self.thisPost![PHParsePostPhotoThumbnail] != nil {   // has photo
            
            textFrame = CGRectMake(offsetLeft, currentHeight, nameLabel.frame.width, 50)
            currentHeight += textFrame!.height
            
            let photoRatio = self.thisPost![PHParsePostPhotoRatio] as! CGFloat
            
            let photoFrame = CGRectMake(offsetLeft,currentHeight,nameLabel.frame.width, nameLabel.frame.width * photoRatio)
            currentHeight += photoFrame.height
            
            
            let photoFile = self.thisPost![PHParsePostPhotoThumbnail] as! PFFile
            
            photoFile.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                if (error == nil && photoData != nil) {
                    let photo = UIImage(data: photoData!)
                    for view in self.contentView.subviews {
                        if view is UIImageView {
                            (view as! UIImageView).image = photo
                        }
                    }
                }
            })
            
            
            
            let photoView = UIImageView(frame: photoFrame)
            photoView.backgroundColor = UIColor.lightGrayColor()
            self.contentView.addSubview(photoView)
        } else {   // no photo
            textFrame = CGRectMake(offsetLeft, currentHeight, nameLabel.frame.width, 100)
            currentHeight += textFrame!.height
        }
        
        let postTextLabel = UILabel(frame: textFrame!)
        postTextLabel.textAlignment = NSTextAlignment.Center
        postTextLabel.text = postText
        postTextLabel.backgroundColor = UIColor.orangeColor()
        self.contentView.addSubview(postTextLabel)
        
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
