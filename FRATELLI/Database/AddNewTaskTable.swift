//
//  AddNewTaskTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/12/24.
//

import Foundation
import SQLite3

class AddNewTaskTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createAddNewTaskTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS AddNewTaskTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                Id TEXT,
                priority TEXT,
                Settlement_Data__c TEXT,
                whatId TEXT,
                External_Id__c TEXT,
                OutletId TEXT,
                TaskSubject TEXT,
                TaskSubtype TEXT,
                IsTaskRequired TEXT,
                TaskStatus TEXT,
                OwnerId TEXT,
                CreatedTime TEXT,
                CreatedDate TEXT,
                createdAt TEXT,
                isSync TEXT,
                attributesType TEXT,
                attributesUrl TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating AddNewTaskTable")
        }
        
        Database.alterTable(tableName: "AddNewTaskTable", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""]
        ])
    }
    
    func saveTasks(tasks: [AddNewTaskModel], completion: @escaping (Bool, [String]?) -> Void) {
        var failedTasks: [String] = []
        var successCount = 0
        
        let insertQuery = """
            INSERT INTO AddNewTaskTable (Id, priority, Settlement_Data__c, whatId, External_Id__c, OutletId, TaskSubject, TaskSubtype, IsTaskRequired,
            TaskStatus, OwnerId, Visit_Date_c, Visit_Order_c, CreatedTime, CreatedDate, createdAt, isSync, attributesType, attributesUrl)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_exec(Database.databaseConnection, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            completion(false, ["Failed to begin transaction: \(errorMsg)"])
            return
        }
        
        for task in tasks {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, task.Id ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, task.priority ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, task.Settlement_Data__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, task.whatId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, task.External_Id__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, task.OutletId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, task.TaskSubject ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, task.TaskSubtype ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, task.IsTaskRequired ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, task.TaskStatus ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, task.OwnerId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 12, task.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, task.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 14, task.CreatedTime ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, task.CreatedDate ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 16, task.createdAt ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 17, task.isSync ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 18, task.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 19, task.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                    failedTasks.append("Task ID \(task.External_Id__c ?? "unknown"): \(errorMsg)")
                } else {
                    successCount += 1
                }
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                failedTasks.append("Task ID \(task.External_Id__c ?? "unknown"): Failed to prepare statement: \(errorMsg)")
            }
            sqlite3_finalize(statement)
        }
        
        if failedTasks.isEmpty {
            if sqlite3_exec(Database.databaseConnection, "COMMIT", nil, nil, nil) == SQLITE_OK {
                completion(true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                completion(false, ["Failed to commit transaction: \(errorMsg)"])
            }
        } else {
            sqlite3_exec(Database.databaseConnection, "ROLLBACK", nil, nil, nil) // Some tasks failed
        }
    }
    
    func saveTasksFromSalesForce(task: AddNewTaskModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO AddNewTaskTable (Id, priority, Settlement_Data__c, whatId, External_Id__c, OutletId, TaskSubject, TaskSubtype, IsTaskRequired, TaskStatus, OwnerId, Visit_Date_c, Visit_Order_c, CreatedTime, CreatedDate, createdAt, isSync, attributesType, attributesUrl) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, task.Id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, task.priority ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, task.Settlement_Data__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, task.whatId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, task.External_Id__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, task.OutletId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, task.TaskSubject ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, task.TaskSubtype ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, task.IsTaskRequired ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, task.TaskStatus ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, task.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, task.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, task.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, task.CreatedTime ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, task.CreatedDate ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, task.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, task.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, task.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, task.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting contact: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Contact inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getTasks() -> [AddNewTaskModel] {
        var tasks = [AddNewTaskModel]()
        let query = "SELECT * FROM AddNewTaskTable"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var task = AddNewTaskModel()
                task.localId = Int(sqlite3_column_int(statement, 0))
                task.Id = String(cString: sqlite3_column_text(statement, 1))
                task.priority = String(cString: sqlite3_column_text(statement, 2))
                task.Settlement_Data__c = String(cString: sqlite3_column_text(statement, 3))
                task.whatId = String(cString: sqlite3_column_text(statement, 4))
                task.External_Id__c = String(cString: sqlite3_column_text(statement, 5))
                task.OutletId = String(cString: sqlite3_column_text(statement, 6))
                task.TaskSubject = String(cString: sqlite3_column_text(statement, 7))
                task.TaskSubtype = String(cString: sqlite3_column_text(statement, 8))
                task.IsTaskRequired = String(cString: sqlite3_column_text(statement, 9))
                task.TaskStatus = String(cString: sqlite3_column_text(statement, 10))
                task.OwnerId = String(cString: sqlite3_column_text(statement, 11))
                task.CreatedTime = String(cString: sqlite3_column_text(statement, 12))
                task.CreatedDate = String(cString: sqlite3_column_text(statement, 13))
                task.createdAt = String(cString: sqlite3_column_text(statement, 14))
                task.isSync = String(cString: sqlite3_column_text(statement, 15))
                let attributesType = String(cString: sqlite3_column_text(statement, 16))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 17))
                task.Visit_Date_c = String(cString: sqlite3_column_text(statement, 18))
                task.Visit_Order_c = String(cString: sqlite3_column_text(statement, 19))
                task.attributes = AddNewTaskModel.Attributes(type: attributesType, url: attributesUrl)
                tasks.append(task)
            }
        } else {
            print("Failed to fetch tasks.")
        }
        sqlite3_finalize(statement)
        return tasks
    }
    
    func getTasksAccordingToWhatId(forWhatId whatId: String) -> [AddNewTaskModel] {
        var resultArray = [AddNewTaskModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AddNewTaskTable WHERE whatId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, whatId, -1, SQLITE_TRANSIENT)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                var task = AddNewTaskModel()
                task.localId = Int(sqlite3_column_int(statement, 0))
                task.Id = String(cString: sqlite3_column_text(statement, 1))
                task.priority = String(cString: sqlite3_column_text(statement, 2))
                task.Settlement_Data__c = String(cString: sqlite3_column_text(statement, 3))
                task.whatId = String(cString: sqlite3_column_text(statement, 4))
                task.External_Id__c = String(cString: sqlite3_column_text(statement, 5))
                task.OutletId = String(cString: sqlite3_column_text(statement, 6))
                task.TaskSubject = String(cString: sqlite3_column_text(statement, 7))
                task.TaskSubtype = String(cString: sqlite3_column_text(statement, 8))
                task.IsTaskRequired = String(cString: sqlite3_column_text(statement, 9))
                task.TaskStatus = String(cString: sqlite3_column_text(statement, 10))
                task.OwnerId = String(cString: sqlite3_column_text(statement, 11))
                task.CreatedTime = String(cString: sqlite3_column_text(statement, 12))
                task.CreatedDate = String(cString: sqlite3_column_text(statement, 13))
                task.createdAt = String(cString: sqlite3_column_text(statement, 14))
                task.isSync = String(cString: sqlite3_column_text(statement, 15))
                let attributesType = String(cString: sqlite3_column_text(statement, 16))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 17))
                task.Visit_Date_c = String(cString: sqlite3_column_text(statement, 18))
                task.Visit_Order_c = String(cString: sqlite3_column_text(statement, 19))
                task.attributes = AddNewTaskModel.Attributes(type: attributesType, url: attributesUrl)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching contacts based on accountId.")
        }
        
        return resultArray
    }
    
    func getTasksWhereIsSyncZero() -> [AddNewTaskModel] {
        var resultArray = [AddNewTaskModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AddNewTaskTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var task = AddNewTaskModel()
                task.localId = Int(sqlite3_column_int(statement, 0))
                task.Id = String(cString: sqlite3_column_text(statement, 1))
                task.priority = String(cString: sqlite3_column_text(statement, 2))
                task.Settlement_Data__c = String(cString: sqlite3_column_text(statement, 3))
                task.whatId = String(cString: sqlite3_column_text(statement, 4))
                task.External_Id__c = String(cString: sqlite3_column_text(statement, 5))
                task.OutletId = String(cString: sqlite3_column_text(statement, 6))
                task.TaskSubject = String(cString: sqlite3_column_text(statement, 7))
                task.TaskSubtype = String(cString: sqlite3_column_text(statement, 8))
                task.IsTaskRequired = String(cString: sqlite3_column_text(statement, 9))
                task.TaskStatus = String(cString: sqlite3_column_text(statement, 10))
                task.OwnerId = String(cString: sqlite3_column_text(statement, 11))
                task.CreatedTime = String(cString: sqlite3_column_text(statement, 12))
                task.CreatedDate = String(cString: sqlite3_column_text(statement, 13))
                task.createdAt = String(cString: sqlite3_column_text(statement, 14))
                task.isSync = String(cString: sqlite3_column_text(statement, 15))
                let attributesType = String(cString: sqlite3_column_text(statement, 16))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 17))
                task.Visit_Date_c = String(cString: sqlite3_column_text(statement, 18))
                task.Visit_Order_c = String(cString: sqlite3_column_text(statement, 19))
                task.attributes = AddNewTaskModel.Attributes(type: attributesType, url: attributesUrl)
                
                resultArray.append(task)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching tasks with isSync = '0'.")
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleTaskIds(localIds: [Int]) {
        for localId in localIds {
            updateTaskSyncStatus(forLocalId: localId)
        }
    }
    
    func updateTaskSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE AddNewTaskTable SET isSync = '1' WHERE localId = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated isSync to '1' for localId: \(localId)")
            } else {
                print("Failed to update isSync for localId: \(localId)")
            }
        } else {
            print("Failed to prepare statement for updating isSync.")
        }
        sqlite3_finalize(statement)
    }
}
