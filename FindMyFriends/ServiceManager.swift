//
//  GetFriendsPosition.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/23.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

struct postServiceKey {
    
    
    static let data = "data"
    static let result = "result"
    static let errorCode = "errorCode"
    
    
    static let friends = "friends"
    static let searchResult = "searchResult"
    static let friendID = "friendID"
    
    static let dataType = "dataType"
    static let lat = "lat"
    static let lon = "lon"
    static let createTime = "createTime"
    
    static let applyID = "applyID"
    static let applidID = "applidID"
    static let status = "status"
    static let applyName = "applyName"
    static let action = "action"
    
    
    
    static let userID = "userID"
    static let account = "account"
    static let password = "password"
    static let userName = "userName"
    static let name = "name"
    static let photoURL = "photoURL"
    static let deviceToken = "deviceToken"
    
}


let base_url = "https://twenjian.com/FindMyFirend/"
let insertApplyFriendURL = "\(base_url)insertApplyFriend.php"
let selectApplyFriendURL = "\(base_url)selectApplyFriend.php"
let updateApplyFriendStatusURL = "\(base_url)updateApplyFriendStatus.php"
let searchFriendURL = "\(base_url)searchFriend.php"
let updateUserDataURL  = "\(base_url)updateUserData.php"
let insertLocationURL  = "\(base_url)insertLocation.php"
let deleteFriendURL  = "\(base_url)deleteFriend.php"
let updateDeviceTokenURL = "\(base_url)updateDeviceToken.php"
let loginAndRegisterURL = "\(base_url)loginAndRegister.php"
let selectFriendDataURL  = "\(base_url)selectFriendData.php"
let fbLogInURL  = "\(base_url)fbLogIn.php"

let notification_downloadDone = "downloadDone"
let isNotConnect = "無法取得網際網路"


typealias DoneHandler = (_ error:Error?,_ result:JSON?) -> Void
typealias done = ([Friend])->Void
typealias LoadImageDone = (Error?)->Void




func showSVProgressHUDError(error:String,delay:Double){
    SVProgressHUD.showError(withStatus: error)
    SVProgressHUD.setDefaultMaskType(.gradient)
    SVProgressHUD.dismiss(withDelay:delay)
}


struct Friend {
    
    let friendName:String
    let id:String
    let photoURL:String?
    let lastUpdateDateTime:String
    let lat:Double
    let lon:Double
    
}


class ServiceManager{
    

