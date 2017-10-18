//
//  SQLiteConnect.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/25.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation


class SQLiteConnect{
    var db:OpaquePointer? = nil
    
    
    init?() {
        
        
        let sqlitePath =  NSHomeDirectory() + "/Documents/sqlite3.sqlite"
        if sqlite3_open(sqlitePath, &db) == SQLITE_OK{
//            print("連接SQLite成功")
            
            
        }else{
            return nil
        }
        
    }
    
    
    func insert(_ tableName:String,rowInfo:[String:String]){
        
        var statement:OpaquePointer? = nil
        let rowKey = "("+rowInfo.keys.joined(separator: ",")+")"
        let rowValue = "("+rowInfo.values.joined(separator: ",")+")"
        let sql = "insert into \(tableName) " + rowKey + " values " + rowValue
        let utf8 = sql.cString(using: String.Encoding.utf8)
        
        if sqlite3_prepare_v2(db,utf8, -1, &statement,nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
//                print("新增成功")
            }
        }
        
        sqlite3_finalize(statement)
        sqlite3_close(db)
        
        
        
    }
    
    func delete(_ tableName:String,cond:String?){
        var statement:OpaquePointer? = nil
        var sql = "delete from \(tableName)"
        
        if let condition = cond{
            sql += " where \(condition)"
        }
        
        
        let utf8 = sql.cString(using: String.Encoding.utf8)
        
        if  sqlite3_prepare_v2(db, utf8,-1,&statement,nil) == SQLITE_OK{
            
            if sqlite3_step(statement) == SQLITE_DONE{
//                print("刪除成功")
            }
            
        }
        
        
        
    }
    
    func fetch(_ tableName:String,cond:String?,order:String?)->[[String:Any?]]{
        var statement:OpaquePointer? = nil
        var sql = "select * from \(tableName)"
        
        if let condition = cond {
            sql += " where \(condition)"
        }
        if let orderBy = order{
            sql += " order by \(orderBy)"
        }
        let utf8 = sql.cString(using:String.Encoding.utf8)
        
        
        sqlite3_prepare_v2(db, utf8,-1,&statement,nil)
        
        var data = [[String:Any?]]()
        
        while sqlite3_step(statement) == SQLITE_ROW{
            
            let count = sqlite3_column_count(statement)
            
            
            let  dictionary:[String:Any?]? = {
                
                var dict = [String:Any?]()
                for i in 0..<count{
                    
                    
                    var value:Any? = 0
                    
                    switch sqlite3_column_type(statement, i) {
                        
                    case SQLITE_INTEGER:
                        
                        value = Int(sqlite3_column_int(statement,i))
    
                    case SQLITE_TEXT:
                        
                        if let  cValue = sqlite3_column_text(statement,i){
                            value = String(cString: cValue)
                            
                        }
                    case SQLITE_FLOAT:
                        
                        value = sqlite3_column_double(statement,i)
                        
                        
                    default:
                        
                        value = nil
                    }
                    
                    guard let  key = sqlite3_column_name(statement,i) else{
                        return nil
                        
                    }
                    
                    let keyString = String(cString: key)
                    
                    dict[keyString] = value
                    
                    
                }
                return dict
            }()
            
            if let myDictonary = dictionary{
                data.append(myDictonary)
            }
            
            
            
        }
        sqlite3_finalize(statement)
        sqlite3_close(db)
        
        return data
    }
    
    
}



