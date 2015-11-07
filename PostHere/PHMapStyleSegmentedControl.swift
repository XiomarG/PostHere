//
//  PHMapStyleSegmentedControl.swift
//  PostHere
//
//  Created by XunGong on 2015-08-19.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import UIKit

@IBDesignable class PHMapStyleSegmentedControl: UISegmentedControl {

    var isShown = true {
        willSet(newValue) {
            if newValue == true {
                showControl()
            } else {
                hideControl()
            }
        }
    }
    
    func toggleAppear() {
        isShown = !isShown
    }
    let labels = ["Standard", "Satellite", "Hybrid"]
    
    func hideControl() {
        let moveTrans = CGAffineTransformMakeTranslation(95, 0)

        UIView.animateWithDuration(0.1) { () -> Void in
            self.transform = CGAffineTransformScale(moveTrans, 0.1, 1)
        }
//        let scaleTrans = CGAffineTransformMakeScale(0.1, 1)
//        self.transform = CGAffineTransformConcat(moveTrans, scaleTrans)
//        self.transform = CGAffineTransformMakeTranslation(80, 0)
        
//        for index in 0...2 {
//            setTitle("", forSegmentAtIndex: index)
//            setWidth(0, forSegmentAtIndex: index)
//        }
    }
    func showControl() {
//        for index in 0...2 {
//            setTitle(labels[index], forSegmentAtIndex: index)
//            setWidth(60, forSegmentAtIndex: index)
//        }
        UIView.animateWithDuration(0.1) { () -> Void in
            self.transform = CGAffineTransformMakeTranslation(0, 0)
        }
    }
    
}
