//
//  SkipTable.swift
//  FRATELLI
//
//  Created by Sakshi on 05/02/25.
//

import Foundation
import SQLite3

class SkipTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createSkipTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS SkipTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                accountId TEXT,
                accountReferenceClassification TEXT,
                accountReferenceId TEXT,
                accountReferenceName TEXT,
                accountReferenceOwnerId TEXT,
                accountReferenceSubChannel TEXT,
                Visit_Order__c TEXT,
                Dealer_Distributor_CORP__c TEXT,
                OwnerId TEXT,
                Meet_Greet__c TEXT,
                Risk_Stock__c TEXT,
                Asset_Visibility__c TEXT,
                POSM_Request__c TEXT,
                Sales_Order__c TEXT,
                QCR__c TEXT,
                Follow_up_task__c TEXT,
                isNew TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating SkipTable")
        }
        
        Database.alterTable(tableName: "SkipTable", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""]
        ])
    }
    
    func saveSkipEntry(skip: SkipModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO SkipTable (accountId, accountReferenceId, accountReferenceClassification, accountReferenceName,
            accountReferenceOwnerId, accountReferenceSubChannel, Visit_Order__c, Dealer_Distributor_CORP__c, OwnerId, Meet_Greet__c, Risk_Stock__c, Asset_Visibility__c, POSM_Request__c, Sales_Order__c, QCR__c, Follow_up_task__c, isNew, attributesType, attributesUrl, isSync, Visit_Date_c, Visit_Order_c) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, skip.accountId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, skip.accountReference?.id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, skip.accountReference?.classification ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, skip.accountReference?.name ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, skip.accountReference?.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, skip.accountReference?.subChannel ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, skip.Visit_Order__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, skip.Dealer_Distributor_CORP__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, skip.OwnerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, skip.Meet_Greet__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, skip.Risk_Stock__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, skip.Asset_Visibility__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, skip.POSM_Request__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, skip.Sales_Order__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, skip.QCR__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, skip.Follow_up_task__c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, skip.isNew, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, skip.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, skip.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, skip.isSync, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 21, skip.Visit_Date_c, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 22, skip.Visit_Order__c, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting skip entry: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Skip entry inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getSkipEntries() -> [SkipModel] {
        var statement: OpaquePointer?
        let query = "SELECT * FROM SkipTable"
        
        var skipList: [SkipModel] = []
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let accountId = String(cString: sqlite3_column_text(statement, 1))
                let accountReferenceId = String(cString: sqlite3_column_text(statement, 2))
                let accountReferenceClassification = String(cString: sqlite3_column_text(statement, 3))
                let accountReferenceName = String(cString: sqlite3_column_text(statement, 4))
                let accountReferenceOwnerId = String(cString: sqlite3_column_text(statement, 5))
                let accountReferenceSubChannel = String(cString: sqlite3_column_text(statement, 6))
                let visitOrder = String(cString: sqlite3_column_text(statement, 7))
                let dealerDistributor = String(cString: sqlite3_column_text(statement, 8))
                let ownerId = String(cString: sqlite3_column_text(statement, 9))
                let meetGreet = String(cString: sqlite3_column_text(statement, 10))
                let riskStock = String(cString: sqlite3_column_text(statement, 11))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 12))
                let posmRequest = String(cString: sqlite3_column_text(statement, 13))
                let salesOrder = String(cString: sqlite3_column_text(statement, 14))
                let qcr = String(cString: sqlite3_column_text(statement, 15))
                let Follow_up_task__c = String(cString: sqlite3_column_text(statement, 16))
                let isNew = String(cString: sqlite3_column_text(statement, 17))
                let attributesType = String(cString: sqlite3_column_text(statement, 18))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 19))
                let isSync = String(cString: sqlite3_column_text(statement, 20))
                let visit_Date = String(cString: sqlite3_column_text(statement, 21))
                let visit_Order = String(cString: sqlite3_column_text(statement, 22))
                
                let attributes = SkipModel.Attributes(type: attributesType, url: attributesUrl)
                let accounts = SkipModel.Account(classification: accountReferenceClassification, id: accountReferenceId, name: accountReferenceName, ownerId: accountReferenceOwnerId, subChannel: accountReferenceSubChannel)
                let skip = SkipModel(localId: localId, accountId: accountId, accountReference: accounts, Visit_Order__c: visitOrder, Dealer_Distributor_CORP__c: dealerDistributor, OwnerId: ownerId, Meet_Greet__c: meetGreet, Risk_Stock__c: riskStock, Asset_Visibility__c: assetVisibility, POSM_Request__c: posmRequest, Sales_Order__c: salesOrder, QCR__c: qcr, Follow_up_task__c: Follow_up_task__c, isNew: isNew, attributes: attributes, isSync: isSync, Visit_Date_c: visit_Date, Visit_Order_c: visit_Order)
                
                skipList.append(skip)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching skip.")
        }
        
        return skipList
    }
    
    func isVisitOrderExist(visitOrderId: String, completion: @escaping (Bool) -> Void) {
        var statement: OpaquePointer?
        let query = "SELECT COUNT(*) FROM SkipTable WHERE Visit_Order__c = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, visitOrderId, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let count = sqlite3_column_int(statement, 0)
                completion(count > 0) // Return true if count > 0 (record exists)
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
        sqlite3_finalize(statement)
    }
    
    func updateSkipEntryByVisitOrder(skip: SkipModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET accountId = ?, 
                accountReferenceClassification = ?, 
                accountReferenceId = ?, 
                accountReferenceName = ?, 
                accountReferenceOwnerId = ?, 
                accountReferenceSubChannel = ?, 
                Dealer_Distributor_CORP__c = ?, 
                OwnerId = ?, 
                Meet_Greet__c = ?, 
                Risk_Stock__c = ?, 
                Asset_Visibility__c = ?, 
                POSM_Request__c = ?, 
                Sales_Order__c = ?, 
                QCR__c = ?, 
                Follow_up_task__c = ?, 
                isNew = ?, 
                attributesType = ?, 
                attributesUrl = ?, 
                isSync = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, skip.accountId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, skip.accountReference?.classification ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, skip.accountReference?.id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, skip.accountReference?.name ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, skip.accountReference?.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, skip.accountReference?.subChannel ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, skip.Dealer_Distributor_CORP__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, skip.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, skip.Meet_Greet__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, skip.Risk_Stock__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, skip.Asset_Visibility__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, skip.POSM_Request__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, skip.Sales_Order__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, skip.QCR__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, skip.Follow_up_task__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, skip.isNew ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, skip.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, skip.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, skip.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, skip.Visit_Order__c ?? "", -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating skip entry: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Skip entry updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateMeetGreetByVisitOrder(visitOrderId: String, meetGreet: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET Meet_Greet__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, meetGreet, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating Meet_Greet__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Meet_Greet__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateRiskStockByVisitOrder(visitOrderId: String, riskStock: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET Risk_Stock__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, riskStock, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating Risk_Stock__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Risk_Stock__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateAssetVisibilityByVisitOrder(visitOrderId: String, assetVisibility: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET Asset_Visibility__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, assetVisibility, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating Asset_Visibility__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Asset_Visibility__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updatePOSMRequestVisibilityByVisitOrder(visitOrderId: String, posmRequestVisibility: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET POSM_Request__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, posmRequestVisibility, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating POSM_Visibility__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("POSM_Visibility__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateSalesOrderVisibilityByVisitOrder(visitOrderId: String, salesOrderVisibility: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET Sales_Order__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, salesOrderVisibility, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating Sales_Order_Visibility__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Sales_Order_Visibility__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateQCRVisibilityByVisitOrder(visitOrderId: String, qcrVisibility: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET QCR__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, qcrVisibility, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating QCR_Visibility__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("QCR_Visibility__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateForAddNewTask(visitOrderId: String, addNewTask: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let updateQuery = """
            UPDATE SkipTable 
            SET Follow_up_task__c = ? 
            WHERE Visit_Order__c = ?
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, addNewTask, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visitOrderId, -1, SQLITE_TRANSIENT)  // Condition for update
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error updating QCR_Visibility__c: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("QCR_Visibility__c updated successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getSkipEntriesWhereIsSyncZero() -> [SkipModel] {
        var resultArray = [SkipModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM SkipTable WHERE isSync = '0'"
        
        var skipList: [SkipModel] = []
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let accountId = String(cString: sqlite3_column_text(statement, 1))
                let accountReferenceId = String(cString: sqlite3_column_text(statement, 2))
                let accountReferenceClassification = String(cString: sqlite3_column_text(statement, 3))
                let accountReferenceName = String(cString: sqlite3_column_text(statement, 4))
                let accountReferenceOwnerId = String(cString: sqlite3_column_text(statement, 5))
                let accountReferenceSubChannel = String(cString: sqlite3_column_text(statement, 6))
                let visitOrder = String(cString: sqlite3_column_text(statement, 7))
                let dealerDistributor = String(cString: sqlite3_column_text(statement, 8))
                let ownerId = String(cString: sqlite3_column_text(statement, 9))
                let meetGreet = String(cString: sqlite3_column_text(statement, 10))
                let riskStock = String(cString: sqlite3_column_text(statement, 11))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 12))
                let posmRequest = String(cString: sqlite3_column_text(statement, 13))
                let salesOrder = String(cString: sqlite3_column_text(statement, 14))
                let qcr = String(cString: sqlite3_column_text(statement, 15))
                let Follow_up_task__c = String(cString: sqlite3_column_text(statement, 16))
                let isNew = String(cString: sqlite3_column_text(statement, 17))
                let attributesType = String(cString: sqlite3_column_text(statement, 18))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 19))
                let isSync = String(cString: sqlite3_column_text(statement, 20))
                let visit_Date = String(cString: sqlite3_column_text(statement, 21))
                let visit_Order = String(cString: sqlite3_column_text(statement, 22))
                
                let attributes = SkipModel.Attributes(type: attributesType, url: attributesUrl)
                let accounts = SkipModel.Account(classification: accountReferenceClassification, id: accountReferenceId, name: accountReferenceName, ownerId: accountReferenceOwnerId, subChannel: accountReferenceSubChannel)
                let skip = SkipModel(localId: localId, accountId: accountId, accountReference: accounts, Visit_Order__c: visitOrder, Dealer_Distributor_CORP__c: dealerDistributor, OwnerId: ownerId, Meet_Greet__c: meetGreet, Risk_Stock__c: riskStock, Asset_Visibility__c: assetVisibility, POSM_Request__c: posmRequest, Sales_Order__c: salesOrder, QCR__c: qcr, Follow_up_task__c: Follow_up_task__c, isNew: isNew, attributes: attributes, isSync: isSync, Visit_Date_c: visit_Date, Visit_Order_c: visit_Order)
                
                skipList.append(skip)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching Skip.")
        }
        
        return skipList
    }
    
    func updateSyncStatusForMultipleSkipIds(localIds: [Int]) {
        for localId in localIds {
            updateSkipSyncStatus(forLocalId: localId)
        }
    }
    
    func updateSkipSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE SkipTable SET isSync = '1' WHERE localId = ?"
        
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

