//
//  AssetRequisitionTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/01/25.
//

import Foundation
import SQLite3

class AssetRequisitionTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    // Create AssetRequisitionTable
    func createAssetRequisitionTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS AssetRequisitionTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                IsActive INTEGER,
                Label TEXT,
                Value TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating AssetRequisitionTable")
        }
    }
    
    // Insert data into AssetRequisitionTable
    func saveAssetRequisition(model: AssetRequisitionModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO AssetRequisitionTable (IsActive, Label, Value, attributesType, attributesUrl, isSync) VALUES (?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            let isActiveValue = model.IsActive == true ? 1 : 0
            sqlite3_bind_int(statement, 1, Int32(isActiveValue))
            sqlite3_bind_text(statement, 2, model.Label ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, model.Value ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, model.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, model.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, model.isSync ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting AssetRequisition: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("AssetRequisitionTable inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    // Fetch all records from AssetRequisitionTable
    func getAssetRequisitions() -> [AssetRequisitionModel] {
        var resultArray = [AssetRequisitionModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AssetRequisitionTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = AssetRequisitionModel()
                
                model.localId = String(cString: sqlite3_column_text(statement, 0))
                model.IsActive = sqlite3_column_int(statement, 1) == 1
                model.Label = String(cString: sqlite3_column_text(statement, 2))
                model.Value = String(cString: sqlite3_column_text(statement, 3))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 4))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 5))
                model.attributes = AssetRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
                model.isSync = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching AssetRequisitionTable records.")
        }
        
        return resultArray
    }
    
    // Fetch records filtered by IsActive status
    func getActiveAssetRequisition() -> [AssetRequisitionModel] {
        var resultArray = [AssetRequisitionModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AssetRequisitionTable WHERE IsActive = 1"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = AssetRequisitionModel()
                
                model.localId = String(cString: sqlite3_column_text(statement, 0))
                model.IsActive = sqlite3_column_int(statement, 1) == 1
                model.Label = String(cString: sqlite3_column_text(statement, 2))
                model.Value = String(cString: sqlite3_column_text(statement, 3))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 4))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 5))
                model.attributes = AssetRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
                model.isSync = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching active AssetRequisitionTable records.")
        }
        
        return resultArray
    }
    
}

