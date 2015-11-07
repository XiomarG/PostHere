//
//  PHTextPostHeaderView.swift
//  PostHere
//
//  Created by XunGong on 2015-09-13.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import Parse

class PHPostDetailHeaderView: UIView {

    var postedBy : String!
    var postedText : String!
    
    var nameLabel : UILabel?
    var textLabel : UILabel?
    
    var adjustedHeight : CGFloat?
    
    
    init(frame: CGRect, post: PFObject){
        
        super.init(frame: frame)
        
        self.postedBy = post[PHParseUserNameKey] as! String
        self.postedText = post[PHParsePostTextKey] as! String
        
        self.backgroundColor = UIColor.clearColor()
        
        self.createView()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createView(){
        
        
        self.nameLabel = UILabel(frame: CGRectMake(0, 0 ,self.frame.width,50))
        self.nameLabel!.text = self.postedBy
        self.nameLabel?.backgroundColor = UIColor.grayColor()
        self.addSubview(self.nameLabel!)
        
        self.textLabel = UILabel(frame: CGRectMake(0,50, self.frame.width, 200))
        self.textLabel!.text = self.postedText
        self.textLabel?.sizeToFit()
        self.textLabel?.frame = CGRectMake(0, 50, self.textLabel!.frame.width, self.textLabel!.frame.height + CGFloat(50))
        self.textLabel?.backgroundColor = UIColor.orangeColor()
        self.addSubview(self.textLabel!)

        let size = CGSize(width: self.frame.width, height: self.nameLabel!.frame.height + self.textLabel!.frame.height)
        self.sizeThatFits(size)
        
        
    }
    internal func newHeight() -> CGFloat {
        return self.adjustedHeight!
    }
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    

}
