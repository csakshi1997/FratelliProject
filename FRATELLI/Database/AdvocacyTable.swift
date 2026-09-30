//
//  AdvocacyTable.swift
//  FRATELLI
//
//  Created by Sakshi on 08/11/24.
//

import Foundation
import UIKit
import SQLite3

class AdvocacyTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createAdvocacyTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS AdvocacyTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                ExternalId TEXT,
                outerName TEXT,
                outerId TEXT,
                advocacyDate TEXT,
                productName TEXT,
                productId TEXT,
                pax TEXT,
                ownerId TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating Advocacy Table")
        }
    }
    
    func saveAdvocacyDate(advocacyRequest: AdvocacyRequest, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO AdvocacyTable (ExternalId, outerName, outerId, advocacyDate, productName, productId, pax, ownerId, isSync, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, advocacyRequest.ExternalId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, advocacyRequest.outerName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, advocacyRequest.outerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, advocacyRequest.advocacyDate, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, advocacyRequest.productName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, advocacyRequest.productId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, advocacyRequest.pax ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, advocacyRequest.OwnerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, advocacyRequest.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, advocacyRequest.createdAt ?? "", -1, SQLITE_TRANSIENT)
            
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
    
    func getAdvocacyRequests(completion: @escaping ([AdvocacyRequest]?, String?) -> Void) {
        var statement: OpaquePointer?
        let query = "SELECT * FROM AdvocacyTable"
        
        var advocacyRequests: [AdvocacyRequest] = []
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let externalId = String(cString: sqlite3_column_text(statement, 1))
                let outerName = String(cString: sqlite3_column_text(statement, 2))
                let outerId = String(cString: sqlite3_column_text(statement, 3))
                let advocacyDate = String(cString: sqlite3_column_text(statement, 4))
                let productName = String(cString: sqlite3_column_text(statement, 5))
                let productId = String(cString: sqlite3_column_text(statement, 6))
                let pax = String(cString: sqlite3_column_text(statement, 7))
                let ownerId = String(cString: sqlite3_column_text(statement, 8))
                let isSync = String(cString: sqlite3_column_text(statement, 9))
                let createdAt = String(cString: sqlite3_column_text(statement, 10))
                
                let advocacyRequest = AdvocacyRequest(
                    localId: localId,
                    ExternalId: externalId,
                    outerName: outerName,
                    outerId: outerId.isEmpty ? "" : outerId,
                    advocacyDate: advocacyDate,
                    productName: productName.isEmpty ? "" : productName,
                    productId: productId,
                    pax: pax.isEmpty ? nil : pax,
                    OwnerId: ownerId.isEmpty ? "" : ownerId,
                    isSync: isSync.isEmpty ? "" : isSync,
                    createdAt: createdAt.isEmpty ? "" : createdAt
                )
                advocacyRequests.append(advocacyRequest)
            }
            completion(advocacyRequests, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(nil, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getAdvocacyRequestsWhereIsSyncZero() -> [AdvocacyRequest] {
        var resultArray = [AdvocacyRequest]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM AdvocacyTable WHERE isSync = '0'"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var advocacyRequest = AdvocacyRequest()
                advocacyRequest.localId = Int(sqlite3_column_int(statement, 0))
                advocacyRequest.ExternalId = String(cString: sqlite3_column_text(statement, 1))
                advocacyRequest.outerName = String(cString: sqlite3_column_text(statement, 2))
                advocacyRequest.outerId = String(cString: sqlite3_column_text(statement, 3))
                advocacyRequest.advocacyDate = String(cString: sqlite3_column_text(statement, 4))
                advocacyRequest.productName = String(cString: sqlite3_column_text(statement, 5))
                advocacyRequest.productId = String(cString: sqlite3_column_text(statement, 6))
                advocacyRequest.pax = String(cString: sqlite3_column_text(statement, 7))
                advocacyRequest.OwnerId = String(cString: sqlite3_column_text(statement, 8))
                advocacyRequest.isSync = String(cString: sqlite3_column_text(statement, 9))
                advocacyRequest.createdAt = String(cString: sqlite3_column_text(statement, 10))
                
                resultArray.append(advocacyRequest)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching advocacy requests with isSync = 0.")
        }
        
        return resultArray
    }
    
    func updateSyncStatusForMultipleAdvocacyRequests(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatusForAdvocacyRequest(localId: localId)
        }
    }

    func updateSyncStatusForAdvocacyRequest(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE AdvocacyTable SET isSync = '1' WHERE localId = ?"
        
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

