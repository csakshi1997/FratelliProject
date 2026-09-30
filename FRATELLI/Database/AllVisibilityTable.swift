//
//  AllVisibilityTable.swift
//  FRATELLI
//
//  Created by Sakshi on 19/12/24.
//

import Foundation
import SQLite3

class AllVisibilityTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createAllVisibilityTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS AllVisibilityTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                externalId TEXT,
                outletId TEXT,
                assetName TEXT,
                addRemark TEXT,
                assetItemImg TEXT,
                isPresent TEXT,
                isMaintenance TEXT,
                isSync TEXT,
                hexString TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating AllVisibilityTable")
        }
    }
    
    func saveVisibility(models: [AllVisibilityModel], completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
            INSERT INTO AllVisibilityTable (externalId, outletId, assetName, addRemark, assetItemImg, isPresent, isMaintenance, isSync, hexString, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        var successCount = 0
        for model in models {
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, model.External_Id__c, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, model.outletId, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, model.assetName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, model.addRemark, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, model.assetItemImg, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, model.isPresent, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, model.isMaintenance, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, model.isSync, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, model.hexString, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, model.createdAt, -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    successCount += 1
                } else {
                    let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                    print("Error inserting data: \(errorMsg)")
                    completion(false, errorMsg)
                    sqlite3_finalize(statement)
                    return
                }
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error preparing statement: \(errorMsg)")
                completion(false, errorMsg)
                sqlite3_finalize(statement)
                return
            }
            
            sqlite3_finalize(statement)
        }
        
        if successCount == models.count {
            completion(true, nil)
        } else {
            completion(false, "Failed to insert all records.")
        }
    }
    
    func getAllVisibilityRecords() -> [AllVisibilityModel] {
        var resultArray = [AllVisibilityModel]()
        let query = "SELECT * FROM AllVisibilityTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let model = AllVisibilityModel(
                    LocalId: Int(sqlite3_column_int(statement, 0)),
                    External_Id__c: String(cString: sqlite3_column_text(statement, 1)),
                    outletId: String(cString: sqlite3_column_text(statement, 2)),
                    assetName: String(cString: sqlite3_column_text(statement, 3)),
                    addRemark: String(cString: sqlite3_column_text(statement, 4)),
                    assetItemImg: String(cString: sqlite3_column_text(statement, 5)),
                    isPresent: String(cString: sqlite3_column_text(statement, 6)),
                    isMaintenance: String(cString: sqlite3_column_text(statement, 7)),
                    isSync: String(cString: sqlite3_column_text(statement, 8)),
                    hexString: String(cString: sqlite3_column_text(statement, 9)),
                    createdAt: String(cString: sqlite3_column_text(statement, 10))
                )
                resultArray.append(model)
            }
        } else {
            print("Failed to prepare query for fetching records.")
        }
        sqlite3_finalize(statement)
        return resultArray
    }
    
    func getAllVisibilityItemsWhereIsSyncZero() -> [AllVisibilityModel] {
        var resultArray = [AllVisibilityModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AllVisibilityTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var visibilityItem = AllVisibilityModel()
                visibilityItem.LocalId = Int(sqlite3_column_int(statement, 0))
                visibilityItem.External_Id__c = String(cString: sqlite3_column_text(statement, 1))
                visibilityItem.outletId = String(cString: sqlite3_column_text(statement, 2))
                visibilityItem.assetName = String(cString: sqlite3_column_text(statement, 3))
                visibilityItem.addRemark = String(cString: sqlite3_column_text(statement, 4))
                visibilityItem.assetItemImg = String(cString: sqlite3_column_text(statement, 5))
                visibilityItem.isPresent = String(cString: sqlite3_column_text(statement, 6))
                visibilityItem.isMaintenance = String(cString: sqlite3_column_text(statement, 7))
                visibilityItem.isSync = String(cString: sqlite3_column_text(statement, 8))
                visibilityItem.hexString = String(cString: sqlite3_column_text(statement, 9))
                visibilityItem.createdAt = String(cString: sqlite3_column_text(statement, 10))
                
                resultArray.append(visibilityItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching unsynced AllVisibility items.")
        }
        
        return resultArray
    }
    
//    func updateSyncStatusForMultipleAllVisibilityItems(localIds: [Int]) {
//        for localId in localIds {
//            updateSyncStatusForAllVisibilityItem(localId: localId)
//        }
//    }
//    
//    func updateSyncStatusForAllVisibilityItem(localId: Int) {
//        var statement: OpaquePointer?
//        let query = "UPDATE AllVisibilityTable SET isSync = '1' WHERE LocalId = ?"
//        
//        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_int(statement, 1, Int32(localId))
//            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Successfully updated isSync to 1 for AllVisibilityTable for LocalId: \(localId)")
//            } else {
//                print("Failed to update isSync for LocalId: \(localId)")
//            }
//        } else {
//            print("Failed to prepare statement for updating isSync.")
//        }
//        
//        sqlite3_finalize(statement)
//    }
    
    func updateSyncStatusForAllVisibilityItem(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE AllVisibilityTable SET isSync = '1' WHERE LocalId = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Successfully updated isSync = 1 for LocalId: \(localId)")
            } else {
                print("❌ Failed to update isSync for LocalId: \(localId)")
            }
        } else {
            print("❌ Failed to prepare update statement for LocalId: \(localId)")
        }
        
        sqlite3_finalize(statement)
    }
}

