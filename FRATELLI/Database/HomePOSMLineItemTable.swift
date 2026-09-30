//
//  HomePOSMLineItemTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/12/24.
//

import Foundation
import SQLite3

class HomePOSMLineItemTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createHomePOSMLineItemTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS HomePOSMLineItemTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                External_Id__C TEXT,
                PosmItemId TEXT,
                POSM_Asset_name__c TEXT,
                Quantity__c TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating HomePOSMLineItemTable")
        }
    }
    
    func saveHomePOSMLineItems(items: [HomePOSMLineItemModel], completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
            INSERT INTO HomePOSMLineItemTable (External_Id__C, PosmItemId, POSM_Asset_name__c, Quantity__c, OwnerId, isSync, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?)
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
                sqlite3_bind_text(statement, 1, item.External_Id__C ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, item.PosmItemId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, item.POSM_Asset_name__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, "\(item.Quantity__c ?? "0")", -1, SQLITE_TRANSIENT) // Convert Int to String
                sqlite3_bind_text(statement, 5, item.OwnerId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, item.isSync ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, item.createdAt ?? "", -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                    print("Error inserting HomePOSMLineItem: \(errorMsg)")
                    
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
            
            print("All HomePOSMLineItems inserted successfully")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getHomePOSMLineItems() -> [HomePOSMLineItemModel] {
        var resultArray = [HomePOSMLineItemModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomePOSMLineItemTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = HomePOSMLineItemModel()
                item.localId = Int(sqlite3_column_int(statement, 0))
                item.External_Id__C = String(cString: sqlite3_column_text(statement, 1))
                item.PosmItemId = String(cString: sqlite3_column_text(statement, 2))
                item.POSM_Asset_name__c = String(cString: sqlite3_column_text(statement, 3))
                item.Quantity__c = String(cString: sqlite3_column_text(statement, 4))
                item.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                item.isSync = String(cString: sqlite3_column_text(statement, 6))
                item.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(item)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomePOSMLineItems.")
        }
        
        return resultArray
    }
    
    func getHomePOSMLineItemsWhereIsSyncZero() -> [HomePOSMLineItemModel] {
        var resultArray = [HomePOSMLineItemModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomePOSMLineItemTable WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = HomePOSMLineItemModel()
                item.localId = Int(sqlite3_column_int(statement, 0))
                item.External_Id__C = String(cString: sqlite3_column_text(statement, 1))
                item.PosmItemId = String(cString: sqlite3_column_text(statement, 2))
                item.POSM_Asset_name__c = String(cString: sqlite3_column_text(statement, 3))
                item.Quantity__c = String(cString: sqlite3_column_text(statement, 4))
                item.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                item.isSync = String(cString: sqlite3_column_text(statement, 6))
                item.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(item)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomePOSMLineItems where isSync = '0'.")
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
        let query = "UPDATE HomePOSMLineItemTable SET isSync = '1' WHERE localId = ?"
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
