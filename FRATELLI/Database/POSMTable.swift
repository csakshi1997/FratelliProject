//
//  POSMTable.swift
//  FRATELLI
//
//  Created by Sakshi on 19/12/24.
//

import Foundation
import SQLite3

class POSMTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createPOSMTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS POSMTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                ExternalId TEXT,
                outerName TEXT,
                outerId TEXT,
                Visit__c TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating POSMTable")
        }
        Database.alterTable(tableName: "POSMTable", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""]
        ])
    }
    
    func savePOSM(posm: POSMModel, completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
            INSERT INTO POSMTable (ExternalId, outerName, outerId, Visit__c, OwnerId, isSync, createdAt, Visit_Date_c, Visit_Order_c)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, posm.ExternalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, posm.outerName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, posm.outerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, posm.Visit__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, posm.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, posm.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, posm.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, posm.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, posm.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting POSM: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("POSM inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getPOSMs() -> [POSMModel] {
        var resultArray = [POSMModel]()
        let query = "SELECT * FROM POSMTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var posm = POSMModel()
                posm.localId = Int(sqlite3_column_int(statement, 0))
                posm.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                posm.outerName = String(cString: sqlite3_column_text(statement, 2))
                posm.outerId = String(cString: sqlite3_column_text(statement, 3))
                posm.Visit__c = String(cString: sqlite3_column_text(statement, 4))
                posm.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                posm.isSync = String(cString: sqlite3_column_text(statement, 6))
                posm.createdAt = String(cString: sqlite3_column_text(statement, 7))
                posm.Visit_Date_c = String(cString: sqlite3_column_text(statement, 8))
                posm.Visit_Order_c = String(cString: sqlite3_column_text(statement, 9))
                
                resultArray.append(posm)
            }
        } else {
            print("Failed to prepare statement for fetching POSMs.")
        }
        sqlite3_finalize(statement)
        return resultArray
    }
    
    func getPOSMsWhereIsSyncZero() -> [POSMModel] {
        var resultArray = [POSMModel]()
        let query = "SELECT * FROM POSMTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var posm = POSMModel()
                posm.localId = Int(sqlite3_column_int(statement, 0))
                posm.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                posm.outerName = String(cString: sqlite3_column_text(statement, 2))
                posm.outerId = String(cString: sqlite3_column_text(statement, 3))
                posm.Visit__c = String(cString: sqlite3_column_text(statement, 4))
                posm.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                posm.isSync = String(cString: sqlite3_column_text(statement, 6))
                posm.createdAt = String(cString: sqlite3_column_text(statement, 7))
                posm.Visit_Date_c = String(cString: sqlite3_column_text(statement, 8))
                posm.Visit_Order_c = String(cString: sqlite3_column_text(statement, 9))
                resultArray.append(posm)
            }
        } else {
            print("Failed to prepare statement for fetching unsynced POSMs.")
        }
        sqlite3_finalize(statement)
        return resultArray
    }
    
    func updateSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatus(forLocalId: localId)
        }
    }
    
    func updateSyncStatus(forLocalId localId: Int) {
        let query = "UPDATE POSMTable SET isSync = '1' WHERE localId = ?"
        
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
