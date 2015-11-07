//
//  PFCommentCell.swift
//  PostHere
//
//  Created by XunGong on 2015-09-15.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class PHCommentCell: PFTableViewCell {

    var nameButton : UIButton?
    var contentLabel : UILabel?
    var user : PFUser?
    var timeLabel : UILabel?
    var mainView : UIView?
    var commenterName : String?
    var commentContent : String?
    var cellInsetWidth = CGFloat(0)
    var cellInsetHeight = CGFloat(0)
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        self.accessoryType = .None
        self.backgroundColor = UIColor.clearColor()
        
        self.commenterName = "Anonymous"
        

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setComment(comment : PFObject){
        if( comment[PHParseActivityFromUserKey] != nil) {
            self.user = comment[PHParseActivityFromUserKey] as? PFUser
            self.commenterName = self.user![PHParseUserNameKey] as? String
        }
        self.commentContent = comment[PHParseActivityCommentContentKey] as? String
        
        
        mainView = UIView(frame: self.contentView.frame)
        
        nameButton = UIButton(type: UIButtonType.Custom)
        
        
        contentLabel = UILabel(frame: CGRectMake(cellInsetWidth, cellInsetHeight, self.contentView.frame.size.width - 2 * cellInsetWidth, CGFloat.max))
        //contentLabel!.text = self.commenterName! + ": " + self.commentContent!

        
        let attComment = NSMutableAttributedString(string: self.commenterName! + ": " + self.commentContent!)
        let nsName = (self.commenterName! + ": ")
        let range = NSMakeRange(0, nsName.characters.count)
        attComment.setAttributes( [NSForegroundColorAttributeName : UIColor.blueColor()], range: range )
        
        contentLabel!.attributedText = attComment
        contentLabel!.numberOfLines = 0
        contentLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        contentLabel!.sizeToFit()
        
        
        
        mainView!.addSubview(self.nameButton!)
        mainView!.addSubview(self.contentLabel!)
        
        self.contentView.addSubview(mainView!)

    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