    static  let standard = ServiceManager()
    private var timer = Timer()
    var friends = [Friend](){
        
        didSet{
            
            DispatchQueue.main.async {
                
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: notification_downloadDone), object: nil)
                
            }
        }
    }
    
    var isConnectService:Bool{
        
        if let reah = Reachability(hostName:base_url){
            
            if reah.currentReachabilityStatus().rawValue == 0 {
                
                SHLog(message: "no internet connected")
                
                
                return false
            }else {
                
                SHLog(message: "internet connected successfully")
                
                return true
            }
            
        }
        return false
        
    }
    
    
    func uploadUserLocation(lat:Double,lon:Double){
        
    
        
        let dict = [postServiceKey.userID:ProfileManager.standard.userID!,
                    postServiceKey.lat:String(lat),
                    postServiceKey.lon:String(lon)]
        
        
        
        postToService(urlString: insertLocationURL,dict: dict) { (error, result) in
            
            
            
            if error != nil{
                SHLog(message: error.debugDescription)
            }
            
            
            guard let myResult = result else{
                return
                
            }
            
            if myResult[postServiceKey.result].boolValue{
                
                SHLog(message:"insertLocation success")
                
                
            }else{
                
                SHLog(message:"\(myResult[postServiceKey.errorCode].stringValue)")
                
                
            }
            
        }
        
    }
    
    
    
    
    func getFriendLocationsData(done:@escaping done){
        
        guard let  userID = ProfileManager.standard.userID else{
            return
        }
        let dict = [postServiceKey.userID:userID,
                    postServiceKey.dataType:"1"]
        
        
        
        postToService(urlString: selectFriendDataURL , dict:dict) { (error, result) in
            
            
            
            if error != nil{
                SHLog(message:error.debugDescription)
            }
            
            
            guard let myResult = result else{
                return
                
            }
            
            if myResult[postServiceKey.result].boolValue{
                
                
                let friendArr = myResult[postServiceKey.friends].arrayValue
                var array = [Friend]()
                for friend in friendArr{
                    
                    
                    
                    
                    let createTime = self.dateFormmater(date:friend[postServiceKey.createTime].doubleValue)
                    
                    let friend =  Friend(friendName:friend[postServiceKey.userName].stringValue,
                                         id: friend[postServiceKey.userID].stringValue,
                                         photoURL:friend[postServiceKey.photoURL].string,
                                         lastUpdateDateTime:createTime,
                                         lat: friend[postServiceKey.lat].doubleValue,
                                         lon: friend[postServiceKey.lon].doubleValue)
                    
                    
                    array.append(friend)
                    
                }
                
                done(array)
                
            }else{
                
                SHLog(message:"\(myResult[postServiceKey.errorCode].stringValue)")
                
                
            }
            
        }

    }
    
    func  dateFormmater(date:Double)->String{
        
        let formmater = DateFormatter()
        let date = Date(timeIntervalSince1970: date)
        formmater.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formmater.string(from: date)
        
    }
    
    
    func  resetRefreshFrequency(interval:TimeInterval){
        
        timer.invalidate()
        
        if ProfileManager.standard.updateFrequency != 0{
            
            timer = Timer.scheduledTimer(withTimeInterval:interval, repeats:true, block: { (Timer) in
                self.getFriendLocationsData(done: { (frendsArr) in
                    self.friends = frendsArr
                })
            })
            
        }
        
        
    }
    
    func downloadUserPhotoWriteToCach(URLStr:String,done:@escaping LoadImageDone){
        
        
        guard let url = URL(string:URLStr) else{
            return
        }
    
        let config = URLSessionConfiguration.ephemeral
        let task = URLSession(configuration: config).dataTask(with: url) { (data, respone, error) in
            
            if error != nil{
                
                return
            }
            
            
            guard let imageData = data else{
                
                return
            }
            let imageName = "profile_\(URLStr.hashValue).jpg"
            let cachesURL = FileManager.default.urls(for:.cachesDirectory,in:.userDomainMask).first
            let fullFileImageName = cachesURL?.appendingPathComponent(imageName)
            ProfileManager.standard.setPhotoURL(url: imageName)
            
            
            guard let _ = try? imageData.write(to:fullFileImageName!,options: [.atomic]) else{
                SHLog(message:"write file error")
                
                return
            }
            
            
            done(nil)
            
        }
        
        task.resume()
        
    }
    
    
    func refreshFirendLocation(){
        
        if isConnectService{
            
            getFriendLocationsData { (friendArr) in
            
                self.friends = friendArr
                
            }
            
        }else{
            
            showSVProgressHUDError(error: isNotConnect, delay:0.8)
            
        }
        
    }
    
    func updateDeviceToken(userID:String,deviceToken:String){
        
        let  dict = [postServiceKey.userID:userID,
                     postServiceKey.deviceToken:deviceToken]
        
        
        
        postToService(urlString:updateDeviceTokenURL, dict:dict) { (error, result) in
            
            
            if error != nil{
                SHLog(message: error.debugDescription)
            }
            
            
            guard let myResult = result else{
                return
                
            }
            
            if myResult[postServiceKey.result].boolValue{
                
                SHLog(message:"updateDeviceToken success")
                
                
            }else{
                
                SHLog(message:"\(myResult[postServiceKey.errorCode].stringValue)")
                
                
            }
            
            
        }
        
        
    }
    
    
    func postToService(urlString:String,dict:[String:String],done:@escaping DoneHandler){
        
        
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject:dict, options: []),
            let jsonStr = String(data:jsonData,encoding:.utf8) else{
                return
        }
        
        
        
        
        Alamofire.request(urlString, method:.post,parameters:[postServiceKey.data:jsonStr],headers: nil).response { (respone) in
            
            
//                        print(String(data: respone.data!, encoding:String.Encoding.utf8)!)
            
            
            if respone.error != nil{
                
                done(respone.error, nil)
                
                return
                
            }
            
            
            if let data = respone.data{
                
                done(nil,JSON(data))
                
            }
            
            
        }
    }
    
}







