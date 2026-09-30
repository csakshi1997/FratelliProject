//
//  CallForHelpTable.swift
//  FRATELLI
//
//  Created by Sakshi on 22/12/24.
//

import Foundation
import SQLite3

class CallForHelpTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createCallForHelpTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS CallForHelpTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                External_Id__C TEXT,
                OutletId TEXT,
                TaskSubject TEXT,
                TaskSubtype TEXT,
                CreatedDate TEXT,
                CreatedTime TEXT,
                IsTaskRequired TEXT,
                TaskStatus TEXT,
                OwnerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating CallForHelpTable")
        }
    }
    
    func saveCallForHelp(model: CallForHelpModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO CallForHelpTable (External_Id__C, OutletId, TaskSubject, TaskSubtype, CreatedDate, CreatedTime, IsTaskRequired, TaskStatus, OwnerId, isSync, createdAt) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, model.External_Id__C ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, model.OutletId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, model.TaskSubject ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, model.TaskSubtype ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, model.CreatedDate ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, model.CreatedTime ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, model.IsTaskRequired ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, model.TaskStatus ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, model.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, model.isSync ?? "0", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, model.createdAt ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting CallForHelp: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("CallForHelp inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getCallForHelpEntries() -> [CallForHelpModel] {
        var resultArray = [CallForHelpModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM CallForHelpTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = CallForHelpModel()
                model.localId = Int(sqlite3_column_int(statement, 0))
                model.External_Id__C = String(cString: sqlite3_column_text(statement, 1))
                model.OutletId = String(cString: sqlite3_column_text(statement, 2))
                model.TaskSubject = String(cString: sqlite3_column_text(statement, 3))
                model.TaskSubtype = String(cString: sqlite3_column_text(statement, 4))
                model.CreatedDate = String(cString: sqlite3_column_text(statement, 5))
                model.CreatedTime = String(cString: sqlite3_column_text(statement, 6))
                model.IsTaskRequired = String(cString: sqlite3_column_text(statement, 7))
                model.TaskStatus = String(cString: sqlite3_column_text(statement, 8))
                model.OwnerId = String(cString: sqlite3_column_text(statement, 9))
                model.isSync = String(cString: sqlite3_column_text(statement, 10))
                model.createdAt = String(cString: sqlite3_column_text(statement, 11))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching CallForHelp entries.")
        }
        return resultArray
    }
    
    func getCallForHelpWithSyncZero() -> [CallForHelpModel] {
        var resultArray = [CallForHelpModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM CallForHelpTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var model = CallForHelpModel()
                model.localId = Int(sqlite3_column_int(statement, 0))
                model.External_Id__C = String(cString: sqlite3_column_text(statement, 1))
                model.OutletId = String(cString: sqlite3_column_text(statement, 2))
                model.TaskSubject = String(cString: sqlite3_column_text(statement, 3))
                model.TaskSubtype = String(cString: sqlite3_column_text(statement, 4))
                model.CreatedDate = String(cString: sqlite3_column_text(statement, 5))
                model.CreatedTime = String(cString: sqlite3_column_text(statement, 6))
                model.IsTaskRequired = String(cString: sqlite3_column_text(statement, 7))
                model.TaskStatus = String(cString: sqlite3_column_text(statement, 8))
                model.OwnerId = String(cString: sqlite3_column_text(statement, 9))
                model.isSync = String(cString: sqlite3_column_text(statement, 10))
                model.createdAt = String(cString: sqlite3_column_text(statement, 11))
                
                resultArray.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching CallForHelp entries with isSync = 0.")
        }
        return resultArray
    }
    
    func updateSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE CallForHelpTable SET isSync = '1' WHERE localId = ?"
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
