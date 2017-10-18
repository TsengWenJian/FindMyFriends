//
//  Measurements.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/28.
//  Copyright © 2017年 Nick. All rights reserved.
//
import Foundation

let notifyName_updateTime = "updateTime"
let notifyName_updateDistance = "updateDistance"

enum TimerStatus{
    case start
    case pause
    case none
    
}

class MyTimerManager {
    
    static let standard = MyTimerManager()
    var startTime = String()
    var distance:Int = 0{
        
        didSet{
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:notifyName_updateDistance), object: nil)
            }
        }
        
    }
    
    
    private var acumulatedTime:Int = 0
    private var timer = Timer()
    
    var timeString:String = "00:00:00"{
        didSet{
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:notifyName_updateTime), object: nil)
            }
        }
    }
    
    
    
    
    func startTimer(){
        
        
        timer = Timer.scheduledTimer(withTimeInterval:1, repeats: true, block: { (Timer) in
            
            self.setTime()
        })
        if startTime == ""{
            
            startTime = dateToString(date: Date())
            
        }
        
    }
    
    func setStartTime(time:String){
        startTime = time
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    func resetTimer(){
        acumulatedTime = 0
        timeString = "00:00:00"
        timer.invalidate()
        startTime = ""
        distance = 0
    }
    
    
    
    private  func setTime(){
        
        
        acumulatedTime+=1
        
        let tempHour = acumulatedTime / 3600;
        let tempMinute = acumulatedTime / 60 - (tempHour * 60);
        let tempSecond = acumulatedTime - (tempHour * 3600 + tempMinute * 60);
        
        
        var  hour = "\(tempHour)"
        var  Minute = "\(tempMinute)"
        var  Second = "\(tempSecond)"
        
        if (tempHour < 10) {
            hour = "0\(tempHour)";
        }
        if (tempMinute < 10) {
            Minute = "0\(tempMinute)";
        }
        if (tempSecond < 10) {
            Second = "0\(tempSecond)";
        }
        
        timeString =  "\(hour):\(Minute):\(Second)"
        
        
    }
    
    func dateToString(date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        return formatter.string(from: date)
        
    }
    
    func setTimeInitial(_ time:String){
        
        
        let timeArray = time.components(separatedBy: ":")
        
        if let hour = Int(timeArray[0]),
            let minute = Int(timeArray[1]),
            let second  = Int(timeArray[2]){
            
            acumulatedTime = hour*3600 + minute*60 + second
            
        }
        
    }
    
    func setDistanceInitial(_ distance:Int){
        self.distance = distance
        
    }
    
    
}
