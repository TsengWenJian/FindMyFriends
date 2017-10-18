//
//  AppDelegate.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/20.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

import UserNotifications
import FBSDKCoreKit
import FacebookLogin
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        // Override point for customization after application launch.
        //iOS 8
        // let settings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
        // application.registerUserNotificationSettings(settings)
        // application.registerForRemoteNotifications()
        
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let notifiCenter = UNUserNotificationCenter.current()
        notifiCenter.delegate = self
        notifiCenter.requestAuthorization(options:[.alert,.badge,.sound]) { (bool, error) in
            
            if bool {
                
                SHLog(message: "iOS request notification success")
            }else{
                
                SHLog(message: "iOS 10 request notification fail")
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        if  ProfileManager.standard.deviceToken == nil{
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        copySqliteToDocument()
        
        return true
    }
    
    func copySqliteToDocument(){
        
        let fileManager = FileManager()
        let sqlitePath =  NSHomeDirectory() + "/Documents/sqlite3.sqlite"
        
        
        //Check if the database does not exist copy sqlite3.sqlite3 to Documents
        if !fileManager.fileExists(atPath:sqlitePath){
            
            let originPath = Bundle.main.path(forResource:"sqlite3", ofType: "sqlite")
            
            do{
                try fileManager.copyItem(atPath:originPath!, toPath: sqlitePath)}
            catch{
                SHLog(message: "copy sqlite error")
                
            }
        }
        
    }
   
    
    
   
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
    }
    
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        SHLog(message: "----------getToken-----------")
        let nsData = deviceToken as NSData
        var deviceTokenString = nsData.description
        deviceTokenString = deviceTokenString.replacingOccurrences(of: "<", with: "")
        deviceTokenString = deviceTokenString.replacingOccurrences(of: ">", with: "")
        deviceTokenString = deviceTokenString.replacingOccurrences(of: " ", with: "")
        ProfileManager.standard.setdeviceToken(token:deviceTokenString)
        
        
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
        SHLog(message:"-----didReceiveRemoteNotification------")
        if let aps = userInfo["aps"] as? [String: AnyObject],
            let badge = aps["badge"] as? Int{
            
            
            UIApplication.shared.applicationIconBadgeNumber = badge
            NotificationCenter.default.post(name:NSNotification.Name(rawValue:notifyName_downloadFriends), object: nil)
            
        }
        
        completionHandler(.newData)
        
    }
    

    // 前景通知觸發
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.sound,.alert])
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        
        SHLog(message:error.localizedDescription)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
    }
    
    
}

