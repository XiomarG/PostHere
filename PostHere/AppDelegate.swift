/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import MapKit
import Bolts
import Parse
import ParseUI

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PFLogInViewControllerDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var tabBarController : PHTabBarController!
    var mapViewController : PHMapViewController?
    //var mapViewController : PHMapViewController!
    //var rightViewController : UIViewController!
    //var createPostViewController : PHCreatePostController?
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()

        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("4U95EubIvb19eXxeSPBtptFwYRcBwPyZYHjzMvSH",
            clientKey: "PgxHfTHeXvc5MzDJsKIUt7ept8TfMt4prT46UCMU")
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************

        //PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes : UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types : UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
            let mySetting = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(mySetting)
        }
        
        let testSection = "tab"
        
        // MARK: Init NSUserDefault 
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.objectForKey(PHUserDefaultsFetchRadiusKey) == nil {
            userDefaults.setDouble(PHDefaultFetchRadius, forKey: PHUserDefaultsFetchRadiusKey)
        }
        if userDefaults.objectForKey(PHUserDefaultsLatitudeKey) == nil {
            userDefaults.setDouble(49.284163, forKey: PHUserDefaultsLatitudeKey)
            userDefaults.setDouble(-123.124410, forKey: PHUserDefaultsLongitudeKey)
        }
        
        // MARK: Init Login VC
        switch testSection {
        case "login":
            if (PFUser.currentUser() != nil) {
                let loginViewController = PFLogInViewController();
                //loginViewController.fields =
                
                loginViewController.delegate = self
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = UINavigationController(rootViewController: loginViewController)
                self.window?.makeKeyAndVisible()
            }
        case "map":
        
            // MARK: Initial Map VC
            let mapViewController = PHMapViewController();
            //loginViewController.fields =
            
            //loginViewController.delegate = self
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = UINavigationController(rootViewController: mapViewController)
            self.window?.makeKeyAndVisible()
            
        case "tab":
            presentTabBarController()
        default: break;
            

        }
        
        return true
    }

    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded, error)  in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    
    func presentTabBarController() {
        self.tabBarController = PHTabBarController()
        self.mapViewController = PHMapViewController()
        let postsTableViewController = PHPostsTableViewController(className: PHParsePostClassKey)
        let rightViewController = UIViewController()
        self.mapViewController!.dataSource = self.tabBarController
        postsTableViewController.dataSource = self.tabBarController
        
        
        let mapNavigationController = UINavigationController(rootViewController: self.mapViewController!)
        let postsTableNavigationController = UINavigationController(rootViewController: postsTableViewController)
        let emptyNavigationController = UIViewController()
        let rightNavigationController = UINavigationController(rootViewController: rightViewController)
        
        let mapTabBarItem = UITabBarItem(title: "Map", image: nil, tag: 0)
        let postsTableTabBarItem = UITabBarItem(title: "List", image: nil, tag: 1)
        let createPostTabBarItem = UITabBarItem(title: "Create", image: nil, tag: 2)
        let rightTabBarItem = UITabBarItem(title: "right", image: nil, tag: 3)
        
        mapNavigationController.tabBarItem = mapTabBarItem
        postsTableNavigationController.tabBarItem = postsTableTabBarItem
        emptyNavigationController.tabBarItem = createPostTabBarItem
        rightNavigationController.tabBarItem = rightTabBarItem
        
        self.tabBarController.delegate = self
        self.tabBarController.setViewControllers([mapNavigationController, postsTableNavigationController ,emptyNavigationController, rightNavigationController], animated: false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: self.tabBarController)
        self.tabBarController.navigationController?.navigationBarHidden = true
        self.window?.makeKeyAndVisible()
        
        
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            let createPostViewController = PHCreatePostController()
            createPostViewController.dataSource = self.tabBarController
            createPostViewController.mapDelegate = self.mapViewController!
            let postNavigationController = UINavigationController(rootViewController: createPostViewController)
            self.tabBarController.presentViewController(postNavigationController, animated: true, completion: nil)
            return false
        } else {
            return true
        }    }

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }

    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}


