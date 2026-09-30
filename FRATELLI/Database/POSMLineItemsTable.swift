//
//  POSMLineItemsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 19/12/24.
//

import Foundation
import SQLite3

class POSMLineItemsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createPOSMLineItemsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS POSMLineItemTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                ExternalId TEXT,
                PosmItemId TEXT,
                POSM_Asset_name__c TEXT,
                Quantity__c TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating POSMLineItemTable")
        }
    }
    
    func savePOSMLineItem(posmLineItem: POSMLineItemsModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO POSMLineItemTable 
            (ExternalId, PosmItemId, POSM_Asset_name__c, Quantity__c, OwnerId, isSync, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, posmLineItem.ExternalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, posmLineItem.PosmItemId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, posmLineItem.POSM_Asset_name__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, posmLineItem.Quantity__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, posmLineItem.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, posmLineItem.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, posmLineItem.createdAt ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting POSMLineItem: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("POSMLineItem inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getPOSMLineItems() -> [POSMLineItemsModel] {
        var resultArray = [POSMLineItemsModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM POSMLineItemTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var posmLineItem = POSMLineItemsModel()
                posmLineItem.localId = Int(sqlite3_column_int(statement, 0))
                posmLineItem.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                posmLineItem.PosmItemId = String(cString: sqlite3_column_text(statement, 2))
                posmLineItem.POSM_Asset_name__c = String(cString: sqlite3_column_text(statement, 3))
                posmLineItem.Quantity__c = String(cString: sqlite3_column_text(statement, 4))
                posmLineItem.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                posmLineItem.isSync = String(cString: sqlite3_column_text(statement, 6))
                posmLineItem.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(posmLineItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching POSMLineItems.")
        }
        
        return resultArray
    }
    
    func getPOSMLineItemsWhereIsSyncZero() -> [POSMLineItemsModel] {
        var resultArray = [POSMLineItemsModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM POSMLineItemTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var posmLineItem = POSMLineItemsModel()
                posmLineItem.localId = Int(sqlite3_column_int(statement, 0))
                posmLineItem.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                posmLineItem.PosmItemId = String(cString: sqlite3_column_text(statement, 2))
                posmLineItem.POSM_Asset_name__c = String(cString: sqlite3_column_text(statement, 3))
                posmLineItem.Quantity__c = String(cString: sqlite3_column_text(statement, 4))
                posmLineItem.OwnerId = String(cString: sqlite3_column_text(statement, 5))
                posmLineItem.isSync = String(cString: sqlite3_column_text(statement, 6))
                posmLineItem.createdAt = String(cString: sqlite3_column_text(statement, 7))
                
                resultArray.append(posmLineItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching unsynced POSMLineItems.")
        }
        
        return resultArray
    }
    
    func updateSyncStatusForPOSMLineItem(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE POSMLineItemTable SET isSync = '1' WHERE localId = ?"
        
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
    
    func updateSyncStatusForMultiplePOSMLineItems(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatusForPOSMLineItem(localId: localId)
        }
    }
}

