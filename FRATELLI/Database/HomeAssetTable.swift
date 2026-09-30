//
//  HomeAssetTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/12/24.
//

import Foundation
import SQLite3

class HomeAssetTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createHomeAssetTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS HomeAssetTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                assetName TEXT,
                assetItemImg TEXT,
                isSpaceAvailable TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating HomeAssetTable")
        }
    }
    
    func saveHomeAssets(items: [HomeAssetModel], completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
            INSERT INTO HomeAssetTable (assetName, assetItemImg, isSpaceAvailable, OwnerId, isSync, createdAt)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_exec(Database.databaseConnection, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error beginning transaction: \(errorMsg)")
            completion(false, errorMsg)
            return
        }
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            for item in items {
                sqlite3_bind_text(statement, 1, item.assetName ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, item.assetItemImg ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, item.isSpaceAvailable ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, item.OwnerId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, item.isSync ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, item.createdAt ?? "", -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                    print("Error inserting HomeAsset: \(errorMsg)")
                    
                    sqlite3_exec(Database.databaseConnection, "ROLLBACK", nil, nil, nil)
                    completion(false, errorMsg)
                    sqlite3_finalize(statement)
                    return
                }
                
                sqlite3_reset(statement)
            }
            
            if sqlite3_exec(Database.databaseConnection, "COMMIT", nil, nil, nil) != SQLITE_OK {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error committing transaction: \(errorMsg)")
                completion(false, errorMsg)
                return
            }
            
            print("All HomeAssets inserted successfully")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getHomeAssets() -> [HomeAssetModel] {
        var resultArray = [HomeAssetModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomeAssetTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = HomeAssetModel()
                item.localId = Int(sqlite3_column_int(statement, 0))
                item.assetName = String(cString: sqlite3_column_text(statement, 1))
                item.assetItemImg = String(cString: sqlite3_column_text(statement, 2))
                item.isSpaceAvailable = String(cString: sqlite3_column_text(statement, 3))
                item.OwnerId = String(cString: sqlite3_column_text(statement, 4))
                item.isSync = String(cString: sqlite3_column_text(statement, 5))
                item.createdAt = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(item)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomeAssets.")
        }
        return resultArray
    }
    
    func getHomeAssetsWhereIsSyncZero() -> [HomeAssetModel] {
        var resultArray = [HomeAssetModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomeAssetTable WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = HomeAssetModel()
                item.localId = Int(sqlite3_column_int(statement, 0))
                item.assetName = String(cString: sqlite3_column_text(statement, 1))
                item.assetItemImg = String(cString: sqlite3_column_text(statement, 2))
                item.isSpaceAvailable = String(cString: sqlite3_column_text(statement, 3))
                item.OwnerId = String(cString: sqlite3_column_text(statement, 4))
                item.isSync = String(cString: sqlite3_column_text(statement, 5))
                item.createdAt = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(item)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomeAssets where isSync = '0'.")
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatus(forLocalId: localId)
        }
    }
    
    func updateSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE HomeAssetTable SET isSync = '1' WHERE localId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated isSync to 1 for localId: \(localId)")
            } else {
                print("Failed to update isSync for localId: \(localId)")
            }
        } else {
            print("Failed to prepare statement for updating isSync.")
        }
        sqlite3_finalize(statement)
    }
}


