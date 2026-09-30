//
//  RiskStockTable.swift
//  FRATELLI
//
//  Created by Sakshi on 28/11/24.
//

import Foundation
import SQLite3
import UIKit

class RiskStockTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createRiskStockTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Risk_Stock__c (
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            externalId TEXT,
            DateTime TEXT,
            outletId TEXT,
            ownerId TEXT,
            isInitiateCustomerPromotion TEXT,
            remarks TEXT,
            attributesType TEXT,
            attributesUrl TEXT,
            isSync TEXT,
            createdAt TEXT
        );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating RiskStock table")
        }
        
        Database.alterTable(tableName: "Risk_Stock__c", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""]
        ])
    }

    func saveRiskStock(riskStock: RiskStock, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
        INSERT INTO Risk_Stock__c (externalId, DateTime, outletId, ownerId, isInitiateCustomerPromotion, remarks, attributesType, attributesUrl, isSync, createdAt, Visit_Date_c, Visit_Order_c)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, riskStock.externalid ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, riskStock.DateTime ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, riskStock.outletId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, riskStock.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 5, riskStock.isInitiateCustomerPromotion ?? false ? 1 : 0)
            sqlite3_bind_text(statement, 6, riskStock.remarks ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, riskStock.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, riskStock.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, riskStock.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, riskStock.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, riskStock.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, riskStock.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("RiskStock record saved successfully.")
                completion(true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error saving RiskStock: \(errorMsg)")
                completion(false, errorMsg)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Failed to prepare insert statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getRiskStocks() -> [RiskStock] {
        var resultArray = [RiskStock]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM Risk_Stock__c"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var riskStock = RiskStock()
                riskStock.localId = Int(sqlite3_column_int(statement, 0))
                riskStock.externalid = String(cString: sqlite3_column_text(statement, 1))
                riskStock.DateTime = String(cString: sqlite3_column_text(statement, 2))
                riskStock.outletId = String(cString: sqlite3_column_text(statement, 3))
                riskStock.ownerId = String(cString: sqlite3_column_text(statement, 4))
                riskStock.isInitiateCustomerPromotion = sqlite3_column_int(statement, 5) == 1
                riskStock.remarks = String(cString: sqlite3_column_text(statement, 6))
                riskStock.attributes = RiskStock.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 7)),
                    url: String(cString: sqlite3_column_text(statement, 8))
                )
                riskStock.isSync = String(cString: sqlite3_column_text(statement, 9))
                riskStock.createdAt = String(cString: sqlite3_column_text(statement, 10))
                riskStock.Visit_Date_c = String(cString: sqlite3_column_text(statement, 11))
                riskStock.Visit_Order_c = String(cString: sqlite3_column_text(statement, 12))
                
                resultArray.append(riskStock)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching RiskStock records.")
        }
        return resultArray
    }
    
    func getRiskStocksWhereIsSyncZero() -> [RiskStock] {
        var resultArray = [RiskStock]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM Risk_Stock__c WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var riskStock = RiskStock()
                riskStock.localId = Int(sqlite3_column_int(statement, 0))
                riskStock.externalid = String(cString: sqlite3_column_text(statement, 1))
                riskStock.DateTime = String(cString: sqlite3_column_text(statement, 2))
                riskStock.outletId = String(cString: sqlite3_column_text(statement, 3))
                riskStock.ownerId = String(cString: sqlite3_column_text(statement, 4))
                riskStock.isInitiateCustomerPromotion = sqlite3_column_int(statement, 5) != 0
                riskStock.remarks = String(cString: sqlite3_column_text(statement, 6))
                riskStock.isSync = String(cString: sqlite3_column_text(statement, 7))
                riskStock.createdAt = String(cString: sqlite3_column_text(statement, 8))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 9))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 10))
                riskStock.attributes = RiskStock.Attributes(type: attributesType, url: attributesUrl)
                riskStock.Visit_Date_c = String(cString: sqlite3_column_text(statement, 11))
                riskStock.Visit_Order_c = String(cString: sqlite3_column_text(statement, 12))
                resultArray.append(riskStock)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching RiskStock records where isSync = '0'.")
        }
        return resultArray
    }
    
    func updateRiskStockSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateRiskStockSyncStatus(forLocalId: localId)
        }
    }
    
    func updateRiskStockSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE Risk_Stock__c SET isSync = '1' WHERE localId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated isSync to 1 for RiskStock localId: \(localId)")
            } else {
                print("Failed to update isSync for RiskStock localId: \(localId)")
            }
        } else {
            print("Failed to prepare statement for updating isSync for RiskStock.")
        }
        sqlite3_finalize(statement)
    }
}
