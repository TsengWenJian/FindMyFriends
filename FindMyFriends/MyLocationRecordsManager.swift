//
//  MyLocationRecord.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/27.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation


struct sqliteKey{
    
    static let id = "id"
    static let startTime = "start_time"
    static let totalTime = "total_time"
    static let lat = "lat"
    static let lon = "lon"
    static let diatancce = "distance"

}


struct DetailRecord {
    let id:Int?
    let startTime:String
    let totalTime:String
    let lat:Double
    let lon:Double
    let distance:Int

}

struct LocationRecord {
    let id:Int?
    let startTime:String
    let totalTime:String
}



enum tableNameType:String {
    case DetailRecord = "DetailRecord"
    case LocationRecord = "LocationRecord"
}


class MyLocationRecordsManager{
    
    let db = SQLiteConnect()
    let tableName:tableNameType
    
    init(_ tableName:tableNameType) {
        
        self.tableName = tableName
        
    }
    
    
   
    // MARK:- DetailRecord Function
    func insertDetailRecord(record:DetailRecord){
       
    
        if let mydb = db{
            
            mydb.insert(tableName.rawValue,
                        rowInfo:[
                            sqliteKey.startTime:"'\(record.startTime)'",
                            sqliteKey.totalTime:"'\(record.totalTime)'",
                            sqliteKey.lat:"\(record.lat)",
                            sqliteKey.lon:"\(record.lon)",
                            sqliteKey.diatancce:"\(record.distance)"])
            
        }
    }
    
    
    
    func getDetailRecords(cond:String?,order:String?)->[DetailRecord]{
        
        if let mydb = db{
            
            let data = mydb.fetch(tableName.rawValue,cond: cond, order: order)
            var myRecordsArray = [DetailRecord]()
            
            for record in data{
                
                
                guard let id = record[sqliteKey.id] as? Int,
                    let startTime = record[sqliteKey.startTime] as? String,
                    let totalTime = record[sqliteKey.totalTime] as? String,
                    let lat = record[sqliteKey.lat] as? Double,
                    let lon = record[sqliteKey.lon] as? Double,
                    let distance = record[sqliteKey.diatancce] as? Int else{
                        
                        
                        continue
                        
                }
                
                let myRecord = DetailRecord(
                    id:id,
                    startTime:startTime,
                    totalTime:totalTime,
                    lat:lat,
                    lon:lon,
                    distance: distance)
                myRecordsArray.append(myRecord)
                
            }
            return myRecordsArray
            
        }
        
        return [DetailRecord]()
        
    }
    
    func deleteRecord(cond:String?){
        
        if let mydb = db{
            
            mydb.delete(tableName.rawValue,cond: cond)
            
        }
        
    }
    
    
    //MARK:- LocationRecord Fuction
    
    func insertLocatoinRecord(record:LocationRecord){
        
        
        if let mydb = db{
            
            mydb.insert(tableName.rawValue,
                        rowInfo:[
                            sqliteKey.startTime:"'\(record.startTime)'",
                            sqliteKey.totalTime:"'\(record.totalTime)'"
                ])
        }
        
        
    }
    
    
    
    func getLocatoinRecord(cond:String?,order:String?)->[LocationRecord]{
        
        if let mydb = db{
            
            let data = mydb.fetch(tableName.rawValue,cond:cond, order: order)
            var myRecordsArray = [LocationRecord]()
            
            for record in data{
                
                
                guard let id = record[sqliteKey.id] as? Int,
                    let startTime = record[sqliteKey.startTime] as? String,
                    let totalTime = record[sqliteKey.totalTime] as? String
                    else{
                        
                        
                        continue
                        
                }
                let myRecord = LocationRecord(
                    id:id,
                    startTime:startTime,
                    totalTime:totalTime
                )
                myRecordsArray.append(myRecord)
                
            }
            return myRecordsArray
            
        }
        
        return [LocationRecord]()
        
    }
    
       
    
}
