//
//  PHLoadMoreCommentCell.swift
//  PostHere
//
//  Created by XunGong on 2015-09-18.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit
import ParseUI

class PHLoadMoreCommentCell: PFTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let label = UILabel(frame: self.contentView.frame)
        label.text = "Load More Comments..."
        label.textAlignment = NSTextAlignment.Center
        self.contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
