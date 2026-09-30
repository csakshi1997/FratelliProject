//
//  SalesOrderLineItemsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 16/12/24.
//

import Foundation
import SQLite3

class SalesOrderLineItemsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createSalesOrderLineItemsTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS SalesOrderLineItemsTable (
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            externalId TEXT,
            productId TEXT,
            productName TEXT,
            schemeType TEXT,
            totalAmountINR TEXT,
            freeIssueQuantityInBottles TEXT,
            schemePercentage TEXT,
            productQuantity TEXT,
            dateTime TEXT,
            ownerId TEXT,
            createdAt TEXT,
            isSync TEXT,
            attributesType TEXT,
            attributesUrl TEXT
        );
        """
        
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error creating SalesOrderLineItemsTable: \(errorMsg)")
        } else {
            print("SalesOrderLineItemsTable created successfully")
        }
    }
    
    func addAddRemarkColumnIfNeeded() {
        
        let alterQuery = """
        ALTER TABLE SalesOrderLineItemsTable
        ADD COLUMN addRemark TEXT;
        """
        
        if sqlite3_exec(Database.databaseConnection, alterQuery, nil, nil, nil) != SQLITE_OK {
            
            let errorMessage = String(cString: sqlite3_errmsg(Database.databaseConnection))
            
            if errorMessage.contains("duplicate column name") {
                print("addRemark column already exists")
            } else {
                print("Failed to add addRemark column: \(errorMessage)")
            }
            
        } else {
            print("addRemark column added successfully")
        }
    }
    
    func saveSalesOrderLineItems(items: [SalesOrderLineItems], completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
        INSERT INTO SalesOrderLineItemsTable (externalId, productId, productName, schemeType, totalAmountINR, freeIssueQuantityInBottles, schemePercentage, productQuantity, dateTime, ownerId, createdAt, isSync, attributesType, attributesUrl, addRemark)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
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
                sqlite3_bind_text(statement, 1, item.External_Id__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, item.Product__ID ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, item.Product_Name ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, item.Scheme_Type__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, item.Total_Amount_INR__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, item.Free_Issue_Quantity_In_Btls__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, item.Scheme_Percentage__c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, item.Product_quantity_c ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, item.dateTime ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, item.ownerId ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, item.createdAt ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 12, item.isSync ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, item.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 14, item.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, item.addRemark ?? "", -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                    print("Error inserting SalesOrderLineItem: \(errorMsg)")
                    
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
            print("All SalesOrderLineItems inserted successfully")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getSalesOrderLineItems(completion: @escaping ([SalesOrderLineItems]?, String?) -> Void) {
        let selectQuery = "SELECT * FROM SalesOrderLineItemsTable;"
        var statement: OpaquePointer?
        var salesOrderLineItems: [SalesOrderLineItems] = []
        
        if sqlite3_prepare_v2(Database.databaseConnection, selectQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId: Int? = sqlite3_column_type(statement, 0) != SQLITE_NULL ? Int(sqlite3_column_int(statement, 0)) : nil
                let externalId = sqlite3_column_text(statement, 1).flatMap { String(cString: $0) }
                let productId = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) }
                let productName = sqlite3_column_text(statement, 3).flatMap { String(cString: $0) }
                let schemeType = sqlite3_column_text(statement, 4).flatMap { String(cString: $0) }
                let totalAmountINR = sqlite3_column_text(statement, 5).flatMap { String(cString: $0) }
                let freeIssueQuantityInBottles = sqlite3_column_text(statement, 6).flatMap { String(cString: $0) }
                let schemePercentage = sqlite3_column_text(statement, 7).flatMap { String(cString: $0) }
                let productQuantity = sqlite3_column_text(statement, 8).flatMap { String(cString: $0) }
                let dateTime = sqlite3_column_text(statement, 9).flatMap { String(cString: $0) }
                let ownerId = sqlite3_column_text(statement, 10).flatMap { String(cString: $0) }
                let createdAt = sqlite3_column_text(statement, 11).flatMap { String(cString: $0) }
                let isSync = sqlite3_column_text(statement, 12).flatMap { String(cString: $0) }
                let attributesType = sqlite3_column_text(statement, 13).flatMap { String(cString: $0) }
                let attributesUrl = sqlite3_column_text(statement, 14).flatMap { String(cString: $0) }
                let addRemark = sqlite3_column_text(statement, 15).flatMap { String(cString: $0) }
                let attributes = SalesOrderLineItems.Attributes(type: attributesType, url: attributesUrl)
                
                let item = SalesOrderLineItems(
                    localId: localId,
                    External_Id__c: externalId,
                    Product__ID: productId,
                    Product_Name: productName,
                    Scheme_Type__c: schemeType,
                    Total_Amount_INR__c: totalAmountINR,
                    Free_Issue_Quantity_In_Btls__c: freeIssueQuantityInBottles,
                    Scheme_Percentage__c: schemePercentage,
                    Product_quantity_c: productQuantity,
                    dateTime: dateTime,
                    ownerId: ownerId,
                    createdAt: createdAt,
                    isSync: isSync,
                    attributes: attributes,
                    addRemark: addRemark
                )
                
                salesOrderLineItems.append(item)
            }
            
            sqlite3_finalize(statement)
            completion(salesOrderLineItems, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(nil, errorMsg)
        }
    }
    
    func getSalesOrderLineItemsWhereIsSyncZero()  -> [SalesOrderLineItems] {
        let query = "SELECT * FROM SalesOrderLineItemsTable WHERE isSync = '0'"
        var statement: OpaquePointer?
        var resultArray: [SalesOrderLineItems] = []
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId: Int? = sqlite3_column_type(statement, 0) != SQLITE_NULL ? Int(sqlite3_column_int(statement, 0)) : nil
                let externalId = sqlite3_column_text(statement, 1).flatMap { String(cString: $0) } ?? ""
                let productId = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) } ?? ""
                let productName = sqlite3_column_text(statement, 3).flatMap { String(cString: $0) } ?? ""
                let schemeType = sqlite3_column_text(statement, 4).flatMap { String(cString: $0) } ?? ""
                let totalAmountINR = sqlite3_column_text(statement, 5).flatMap { String(cString: $0) } ?? ""
                let freeIssueQuantityInBottles = sqlite3_column_text(statement, 6).flatMap { String(cString: $0) } ?? ""
                let schemePercentage = sqlite3_column_text(statement, 7).flatMap { String(cString: $0) } ?? ""
                let productQuantity = sqlite3_column_text(statement, 8).flatMap { String(cString: $0) } ?? ""
                let dateTime = sqlite3_column_text(statement, 9).flatMap { String(cString: $0) } ?? ""
                let ownerId = sqlite3_column_text(statement, 10).flatMap { String(cString: $0) } ?? ""
                let createdAt = sqlite3_column_text(statement, 11).flatMap { String(cString: $0) } ?? ""
                let isSync = sqlite3_column_text(statement, 12).flatMap { String(cString: $0) } ?? ""
                let attributesType = sqlite3_column_text(statement, 13).flatMap { String(cString: $0) }
                let attributesUrl = sqlite3_column_text(statement, 14).flatMap { String(cString: $0) }
                
                let attributes = SalesOrderLineItems.Attributes(type: attributesType, url: attributesUrl)
                let addRemark = sqlite3_column_text(statement, 15).flatMap { String(cString: $0) } ?? ""
                
                let item = SalesOrderLineItems(
                    localId: localId,
                    External_Id__c: externalId,
                    Product__ID: productId,
                    Product_Name: productName,
                    Scheme_Type__c: schemeType,
                    Total_Amount_INR__c: totalAmountINR,
                    Free_Issue_Quantity_In_Btls__c: freeIssueQuantityInBottles,
                    Scheme_Percentage__c: schemePercentage,
                    Product_quantity_c: productQuantity,
                    dateTime: dateTime,
                    ownerId: ownerId,
                    createdAt: createdAt,
                    isSync: isSync,
                    attributes: attributes,
                    addRemark: addRemark
                )
                resultArray.append(item)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching Adhoc Sales Orders where isSync = '0'.")
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleLocalIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatus(localId: localId)
        }
    }
    
    func updateSyncStatus(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE SalesOrderLineItemsTable SET isSync = '1' WHERE localId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated isSync to 1 for localId: \(localId)")
            } else {
                print("Failed to update isSync for localId: \(localId)")
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing update statement: \(errorMsg)")
        }
        sqlite3_finalize(statement)
    }
}
