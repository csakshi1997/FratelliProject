//
//  HomePOSMTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/12/24.
//

import Foundation
import SQLite3

class HomePOSMTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createHomePOSMTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS HomePOSMTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                ExternalId TEXT,
                Outlet_Name__c TEXT,
                OutletName TEXT,
                Visit__c TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating HomePOSMTable")
        }
    }
    
    func saveHomePOSM(homePOSM: HomePOSMModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO HomePOSMTable (ExternalId, Outlet_Name__c, OutletName, Visit__c, OwnerId, isSync, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, homePOSM.ExternalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, homePOSM.Outlet_Name__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, homePOSM.OutletName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, homePOSM.Visit__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, homePOSM.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, homePOSM.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, homePOSM.createdAt ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting HomePOSM: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("HomePOSM inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getHomePOSMs() -> [HomePOSMModel] {
        var resultArray = [HomePOSMModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomePOSMTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var homePOSM = HomePOSMModel()
                homePOSM.localId = Int(sqlite3_column_int(statement, 0))
                homePOSM.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                homePOSM.Outlet_Name__c = String(cString: sqlite3_column_text(statement, 2))
                homePOSM.OutletName = String(cString: sqlite3_column_text(statement, 3))
                homePOSM.Visit__c = String(cString: sqlite3_column_text(statement, 4))
                homePOSM.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                homePOSM.isSync = String(cString: sqlite3_column_text(statement, 6))
                homePOSM.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(homePOSM)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomePOSMs.")
        }
        
        return resultArray
    }
    
    func getHomePOSMsWhereIsSyncZero() -> [HomePOSMModel] {
        var resultArray = [HomePOSMModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM HomePOSMTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var homePOSM = HomePOSMModel()
                homePOSM.localId = Int(sqlite3_column_int(statement, 0))
                homePOSM.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                homePOSM.Outlet_Name__c = String(cString: sqlite3_column_text(statement, 2))
                homePOSM.OutletName = String(cString: sqlite3_column_text(statement, 3))
                homePOSM.Visit__c = String(cString: sqlite3_column_text(statement, 4))
                homePOSM.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                homePOSM.isSync = String(cString: sqlite3_column_text(statement, 6))
                homePOSM.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(homePOSM)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching HomePOSMs with isSync = '0'.")
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
        let query = "UPDATE HomePOSMTable SET isSync = '1' WHERE localId = ?"
        
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

