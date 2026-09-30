//
//  OnAssetsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 29/11/24.
//

import Foundation
import SQLite3
import UIKit

class OnAssetsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createOnAssetsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS OnAssetsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                IsActive TEXT,
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
    
    func saveAsset(assetModel: AssetModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO OnAssetsTable (IsActive, Label, Value, attributesType, attributesUrl, isSync) VALUES (?, ?, ?, ?, ?, ?)"
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(assetModel.IsActive ?? 0))
            sqlite3_bind_text(statement, 2, assetModel.Label ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, assetModel.Value ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, assetModel.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, assetModel.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            
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
    
    func getAssets() -> [AssetModel] {
        var resultArray = [AssetModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM OnAssetsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var assetModel = AssetModel()
                assetModel.IsActive = Int(sqlite3_column_int(statement, 1))
                assetModel.Label = String(cString: sqlite3_column_text(statement, 2))
                assetModel.Value = String(cString: sqlite3_column_text(statement, 3))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 4))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 5))
                assetModel.attributes = AssetModel.Attributes(type: attributesType, url: attributesUrl)
                resultArray.append(assetModel)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching OnTrade records.")
        }
        return resultArray
    }
    
    
    func clearAssetsTable(completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let deleteQuery = "DELETE FROM OnAssetsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error clearing assets table: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Assets table cleared successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing clear table statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
}

