//
//  OnTradeTable.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import Foundation
import UIKit
import SQLite3

class OnTradeTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createOnTradeTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS OnTradeTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                Id TEXT UNIQUE,
                DurableId TEXT,
                Label TEXT,
                Value TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating OnTradeTable")
        }
    }
    
    func saveOnTrade(onTrade: OnTrade, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO OnTradeTable (Id, DurableId, Label, Value, attributesType, attributesUrl, isSync) VALUES (?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, onTrade.Id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, onTrade.DurableId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, onTrade.Label ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, onTrade.Value ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, onTrade.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, onTrade.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, onTrade.isSync ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting OnTrade: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("OnTrade inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getOnTrades() -> [OnTrade] {
        var resultArray = [OnTrade]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM OnTradeTable"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var onTrade = OnTrade()
                
                onTrade.Id = String(cString: sqlite3_column_text(statement, 1))
                onTrade.DurableId = String(cString: sqlite3_column_text(statement, 2))
                onTrade.Label = String(cString: sqlite3_column_text(statement, 3))
                onTrade.Value = String(cString: sqlite3_column_text(statement, 4))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 5))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 6))
                onTrade.attributes = OnTrade.Attributes(type: attributesType, url: attributesUrl)
                onTrade.isSync = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(onTrade)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching OnTrade records.")
        }
        
        return resultArray
    }
    
    func getOnTradesById(forId id: String) -> [OnTrade] {
        var resultArray = [OnTrade]()
        var statement: OpaquePointer?
        
        let query = "SELECT * FROM OnTradeTable WHERE Id = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                var onTrade = OnTrade()
                onTrade.Id = String(cString: sqlite3_column_text(statement, 1))
                onTrade.DurableId = String(cString: sqlite3_column_text(statement, 2))
                onTrade.Label = String(cString: sqlite3_column_text(statement, 3))
                onTrade.Value = String(cString: sqlite3_column_text(statement, 4))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 5))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 6))
                onTrade.attributes = OnTrade.Attributes(type: attributesType, url: attributesUrl)
                onTrade.isSync = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(onTrade)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching OnTrade records by Id.")
        }
        return resultArray
    }
}
