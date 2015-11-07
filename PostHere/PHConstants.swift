//
//  PHConstants.swift
//  PostHere
//
//  Created by XunGong on 2015-08-17.
//  Copyright © 2015 Xiomar. All rights reserved.
//

import Foundation

let PHDefaultFetchRadius = Double(10000)


// NSUserDefaults Keys
let PHUserDefaultsFetchRadiusKey = "fetch radius"
let PHUserDefaultsLatitudeKey = "default latitude"
let PHUserDefaultsLongitudeKey = "default longitude"
let PHUserDefaultsMapTypeIndex = "default map type index"


// Post Key

let PHParsePostLocationKey = "postlocation"
let PHParsePostTextKey = "posttext"
let PHParsePostUserKey = "postuser"
let PHAnonymous = "Anonymous"
let PHParsePostClassKey = "posts"
let PHParseUserNameKey = "parseusername"
let PHParsePostPhotoKey = "parsepicture"
let PHParsePostPhotoThumbnail = "ThunmnailPicture"
let PHParsePostPhotoRatio = "PictureRatio"
let PhParsePostCommentCountKey = "CommentCount"



// Activity Key
let PHParseActivityClassKey = "postsactivity"
let PHParseActivityTypeKey = "activitytype"
let PHParseActivityTypeComment = "activitycomment"
let PHParseActivityToUserKey = "touserkey"
let PHParseActivityFromUserKey = "fromuserkey"
let PHParseActivityCommentContentKey = "commentcontent"
let PHParseActivityObjectID = "activityobjectID"
let PHParseActivityCommenterNameKey = "commentername"

// Notification

let PHLocationDidChangeNotification = "PHLocationDidChangeNotification"
let PHPostCreatedNotification = "PHPostCreatedNotification"

// System Setting Constants

let PHNeabyPostsMaxQuantity = 500
let PHPostMaximumSearchRadius : Double = 100.0