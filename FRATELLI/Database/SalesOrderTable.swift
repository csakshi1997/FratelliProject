//
//  SalesOrderTable.swift
//  FRATELLI
//
//  Created by Sakshi on 16/12/24.
//

import Foundation
import SQLite3

class SalesOrderTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createSalesOrderTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS SalesOrderTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                External_Id__c TEXT,
                Bulk_Upload__c TEXT,
                Distributor__Id TEXT,
                DistributorName TEXT,
                Customer__Id TEXT,
                customerName TEXT,
                Employee_Code__c TEXT,
                Order_Booking_Data__c TEXT,
                Distributor_Party_Code__c TEXT,
                Customer_Party_Code__c TEXT,
                Status__c TEXT,
                dateTime TEXT,
                ownerId TEXT,
                addRemark TEXT,
                createdAt TEXT,
                isSync TEXT,
                attributesType TEXT,
                attributesUrl TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating SalesOrderTable")
        }
        
        Database.alterTable(tableName: "SalesOrderTable", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""]
        ])
    }
    
    func saveSalesOrder(order: SalesOrderModel, completion: @escaping (Bool, String?) -> Void) {
        let insertQuery = """
            INSERT INTO SalesOrderTable (External_Id__c, Bulk_Upload__c, Distributor__Id, DistributorName, Customer__Id, customerName, Employee_Code__c, Order_Booking_Data__c, Distributor_Party_Code__c, Customer_Party_Code__c, Status__c, dateTime, ownerId, addRemark, createdAt, isSync, attributesType, attributesUrl, Visit_Date_c, Visit_Order_c) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, order.External_Id__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, order.Bulk_Upload__c ? 1 : 0)
            sqlite3_bind_text(statement, 3, order.Distributor__Id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, order.DistributorName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, order.Customer__Id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, order.customerName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, order.Employee_Code__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, order.Order_Booking_Data__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, order.Distributor_Party_Code__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, order.Customer_Party_Code__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, order.Status__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, order.dateTime ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, order.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, order.addRemark ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, order.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, order.isSync ?? "", -1, SQLITE_TRANSIENT)
            
            sqlite3_bind_text(statement, 17, order.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, order.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, order.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, order.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting sales order: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Sales order inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getSalesOrders(completion: @escaping ([SalesOrderModel]?, String?) -> Void) {
        let selectQuery = "SELECT * FROM SalesOrderTable"
        var statement: OpaquePointer? = nil
        
        var salesOrders: [SalesOrderModel] = []
        
        if sqlite3_prepare_v2(Database.databaseConnection, selectQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = sqlite3_column_int(statement, 0)
                let externalId = String(cString: sqlite3_column_text(statement, 1))
                let bulkUpload = sqlite3_column_int(statement, 2) != 0
                let distributorId = String(cString: sqlite3_column_text(statement, 3))
                let distributorName = String(cString: sqlite3_column_text(statement, 4))
                let customerId = String(cString: sqlite3_column_text(statement, 5))
                let customerName = String(cString: sqlite3_column_text(statement, 6))
                let employeeCode = String(cString: sqlite3_column_text(statement, 7))
                let orderBookingData = String(cString: sqlite3_column_text(statement, 8))
                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 9))
                let customerPartyCode = String(cString: sqlite3_column_text(statement, 10))
                let status = String(cString: sqlite3_column_text(statement, 11))
                let dateTime = String(cString: sqlite3_column_text(statement, 12))
                let ownerId = String(cString: sqlite3_column_text(statement, 13))
                let addRemark = String(cString: sqlite3_column_text(statement, 14))
                let createdAt = String(cString: sqlite3_column_text(statement, 15))
                let isSync = String(cString: sqlite3_column_text(statement, 16))
                
                let attributesType = sqlite3_column_text(statement, 17) != nil ? String(cString: sqlite3_column_text(statement, 17)) : nil
                let attributesUrl = sqlite3_column_text(statement, 18) != nil ? String(cString: sqlite3_column_text(statement, 18)) : nil
                
                let attributes = SalesOrderModel.Attributes(type: attributesType, url: attributesUrl)
                
                let Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                let Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                
                let salesOrder = SalesOrderModel(
                    localId: Int(localId),
                    External_Id__c: externalId,
                    Bulk_Upload__c: bulkUpload,
                    Distributor__Id: distributorId,
                    DistributorName: distributorName,
                    Customer__Id: customerId,
                    customerName: customerName,
                    Employee_Code__c: employeeCode,
                    Order_Booking_Data__c: orderBookingData,
                    Distributor_Party_Code__c: distributorPartyCode,
                    Customer_Party_Code__c: customerPartyCode,
                    Status__c: status,
                    dateTime: dateTime,
                    ownerId: ownerId,
                    addRemark: addRemark,
                    createdAt: createdAt,
                    isSync: isSync,
                    attributes: attributes,
                    Visit_Date_c: Visit_Date_c,
                    Visit_Order_c: Visit_Order_c
                )
                
                salesOrders.append(salesOrder)
            }
            
            sqlite3_finalize(statement)
            completion(salesOrders, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error retrieving sales orders: \(errorMsg)")
            sqlite3_finalize(statement)
            completion(nil, errorMsg)
        }
    }
    
    func getAdhocSalesOrdersWhereIsSyncZero() -> [SalesOrderModel] {
        var resultArray = [SalesOrderModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM SalesOrderTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let externalId = String(cString: sqlite3_column_text(statement, 1))
                let bulkUpload = sqlite3_column_int(statement, 2) != 0
                let distributorId = String(cString: sqlite3_column_text(statement, 3))
                let distributorName = String(cString: sqlite3_column_text(statement, 4))
                let customerId = String(cString: sqlite3_column_text(statement, 5))
                let customerName = String(cString: sqlite3_column_text(statement, 6))
                let employeeCode = String(cString: sqlite3_column_text(statement, 7))
                let orderBookingData = String(cString: sqlite3_column_text(statement, 8))
                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 9))
                let customerPartyCode = String(cString: sqlite3_column_text(statement, 10))
                let status = String(cString: sqlite3_column_text(statement, 11))
                let dateTime = String(cString: sqlite3_column_text(statement, 12))
                let ownerId = String(cString: sqlite3_column_text(statement, 13))
                let addRemark = String(cString: sqlite3_column_text(statement, 14))
                let createdAt = String(cString: sqlite3_column_text(statement, 15))
                let isSync = String(cString: sqlite3_column_text(statement, 16))
                
                let attributesType = sqlite3_column_text(statement, 17) != nil ? String(cString: sqlite3_column_text(statement, 17)) : nil
                let attributesUrl = sqlite3_column_text(statement, 18) != nil ? String(cString: sqlite3_column_text(statement, 18)) : nil
                let attributes = SalesOrderModel.Attributes(type: attributesType, url: attributesUrl)
                
                let Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                let Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                
                let salesOrder = SalesOrderModel(
                    localId: localId,
                    External_Id__c: externalId,
                    Bulk_Upload__c: bulkUpload,
                    Distributor__Id: distributorId,
                    DistributorName: distributorName,
                    Customer__Id: customerId,
                    customerName: customerName,
                    Employee_Code__c: employeeCode,
                    Order_Booking_Data__c: orderBookingData,
                    Distributor_Party_Code__c: distributorPartyCode,
                    Customer_Party_Code__c: customerPartyCode,
                    Status__c: status,
                    dateTime: dateTime,
                    ownerId: ownerId,
                    addRemark: addRemark,
                    createdAt: createdAt,
                    isSync: isSync,
                    attributes: attributes,
                    Visit_Date_c: Visit_Date_c,
                    Visit_Order_c: Visit_Order_c
                )
                resultArray.append(salesOrder)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching Adhoc Sales Orders where isSync = '0'.")
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatus(localId: localId)
        }
    }
    
    func updateSyncStatus(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE SalesOrderTable SET isSync = '1' WHERE localId = ?"
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
