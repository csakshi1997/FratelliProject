//
//  RQCRTable.swift
//  FRATELLI
//
//  Created by Sakshi on 17/12/24.
//

import Foundation
import SQLite3

class RQCRTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createRQCRTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS RQCRTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                externalId TEXT,
                outletId TEXT,
                outletName TEXT,
                batchNo TEXT,
                brandName TEXT,
                canBottle TEXT,
                complaint TEXT,
                concernDetails TEXT,
                createdById TEXT,
                createdDate TEXT,
                dateOfGrievances TEXT,
                debitNoteCost TEXT,
                defectedQuantity INTEGER,
                locationDetails TEXT,
                manufacturingDate TEXT,
                particularBrandClosingStockReceived TEXT,
                remark TEXT,
                stockDetails TEXT,
                regionalSalesPerson TEXT,
                territorySalesPersonInCharge TEXT,
                ownerId TEXT,
                createdAt TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating RQCRTable")
        }
    }
    
    func saveRQCR(rqcr: RQCRModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO RQCRTable (externalId, outletId, outletName, batchNo, brandName, canBottle, complaint, concernDetails,
            createdById, createdDate, dateOfGrievances, debitNoteCost, defectedQuantity, locationDetails, manufacturingDate,
            particularBrandClosingStockReceived, remark, stockDetails, regionalSalesPerson, territorySalesPersonInCharge,
            ownerId, createdAt, isSync)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, rqcr.externalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, rqcr.outletId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, rqcr.outletName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, rqcr.batchNo, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, rqcr.brandName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, rqcr.canBottle, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, rqcr.complaint, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, rqcr.concernDetails, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, rqcr.createdById, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, rqcr.createdDate, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, rqcr.dateOfGrievances, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, rqcr.debitNoteCost, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 13, Int32(rqcr.defectedQuantity))
            sqlite3_bind_text(statement, 14, rqcr.locationDetails, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, rqcr.manufacturingDate, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, rqcr.particularBrandClosingStockReceived, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, rqcr.remark, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, rqcr.stockDetails, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, rqcr.regionalSalesPerson, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, rqcr.territorySalesPersonInCharge, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 21, rqcr.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 22, rqcr.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 23, rqcr.isSync ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting RQCR: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("RQCR inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getRQCRs() -> [RQCRModel] {
        var resultArray = [RQCRModel]()
        var rqcr: RQCRModel?
        var statement: OpaquePointer?
        let query = "SELECT * FROM RQCRTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                rqcr?.localId = Int(sqlite3_column_int(statement, 0))
                rqcr?.externalId = String(cString: sqlite3_column_text(statement, 1))
                rqcr?.outletId = String(cString: sqlite3_column_text(statement, 2))
                rqcr?.outletName = String(cString: sqlite3_column_text(statement, 3))
                rqcr?.batchNo = String(cString: sqlite3_column_text(statement, 4))
                rqcr?.brandName = String(cString: sqlite3_column_text(statement, 5))
                rqcr?.canBottle = String(cString: sqlite3_column_text(statement, 6))
                rqcr?.complaint = String(cString: sqlite3_column_text(statement, 7))
                rqcr?.concernDetails = String(cString: sqlite3_column_text(statement, 8))
                rqcr?.createdById = String(cString: sqlite3_column_text(statement, 9))
                rqcr?.createdDate = String(cString: sqlite3_column_text(statement, 10))
                rqcr?.dateOfGrievances = String(cString: sqlite3_column_text(statement, 11))
                rqcr?.debitNoteCost = String(cString: sqlite3_column_text(statement, 12))
                rqcr?.defectedQuantity = Int(sqlite3_column_int(statement, 13))
                rqcr?.locationDetails = String(cString: sqlite3_column_text(statement, 14))
                rqcr?.manufacturingDate = String(cString: sqlite3_column_text(statement, 15))
                rqcr?.particularBrandClosingStockReceived = String(cString: sqlite3_column_text(statement, 16))
                rqcr?.remark = String(cString: sqlite3_column_text(statement, 17))
                rqcr?.stockDetails = String(cString: sqlite3_column_text(statement, 18))
                rqcr?.regionalSalesPerson = String(cString: sqlite3_column_text(statement, 19))
                rqcr?.territorySalesPersonInCharge = String(cString: sqlite3_column_text(statement, 20))
                rqcr?.ownerId = String(cString: sqlite3_column_text(statement, 21))
                rqcr?.createdAt = String(cString: sqlite3_column_text(statement, 22))
                rqcr?.isSync = String(cString: sqlite3_column_text(statement, 23))
                resultArray.append(rqcr ?? RQCRModel(batchNo: "", brandName: "", canBottle: "", complaint: "", concernDetails: "", createdById: "", createdDate: "", dateOfGrievances: "", debitNoteCost: "", defectedQuantity: 0, locationDetails: "", manufacturingDate: "", particularBrandClosingStockReceived: "", remark: "", stockDetails: "", regionalSalesPerson: "", territorySalesPersonInCharge: ""))
            }
            sqlite3_finalize(statement)
        }
        return resultArray
    }
    
    func getRQCRsWhereIsSyncZero() -> [RQCRModel] {
        var resultArray = [RQCRModel]()
        var rqcr: RQCRModel?
        var statement: OpaquePointer?
        let query = "SELECT * FROM RQCRTable WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                rqcr = RQCRModel(
                    localId: Int(sqlite3_column_int(statement, 0)),
                    externalId: String(cString: sqlite3_column_text(statement, 1)),
                    outletId: String(cString: sqlite3_column_text(statement, 2)),
                    outletName: String(cString: sqlite3_column_text(statement, 3)),
                    batchNo: String(cString: sqlite3_column_text(statement, 4)),
                    brandName: String(cString: sqlite3_column_text(statement, 5)),
                    canBottle: String(cString: sqlite3_column_text(statement, 6)),
                    complaint: String(cString: sqlite3_column_text(statement, 7)),
                    concernDetails: String(cString: sqlite3_column_text(statement, 8)),
                    createdById: String(cString: sqlite3_column_text(statement, 9)),
                    createdDate: String(cString: sqlite3_column_text(statement, 10)),
                    dateOfGrievances: String(cString: sqlite3_column_text(statement, 11)),
                    debitNoteCost: String(cString: sqlite3_column_text(statement, 12)),
                    defectedQuantity: Int(sqlite3_column_int(statement, 13)),
                    locationDetails: String(cString: sqlite3_column_text(statement, 14)),
                    manufacturingDate: String(cString: sqlite3_column_text(statement, 15)),
                    particularBrandClosingStockReceived: String(cString: sqlite3_column_text(statement, 16)),
                    remark: String(cString: sqlite3_column_text(statement, 17)),
                    stockDetails: String(cString: sqlite3_column_text(statement, 18)),
                    regionalSalesPerson: String(cString: sqlite3_column_text(statement, 19)),
                    territorySalesPersonInCharge: String(cString: sqlite3_column_text(statement, 20)),
                    ownerId: String(cString: sqlite3_column_text(statement, 21)),
                    createdAt: String(cString: sqlite3_column_text(statement, 22)),
                    isSync: String(cString: sqlite3_column_text(statement, 23))
                )
                
                resultArray.append(rqcr ?? RQCRModel(batchNo: "", brandName: "", canBottle: "", complaint: "", concernDetails: "", createdById: "", createdDate: "", dateOfGrievances: "", debitNoteCost: "", defectedQuantity: 0, locationDetails: "", manufacturingDate: "", particularBrandClosingStockReceived: "", remark: "", stockDetails: "", regionalSalesPerson: "", territorySalesPersonInCharge: ""))
            }
            sqlite3_finalize(statement)
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatus(forLocalId: localId)
        }
    }
    
    func updateSyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE RQCRTable SET isSync = '1' WHERE localId = ?"
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
