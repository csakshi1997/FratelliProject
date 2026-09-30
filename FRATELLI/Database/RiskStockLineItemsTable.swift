//
//  RiskStockLineItemsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 28/11/24.
//

import Foundation
import SQLite3
import UIKit

class RiskStockLineItemsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createRiskStockLineItemsTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Risk_Stock_Line_Items (
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            externalid TEXT,
            Product_Name__c TEXT,
            Outlet_Stock_In_Btls__c TEXT,
            Risk_Stock_In_Btls__c TEXT,
            DateTime TEXT,
            ownerId TEXT,
            isSync TEXT,
            createdAt TEXT,
            attributesType TEXT,
            attributesUrl TEXT
        );
        """
        
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating RiskStockLineItems table")
        }
    }
    
    func saveRiskStockLineItem(riskStockLineItem: RiskStockLineItem, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
        INSERT INTO Risk_Stock_Line_Items (externalid, Product_Name__c, Outlet_Stock_In_Btls__c, Risk_Stock_In_Btls__c, DateTime, ownerId, isSync, createdAt, attributesType, attributesUrl)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, riskStockLineItem.externalid ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, riskStockLineItem.Product_Name__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 3, Int32(Int(riskStockLineItem.Outlet_Stock_In_Btls__c ?? 0)))
            sqlite3_bind_int(statement, 4, Int32(Int(riskStockLineItem.Risk_Stock_In_Btls__c ?? 0)))
            sqlite3_bind_text(statement, 5, riskStockLineItem.DateTime ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, riskStockLineItem.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, riskStockLineItem.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, riskStockLineItem.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, riskStockLineItem.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, riskStockLineItem.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("RiskStockLineItem record saved successfully.")
                completion(true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error saving RiskStockLineItem: \(errorMsg)")
                completion(false, errorMsg)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Failed to prepare insert statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getRiskStockLineItems() -> [RiskStockLineItem] {
        var resultArray = [RiskStockLineItem]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM Risk_Stock_Line_Items"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var riskStockLineItem = RiskStockLineItem()
                riskStockLineItem.localId = Int(sqlite3_column_int(statement, 0))
                riskStockLineItem.externalid = String(cString: sqlite3_column_text(statement, 1))
                riskStockLineItem.Product_Name__c = String(cString: sqlite3_column_text(statement, 2))
                riskStockLineItem.Outlet_Stock_In_Btls__c = Int(sqlite3_column_int(statement, 3))
                riskStockLineItem.Risk_Stock_In_Btls__c = Int(sqlite3_column_int(statement, 4))
                riskStockLineItem.DateTime = String(cString: sqlite3_column_text(statement, 5))
                riskStockLineItem.ownerId = String(cString: sqlite3_column_text(statement, 6))
                riskStockLineItem.isSync = String(cString: sqlite3_column_text(statement, 7))
                riskStockLineItem.createdAt = String(cString: sqlite3_column_text(statement, 8))
                riskStockLineItem.attributes = RiskStockLineItem.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 9)),
                    url: String(cString: sqlite3_column_text(statement, 10))
                )
                resultArray.append(riskStockLineItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching RiskStockLineItems.")
        }
        return resultArray
    }
    
    func getRiskStockLineItemsWhereIsSyncZero() -> [RiskStockLineItem] {
        var resultArray = [RiskStockLineItem]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM Risk_Stock_Line_Items WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var lineItem = RiskStockLineItem()
                lineItem.localId = Int(sqlite3_column_int(statement, 0))
                lineItem.externalid = String(cString: sqlite3_column_text(statement, 1))
                lineItem.Product_Name__c = String(cString: sqlite3_column_text(statement, 2))
                lineItem.Outlet_Stock_In_Btls__c = Int(sqlite3_column_int(statement, 3))
                lineItem.Risk_Stock_In_Btls__c = Int(sqlite3_column_int(statement, 4))
                lineItem.DateTime = String(cString: sqlite3_column_text(statement, 5))
                lineItem.ownerId = String(cString: sqlite3_column_text(statement, 6))
                lineItem.isSync = String(cString: sqlite3_column_text(statement, 7))
                lineItem.createdAt = String(cString: sqlite3_column_text(statement, 8))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 9))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 10))
                lineItem.attributes = RiskStockLineItem.Attributes(type: attributesType, url: attributesUrl)
                
                resultArray.append(lineItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching RiskStockLineItem records where isSync = '0'.")
        }
        return resultArray
    }
    
    func updateRiskStockLineItemSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateRiskStockLineItemSyncStatus(forLocalId: localId)
        }
    }
    
    func updateRiskStockLineItemSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE Risk_Stock_Line_Items SET isSync = '1' WHERE localId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated isSync to 1 for RiskStockLineItem localId: \(localId)")
            } else {
                print("Failed to update isSync for RiskStockLineItem localId: \(localId)")
            }
        } else {
            print("Failed to prepare statement for updating isSync for RiskStockLineItem.")
        }
        sqlite3_finalize(statement)
    }
}
