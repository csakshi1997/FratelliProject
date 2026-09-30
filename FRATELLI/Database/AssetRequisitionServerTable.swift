//
//  AssetRequisitionServerTable.swift
//  FRATELLI
//
//  Created by Sakshi on 26/06/25.
//

import Foundation
import SQLite3

class AssetRequisitionServerTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createVisibilityServerTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS AssetRequisitionServerTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                userId TEXT,
                fileType TEXT,
                fileName TEXT,
                isSync TEXT,
                createdAt TEXT,
                assetName TEXT,
                externalId TEXT,
                dealerDistributorCorpId TEXT,
                deviceName TEXT,
                deviceVersion TEXT,
                deviceType TEXT,
                visitOrderId TEXT,
                imagePublicUrl TEXT
            );
        """
        
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating AssetRequisitionServerTable")
        } else {
            print("✅ AssetRequisitionServerTable created or already exists.")
        }
    }
    
    func saveRecord(_ record: AssetRequisitionServerModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO AssetRequisitionServerTable (
                userId, fileType, fileName, isSync, createdAt,
                assetName, externalId, dealerDistributorCorpId,
                deviceName, deviceVersion, deviceType,
                visitOrderId, imagePublicUrl
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, record.userId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, record.fileType ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, record.fileName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, record.isSync ?? "0", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, record.createdAt, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, record.assetName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, record.externalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, record.dealerDistributorCorpId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, record.deviceName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, record.deviceVersion ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, record.deviceType ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, record.visitOrderId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, record.imagePublicUrl ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("❌ Insert failed: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("✅ Record inserted for file: \(record.fileName ?? "-")")
                completion(true, nil)
            }
            
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("❌ Prepare failed: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getAllRecords() -> [AssetRequisitionServerModel] {
        var results: [AssetRequisitionServerModel] = []
        var statement: OpaquePointer?
        let query = "SELECT * FROM AssetRequisitionServerTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let userId = String(cString: sqlite3_column_text(statement, 1))
                let fileType = String(cString: sqlite3_column_text(statement, 2))
                let fileName = String(cString: sqlite3_column_text(statement, 3))
                let isSync = String(cString: sqlite3_column_text(statement, 4))
                let createdAt = String(cString: sqlite3_column_text(statement, 5))
                let assetName = String(cString: sqlite3_column_text(statement, 6))
                let externalId = String(cString: sqlite3_column_text(statement, 7))
                let dealerDistributorCorpId = String(cString: sqlite3_column_text(statement, 8))
                let deviceName = String(cString: sqlite3_column_text(statement, 9))
                let deviceVersion = String(cString: sqlite3_column_text(statement, 10))
                let deviceType = String(cString: sqlite3_column_text(statement, 11))
                let visitOrderId = String(cString: sqlite3_column_text(statement, 12))
                let imagePublicUrl = String(cString: sqlite3_column_text(statement, 13))
                
                let record = AssetRequisitionServerModel(
                    localId: localId,
                    userId: userId,
                    fileType: fileType,
                    fileName: fileName,
                    isSync: isSync,
                    createdAt: createdAt,
                    externalId: externalId
                )
                results.append(record)
            }
            sqlite3_finalize(statement)
        } else {
            print("❌ Failed to prepare SELECT statement.")
        }
        
        return results
    }
    
    func getUnsyncedRecords() -> [AssetRequisitionServerModel] {
        var results: [AssetRequisitionServerModel] = []
        var statement: OpaquePointer?
        let query = "SELECT * FROM AssetRequisitionServerTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let userId = String(cString: sqlite3_column_text(statement, 1))
                let fileType = String(cString: sqlite3_column_text(statement, 2))
                let fileName = String(cString: sqlite3_column_text(statement, 3))
                let isSync = String(cString: sqlite3_column_text(statement, 4))
                let createdAt = String(cString: sqlite3_column_text(statement, 5))
                
                let record = AssetRequisitionServerModel(
                    localId: localId,
                    userId: userId,
                    fileType: fileType,
                    fileName: fileName,
                    isSync: isSync,
                    createdAt: createdAt
                )
                results.append(record)
            }
            sqlite3_finalize(statement)
        } else {
            print("❌ Failed to fetch unsynced AssetRequisitionServerTable records.")
        }
        
        return results
    }
    
    func updateSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE AssetRequisitionServerTable SET isSync = '1' WHERE localId = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ isSync updated to 1 for localId: \(localId)")
            } else {
                print("❌ Failed to update isSync for localId: \(localId)")
            }
        } else {
            print("❌ Failed to prepare update statement.")
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateSyncStatusForMultipleIds(localIds: [Int]) {
        for id in localIds {
            updateSyncStatus(forLocalId: id)
        }
    }
    
    func updatePublicURL(forLocalId localId: Int, url: String) {
        var statement: OpaquePointer?
        let updateQuery = "UPDATE AssetRequisitionServerTable SET imagePublicUrl = ? WHERE localId = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, url, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, Int32(localId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ imagePublicUrl updated for localId: \(localId)")
            } else {
                print("❌ Failed to update imagePublicUrl for localId: \(localId)")
            }
        } else {
            print("❌ Failed to prepare updatePublicURL statement.")
        }
        
        sqlite3_finalize(statement)
    }
}

