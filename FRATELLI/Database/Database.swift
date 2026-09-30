//
//  Database.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation
import UIKit
import SQLite3

class Database: NSObject {
    static var databaseConnection: OpaquePointer? = nil
    
    func printErroMessage() -> String {
        return String(cString:sqlite3_errmsg(Database.databaseConnection))
    }
    
    func getStringAt(statement:OpaquePointer, column:Int ) -> String? {
        let cColumn:CInt = CInt(column)
        let c = sqlite3_column_text(statement, cColumn)
        if ( c != nil ) {
            let cStringPtr = UnsafePointer<UInt8>(c)
            return String(cString:cStringPtr!)
        } else  {
            return EMPTY
        }
    }
    
    func getIntAt(statement:OpaquePointer, column:Int) -> Int {
        let cColumn:CInt = CInt(column)
        return Int(sqlite3_column_int(statement, cColumn))
    }
    
    class func createDatabase() {
        print(sqlite3_libversion()!)
        print(sqlite3_threadsafe())
        openDatabase()
        let contactsTable = ContactsTable()
        contactsTable.createContactsTable()
        let outletsTable = OutletsTable()
        outletsTable.createOutletsTable()
        let visitsTable = VisitsTable()
        visitsTable.createVisitsTable()
        let productsTable = ProductsTable()
        productsTable.createProductsTable()
        let recommendationsTable = RecommendationsTable()
        recommendationsTable.createRecommendationsTable()
        let advocacyTable = AdvocacyTable()
        advocacyTable.createAdvocacyTable()
        let promotionsTable = PromotionsTable()
        promotionsTable.createPromotionsTable()
        let onTradeTable = OnTradeTable()
        onTradeTable.createOnTradeTable()
        let riskStockTable = RiskStockTable()
        riskStockTable.createRiskStockTable()
        let riskStockLineItemsTable = RiskStockLineItemsTable()
        riskStockLineItemsTable.createRiskStockLineItemsTable()
        let onAssetsTable = OnAssetsTable()
        onAssetsTable.createOnAssetsTable()
        let salesOrderTable = SalesOrderTable()
        salesOrderTable.createSalesOrderTable()
        let salesOrderLineItemsTable = SalesOrderLineItemsTable()
        salesOrderLineItemsTable.createSalesOrderLineItemsTable()
        salesOrderLineItemsTable.addAddRemarkColumnIfNeeded()
        let rQCRTable = RQCRTable()
        rQCRTable.createRQCRTable()
        let pOSMTable = POSMTable()
        pOSMTable.createPOSMTable()
        let pOSMLineItemsTable = POSMLineItemsTable()
        pOSMLineItemsTable.createPOSMLineItemsTable()
        let allVisibilityTable = AllVisibilityTable()
        allVisibilityTable.createAllVisibilityTable()
        let homePOSMTable = HomePOSMTable()
        homePOSMTable.createHomePOSMTable()
        let homePOSMLineItemTable = HomePOSMLineItemTable()
        homePOSMLineItemTable.createHomePOSMLineItemTable()
        let homeAssetTable = HomeAssetTable()
        homeAssetTable.createHomeAssetTable()
        let callForHelpTable = CallForHelpTable()
        callForHelpTable.createCallForHelpTable()
        let addNewTaskTable = AddNewTaskTable()
        addNewTaskTable.createAddNewTaskTable()
        let pOSMRequisitionTable = POSMRequisitionTable()
        pOSMRequisitionTable.createPOSMRequisitionTable()
        let assetRequisitionTable = AssetRequisitionTable()
        assetRequisitionTable.createAssetRequisitionTable()
        let skipTable = SkipTable()
        skipTable.createSkipTable()
        let distributorAccountsTable = DistributorAccountsTable()
        distributorAccountsTable.createOutletsTable()
        let locationTable = LocationTable()
        locationTable.createLocationTable()
        let otherActivityTable = OtherActivityTable()
        otherActivityTable.createOtherActivityTable()
        let visibilityServerTable = VisibilityServerTable()
        visibilityServerTable.createVisibilityServerTable()
        let assetRequisitionServerTable = AssetRequisitionServerTable()
        assetRequisitionServerTable.createVisibilityServerTable()
    }
    
    class func openDatabase() {
        if sqlite3_open_v2(getDBPath(), &databaseConnection, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            print("Successfully opened connection to database")
        } else {
            print("Unable to open database.")
        }
    }
    
    class func getDBPath() -> String {
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir: String? = (paths[0] as? String)
        let folderDir: String = documentsDir! + "/Fratelli.db"
        print(folderDir)
        return folderDir
    }
}

extension Database {
    static func columnExists(in tableName: String, columnName: String) -> Bool {
        let query = "PRAGMA table_info(\(tableName));"
        var statement: OpaquePointer?
        var exists = false
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let name = sqlite3_column_text(statement, 1) {
                    let column = String(cString: name)
                    if column == columnName {
                        exists = true
                        break
                    }
                }
            }
        }
        sqlite3_finalize(statement)
        return exists
    }
    
    static func deleteTable(tableName: String) {
        let querySQL = "delete from \(tableName)"
        var localStatement: OpaquePointer? = nil
        sqlite3_prepare_v2(Database.databaseConnection, querySQL, -1, &localStatement, nil)
        sqlite3_step(localStatement)
        sqlite3_reset(localStatement)
    }
    
    static func alterTable(tableName: String, dictArray: [[String : String]]) {
        for dict in dictArray {
            guard let column = dict["column"], let defaultValue = dict["defaultValue"] else { continue }
            
            if !columnExists(in: tableName, columnName: column) {
                let querySQL = "ALTER TABLE \(tableName) ADD COLUMN \(column) TEXT DEFAULT '\(defaultValue)'"
                var localStatement: OpaquePointer?
                if sqlite3_prepare_v2(Database.databaseConnection, querySQL, -1, &localStatement, nil) == SQLITE_OK {
                    sqlite3_step(localStatement)
                }
                sqlite3_finalize(localStatement)
            } else {
                print("Column '\(column)' already exists in table '\(tableName)'")
            }
        }
    }
}

