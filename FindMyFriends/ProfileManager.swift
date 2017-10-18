//
//  Setting.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/25.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation


struct userDefaultKey {
    
    static let updateFrequency = "updateFrequency"
    static let userIsShareing = "userIsShareing"
    static let desiredAccuracy = "desiredAccuracy"
    static let userName = "userName"
    static let userID = "userID"
    static let photoURL = "photoURL"
    static let deviceToken = "deviceToken"
    
    
    
}


let notifyName_updateFrequency = "updateFrequency"
let notifyName_logOut = "logOut"
let notifyName_downloadFriends = "downloadFriends"



class ProfileManager {
    
    var userName:String?{
        return UserDefaults.standard.string(forKey: userDefaultKey.userName)
    }
    
    var userID:String?{
        return UserDefaults.standard.string(forKey: userDefaultKey.userID)
        
    }
    
    var userPhotoURL:String?{
        return UserDefaults.standard.string(forKey: userDefaultKey.photoURL)
    }
    
    var deviceToken:String?{
        return UserDefaults.standard.string(forKey: userDefaultKey.deviceToken)
    }
    
    
    static let standard = ProfileManager()
    let sectionTitleArray = ["","分享我的位置","更新朋友位置頻率","背景更新模式","軌跡記錄","登出"]
    let backgroudUpdataBodyTitle = ["電池省電模式","一般精準度","高精準度"]
    let backgroudUpdateBodyValue:[Double] = [100,10,-1]
    let updateFrequencyBodyTitle = ["手動更新","自動更新"]
    let managerFriendTitle = ["管理好友","新增好友"]
    var gotoBeginRecord:Bool = false
    
    
    // pickerVC to be use
    let autoRefreshSecord:[String] = {
        var array = [String]()
        for i in 0...6000{
            let remainder = Double(i).truncatingRemainder(dividingBy: 10)
            if remainder == 0{
                array.append("\(i)")
            }
            
        }
        // remove 0 secord
        array.remove(at: 0)
        return array
    }()
    
    // initial value = 0 equal to manual update
    var updateFrequency:Int = UserDefaults.standard.integer(forKey:userDefaultKey.updateFrequency){
        didSet{
            UserDefaults.standard.set(updateFrequency,forKey:userDefaultKey.updateFrequency)
            UserDefaults.standard.synchronize()
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:notifyName_updateFrequency), object: nil)
            
        }
        
    }
    
    // initial value = false
    var userisShareing:Bool = UserDefaults.standard.bool(forKey:userDefaultKey.userIsShareing){
        
        didSet{
            
            UserDefaults.standard.set(userisShareing, forKey:userDefaultKey.userIsShareing)
            UserDefaults.standard.synchronize()
            
        }
    }
    
    // LocationManager desiredAccuracy
    var desiredAccuracy:Double = {
        
        let myUserdefaults = UserDefaults.standard
        
        // Set the initial value
        if myUserdefaults.double(forKey:userDefaultKey.desiredAccuracy) == 0.0 {
            myUserdefaults.set(-1,forKey:userDefaultKey.desiredAccuracy)
            UserDefaults.standard.synchronize()
        }
        
        return myUserdefaults.double(forKey:userDefaultKey.desiredAccuracy)
        }(){
        
        didSet{
            UserDefaults.standard.set(desiredAccuracy,forKey:userDefaultKey.desiredAccuracy)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func setUserDefaultValue(key:String,value:Any?){
        
        UserDefaults.standard.set(value,forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    
    
    
    
    func setUserName(name:String){
        
        setUserDefaultValue(key: userDefaultKey.userName,value:name)
    }
    
    
    func setID(id:String){
        
        setUserDefaultValue(key: userDefaultKey.userID,value:id)
        
    }
    
    func setPhotoURL(url:String){
        
        setUserDefaultValue(key:userDefaultKey.photoURL,value:url)
        
        
    }
    
    func setdeviceToken(token:String){
        
        setUserDefaultValue(key:userDefaultKey.deviceToken,value: token)
        
    }
    
    
    
    func setUserDataNil(){
        
        UserDefaults.standard.set(nil, forKey: userDefaultKey.userName)
        UserDefaults.standard.set(nil, forKey: userDefaultKey.userID)
        UserDefaults.standard.set(nil, forKey: userDefaultKey.photoURL)
        UserDefaults.standard.synchronize()
        
        
        
    }
}
