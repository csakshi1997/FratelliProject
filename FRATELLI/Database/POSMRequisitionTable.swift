//
//  POSMRequisitionTable.swift
//  FRATELLI
//
//  Created by Sakshi on 29/11/24.
//

import Foundation
import SQLite3

class POSMRequisitionTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createPOSMRequisitionTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS POSMRequisitionTable (
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
            print("Error creating POSMRequisitionTable")
        }
    }
    
    func savePOSMRequisition(model: POSMRequisitionModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO POSMRequisitionTable (IsActive, Label, Value, attributesType, attributesUrl, isSync) VALUES (?, ?, ?, ?, ?, ?)"
        
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
                print("Error inserting POSMRequisition: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("POSMRequisition inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    // Fetch all records from POSMRequisitionTable
    func getPOSMRequisitions() -> [POSMRequisitionModel] {
        var resultArray = [POSMRequisitionModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM POSMRequisitionTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = POSMRequisitionModel()
                
                model.localId = String(cString: sqlite3_column_text(statement, 0))
                model.IsActive = sqlite3_column_int(statement, 1) == 1
                model.Label = String(cString: sqlite3_column_text(statement, 2))
                model.Value = String(cString: sqlite3_column_text(statement, 3))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 4))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 5))
                model.attributes = POSMRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
                model.isSync = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching POSMRequisition records.")
        }
        
        return resultArray
    }
    
    // Fetch records filtered by IsActive status
    func getActivePOSMRequisitions() -> [POSMRequisitionModel] {
        var resultArray = [POSMRequisitionModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM POSMRequisitionTable WHERE IsActive = 1"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = POSMRequisitionModel()
                
                model.localId = String(cString: sqlite3_column_text(statement, 0))
                model.IsActive = sqlite3_column_int(statement, 1) == 1
                model.Label = String(cString: sqlite3_column_text(statement, 2))
                model.Value = String(cString: sqlite3_column_text(statement, 3))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 4))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 5))
                model.attributes = POSMRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
                model.isSync = String(cString: sqlite3_column_text(statement, 6))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching active POSMRequisition records.")
        }
        
        return resultArray
    }
    
}
