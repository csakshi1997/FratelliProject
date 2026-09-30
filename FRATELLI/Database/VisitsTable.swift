//
//  VisitsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation
import UIKit
import SQLite3

class VisitsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createVisitsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS VisitsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                accountId TEXT,
                accountReferenceClassification TEXT,
                accountReferenceId TEXT,
                accountReferenceName TEXT,
                accountReferenceOwnerId TEXT,
                accountReferenceSubChannel TEXT,
                actualEnd TEXT,
                actualStart TEXT,
                area TEXT,
                beatRoute TEXT,
                channel TEXT,
                checkInLocation TEXT,
                checkOutLocation TEXT,
                checkedInLocationLatitude TEXT,
                checkedInLocationLongitude TEXT,
                checkedIn INTEGER,
                checkedOutGeolocationLatitude TEXT,
                checkedOutGeolocationLongitude TEXT,
                checkedOut INTEGER,
                empZone TEXT,
                employeeCode INTEGER,
                id TEXT,
                name TEXT,
                oldPartyCode TEXT,
                outletCreation TEXT,
                outletType TEXT,
                ownerId TEXT,
                ownerArea TEXT,
                partyCode TEXT,
                remarks TEXT,
                status TEXT,
                visitPlanDate TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT,
                isCompleted TEXT,
                createdAt TEXT,
                isNew INTEGER,
                externalId TEXT,
                fromAppCompleted TEXT,
                Contact_Person_Name__c TEXT,
                Contact_Phone_Number__c TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating VisitsTable")
        }
    }
    
    
    func saveVisit(visit: Visit, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO VisitsTable (
            accountId, accountReferenceId, accountReferenceClassification, accountReferenceName,
            accountReferenceOwnerId, accountReferenceSubChannel, actualEnd, actualStart, area, beatRoute, channel,
            checkInLocation, checkOutLocation, checkedInLocationLatitude, checkedInLocationLongitude,
            checkedIn, checkedOutGeolocationLatitude, checkedOutGeolocationLongitude, checkedOut,
            empZone, employeeCode, id, name, oldPartyCode, outletCreation, outletType, ownerId,
            ownerArea, partyCode, remarks, status, visitPlanDate, attributesType, attributesUrl,
            isSync, isCompleted, createdAt, isNew, externalId, fromAppCompleted, Contact_Person_Name__c, Contact_Phone_Number__c) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """

        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, visit.accountId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, visit.accountReference?.id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, visit.accountReference?.classification ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, visit.accountReference?.name ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, visit.accountReference?.ownerId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, visit.accountReference?.subChannel ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, visit.actualEnd ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, visit.actualStart ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, visit.area ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, visit.beatRoute ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, visit.channel ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, visit.checkInLocation ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, visit.checkOutLocation ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, visit.checkedInLocationLatitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, visit.checkedInLocationLongitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 16, Int32(visit.checkedIn))
            sqlite3_bind_text(statement, 17, visit.checkedOutGeolocationLatitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, visit.checkedOutGeolocationLongitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 19, Int32(visit.checkedOut))
            sqlite3_bind_text(statement, 20, visit.empZone, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 21, Int32(visit.employeeCode))
            sqlite3_bind_text(statement, 22, visit.id ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 23, visit.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 24, visit.oldPartyCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 25, visit.outletCreation, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 26, visit.outletType ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 27, visit.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 28, visit.ownerArea, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 29, visit.partyCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 30, visit.remarks ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 31, visit.status, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 32, visit.visitPlanDate, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 33, visit.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 34, visit.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 35, visit.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 36, visit.isCompleted ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 37, visit.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 38, Int32(visit.isNew ?? 0))
            sqlite3_bind_text(statement, 39, visit.externalId ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 40, visit.fromAppCompleted ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 41, visit.Contact_Person_Name__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 42, visit.Contact_Phone_Number__c ?? "", -1, SQLITE_TRANSIENT)

            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting visit: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Visit inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Failed to prepare statement: \(errorMsg)")
            completion(false, errorMsg)
        }

        sqlite3_finalize(statement)
    }
    
    
    func fetchTodaysVisits() -> [Visit] {
        var visits = [Visit]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM VisitsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let accountReference = Visit.Account(
                    classification: String(cString: sqlite3_column_text(statement, 2)),
                    id: String(cString: sqlite3_column_text(statement, 3)),
                    name: String(cString: sqlite3_column_text(statement, 4)),
                    ownerId: String(cString: sqlite3_column_text(statement, 5)),
                    subChannel: String(cString: sqlite3_column_text(statement, 6))
                )
                
                let attributes = Visit.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 33)),  // attributesType
                    url: String(cString: sqlite3_column_text(statement, 34))    // attributesUrl
                )
                
                let visit = Visit(
                    localId: Int(sqlite3_column_int(statement, 0)),
                    accountId: String(cString: sqlite3_column_text(statement, 1)),
                    accountReference: accountReference,
                    actualEnd: String(cString: sqlite3_column_text(statement, 7)),
                    actualStart: String(cString: sqlite3_column_text(statement, 8)),
                    area: String(cString: sqlite3_column_text(statement, 9)),
                    beatRoute: String(cString: sqlite3_column_text(statement, 10)),
                    channel: String(cString: sqlite3_column_text(statement, 11)),
                    checkInLocation: String(cString: sqlite3_column_text(statement, 12)),
                    checkOutLocation: String(cString: sqlite3_column_text(statement, 13)),
                    checkedInLocationLatitude: String(cString: sqlite3_column_text(statement, 14)),
                    checkedInLocationLongitude: String(cString: sqlite3_column_text(statement, 15)),
                    checkedIn: Int(sqlite3_column_int(statement, 16)),
                    checkedOutGeolocationLatitude: String(cString: sqlite3_column_text(statement, 17)),
                    checkedOutGeolocationLongitude: String(cString: sqlite3_column_text(statement, 18)),
                    checkedOut: Int(sqlite3_column_int(statement, 19)),
                    empZone: String(cString: sqlite3_column_text(statement, 20)),
                    employeeCode: Int(sqlite3_column_int(statement, 21)),
                    id: String(cString: sqlite3_column_text(statement, 22)),
                    name: String(cString: sqlite3_column_text(statement, 23)),
                    oldPartyCode: String(cString: sqlite3_column_text(statement, 24)),
                    outletCreation: String(cString: sqlite3_column_text(statement, 25)),
                    outletType: String(cString: sqlite3_column_text(statement, 26)),
                    ownerId: String(cString: sqlite3_column_text(statement, 27)),
                    ownerArea: String(cString: sqlite3_column_text(statement, 28)),
                    partyCode: String(cString: sqlite3_column_text(statement, 29)),
                    remarks: String(cString: sqlite3_column_text(statement, 30)),
                    status: String(cString: sqlite3_column_text(statement, 31)),
                    visitPlanDate: String(cString: sqlite3_column_text(statement, 32)),
                    attributes: attributes,
                    isSync: String(cString: sqlite3_column_text(statement, 35)),
                    isCompleted: String(cString: sqlite3_column_text(statement, 36)),
                    createdAt: String(cString: sqlite3_column_text(statement, 37)),
                    isNew: Int(sqlite3_column_int(statement, 38)),
                    externalId: String(cString: sqlite3_column_text(statement, 39)),
                    fromAppCompleted: String(cString: sqlite3_column_text(statement, 40)),
                    Contact_Person_Name__c: String(cString: sqlite3_column_text(statement, 41)),
                    Contact_Phone_Number__c : String(cString: sqlite3_column_text(statement, 42))
                )
                visits.append(visit)
            }
            sqlite3_finalize(statement)
            DispatchQueue.main.async {
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
        }
        return visits
    }
    
    func fetchAllAccountIds() -> [String] {
        var accountIds = [String]()
        var statement: OpaquePointer?
        let query = "SELECT accountId FROM VisitsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let accountIdCStr = sqlite3_column_text(statement, 0) {
                    let accountId = String(cString: accountIdCStr)
                    accountIds.append(accountId)
                }
            }
            sqlite3_finalize(statement)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
        }
        return accountIds
    }
    
    func getVisitDataByAccountId(accountId: String) -> Visit? {
        var resultVisit: Visit? = nil
        var statement: OpaquePointer?
        
        let query = "SELECT * FROM VisitsTable WHERE accountId = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, accountId, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let accountReference = Visit.Account(
                    classification: String(cString: sqlite3_column_text(statement, 2)),
                    id: String(cString: sqlite3_column_text(statement, 3)),
                    name: String(cString: sqlite3_column_text(statement, 4)),
                    ownerId: String(cString: sqlite3_column_text(statement, 5)),
                    subChannel: String(cString: sqlite3_column_text(statement, 6))
                )
                
                let attributes = Visit.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 33)),
                    url: String(cString: sqlite3_column_text(statement, 34))
                )
                let visit = Visit(
                    localId: Int(sqlite3_column_int(statement, 0)),
                    accountId: String(cString: sqlite3_column_text(statement, 1)),
                    accountReference: accountReference,
                    actualEnd: String(cString: sqlite3_column_text(statement, 7)),
                    actualStart: String(cString: sqlite3_column_text(statement, 8)),
                    area: String(cString: sqlite3_column_text(statement, 9)),
                    beatRoute: String(cString: sqlite3_column_text(statement, 10)),
                    channel: String(cString: sqlite3_column_text(statement, 11)),
                    checkInLocation: String(cString: sqlite3_column_text(statement, 12)),
                    checkOutLocation: String(cString: sqlite3_column_text(statement, 13)),
                    checkedInLocationLatitude: String(cString: sqlite3_column_text(statement, 14)),
                    checkedInLocationLongitude: String(cString: sqlite3_column_text(statement, 15)),
                    checkedIn: Int(sqlite3_column_int(statement, 16)),
                    checkedOutGeolocationLatitude: String(cString: sqlite3_column_text(statement, 17)),
                    checkedOutGeolocationLongitude: String(cString: sqlite3_column_text(statement, 18)),
                    checkedOut: Int(sqlite3_column_int(statement, 19)),
                    empZone: String(cString: sqlite3_column_text(statement, 20)),
                    employeeCode: Int(sqlite3_column_int(statement, 21)),
                    id: String(cString: sqlite3_column_text(statement, 22)),
                    name: String(cString: sqlite3_column_text(statement, 23)),
                    oldPartyCode: String(cString: sqlite3_column_text(statement, 24)),
                    outletCreation: String(cString: sqlite3_column_text(statement, 25)),
                    outletType: String(cString: sqlite3_column_text(statement, 26)),
                    ownerId: String(cString: sqlite3_column_text(statement, 27)),
                    ownerArea: String(cString: sqlite3_column_text(statement, 28)),
                    partyCode: String(cString: sqlite3_column_text(statement, 29)),
                    remarks: String(cString: sqlite3_column_text(statement, 30)),
                    status: String(cString: sqlite3_column_text(statement, 31)),
                    visitPlanDate: String(cString: sqlite3_column_text(statement, 32)),
                    attributes: attributes,
                    isSync: String(cString: sqlite3_column_text(statement, 35)),
                    isCompleted: String(cString: sqlite3_column_text(statement, 36)),
                    createdAt: String(cString: sqlite3_column_text(statement, 37)),
                    isNew: Int(sqlite3_column_int(statement, 38)),
                    externalId: String(cString: sqlite3_column_text(statement, 39)),
                    fromAppCompleted: String(cString: sqlite3_column_text(statement, 40)),
                    Contact_Person_Name__c: String(cString: sqlite3_column_text(statement, 41)),
                    Contact_Phone_Number__c : String(cString: sqlite3_column_text(statement, 42))
                )
                resultVisit = visit
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching visit by accountId.")
        }
        return resultVisit
    }
    
    func updateCheckInLocation(actualStart: String, forVisitId: String, isSync: String, createdAt: String, checkInLocation: String, latitude: String, longitude: String, checkedIn: Bool, externalId: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        
        let updateQuery = """
            UPDATE VisitsTable 
            SET checkInLocation = ?, actualStart = ?, checkedInLocationLatitude = ?, checkedInLocationLongitude = ?, checkedIn = ?, isSync = ?, externalId = ? 
            WHERE accountId = ?
        """
        guard let dbConnection = Database.databaseConnection else {
            print("Error: Database connection is nil.")
            completion(false, "Database connection is nil")
            return
        }
        if sqlite3_prepare_v2(dbConnection, updateQuery, -1, &statement, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
            return
        }
        sqlite3_bind_text(statement, 1, checkInLocation, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, actualStart, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 3, latitude, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 4, longitude, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 5, checkedIn ? 1 : 0)
        sqlite3_bind_text(statement, 6, isSync, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 7, externalId, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 8, forVisitId, -1, SQLITE_TRANSIENT)
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Check-in location updated successfully for visitId: \(forVisitId)")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error executing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateCheckOutLocation(createdAt: String, actualEnd: String, checkedIn: String, forVisitId: String, checkOutLocation: String, latitude: String, longitude: String, chcekedOut: Bool, isCompleted: String, fromAppCompleted: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        
        let updateQuery = """
            UPDATE VisitsTable 
            SET checkedIn = ?, actualEnd = ?, checkOutLocation = ?, checkedOutGeolocationLatitude = ?, checkedOutGeolocationLongitude = ?, checkedOut = ?, createdAt = ?, isCompleted = ?, fromAppCompleted = ? 
            WHERE accountId = ?
        """
        guard let dbConnection = Database.databaseConnection else {
            print("Error: Database connection is nil.")
            completion(false, "Database connection is nil")
            return
        }
        if sqlite3_prepare_v2(dbConnection, updateQuery, -1, &statement, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
            return
        }
        sqlite3_bind_text(statement, 1, checkedIn, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, actualEnd, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 3, checkOutLocation, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 4, latitude, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 5, longitude, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 6, chcekedOut ? 1 : 0)
        sqlite3_bind_text(statement, 7, createdAt, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 8, isCompleted, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 9, fromAppCompleted, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 10, forVisitId, -1, SQLITE_TRANSIENT)
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Check-out data updated successfully for visitId: \(forVisitId)")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error executing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func updateContactDetails(accountId: String, contactPersonName: String, contactPhoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        
        let updateQuery = """
            UPDATE VisitsTable
            SET Contact_Person_Name__c = ?, Contact_Phone_Number__c = ?
            WHERE accountId = ?
        """
        
        guard let dbConnection = Database.databaseConnection else {
            print("Error: Database connection is nil.")
            completion(false, "Database connection is nil")
            return
        }
        
        if sqlite3_prepare_v2(dbConnection, updateQuery, -1, &statement, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
            return
        }
        sqlite3_bind_text(statement, 1, contactPersonName, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, contactPhoneNumber, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 3, accountId, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Contact details updated successfully for visitId: \(accountId)")
            completion(true, nil)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(dbConnection))
            print("Error executing update statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func fetchCheckedInVisits() -> [Visit] {
        var visits = [Visit]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM VisitsTable WHERE checkedIn = 1"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let accountReference = Visit.Account(
                    classification: String(cString: sqlite3_column_text(statement, 2)),
                    id: String(cString: sqlite3_column_text(statement, 3)),
                    name: String(cString: sqlite3_column_text(statement, 4)),
                    ownerId: String(cString: sqlite3_column_text(statement, 5)),
                    subChannel: String(cString: sqlite3_column_text(statement, 6))
                )
                
                let attributes = Visit.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 33)),
                    url: String(cString: sqlite3_column_text(statement, 34))
                )
                let visit = Visit(
                    localId: Int(sqlite3_column_int(statement, 0)),
                    accountId: String(cString: sqlite3_column_text(statement, 1)),
                    accountReference: accountReference,
                    actualEnd: String(cString: sqlite3_column_text(statement, 7)),
                    actualStart: String(cString: sqlite3_column_text(statement, 8)),
                    area: String(cString: sqlite3_column_text(statement, 9)),
                    beatRoute: String(cString: sqlite3_column_text(statement, 10)),
                    channel: String(cString: sqlite3_column_text(statement, 11)),
                    checkInLocation: String(cString: sqlite3_column_text(statement, 12)),
                    checkOutLocation: String(cString: sqlite3_column_text(statement, 13)),
                    checkedInLocationLatitude: String(cString: sqlite3_column_text(statement, 14)),
                    checkedInLocationLongitude: String(cString: sqlite3_column_text(statement, 15)),
                    checkedIn: Int(sqlite3_column_int(statement, 16)),
                    checkedOutGeolocationLatitude: String(cString: sqlite3_column_text(statement, 17)),
                    checkedOutGeolocationLongitude: String(cString: sqlite3_column_text(statement, 18)),
                    checkedOut: Int(sqlite3_column_int(statement, 19)),
                    empZone: String(cString: sqlite3_column_text(statement, 20)),
                    employeeCode: Int(sqlite3_column_int(statement, 21)),
                    id: String(cString: sqlite3_column_text(statement, 22)),
                    name: String(cString: sqlite3_column_text(statement, 23)),
                    oldPartyCode: String(cString: sqlite3_column_text(statement, 24)),
                    outletCreation: String(cString: sqlite3_column_text(statement, 25)),
                    outletType: String(cString: sqlite3_column_text(statement, 26)),
                    ownerId: String(cString: sqlite3_column_text(statement, 27)),
                    ownerArea: String(cString: sqlite3_column_text(statement, 28)),
                    partyCode: String(cString: sqlite3_column_text(statement, 29)),
                    remarks: String(cString: sqlite3_column_text(statement, 30)),
                    status: String(cString: sqlite3_column_text(statement, 31)),
                    visitPlanDate: String(cString: sqlite3_column_text(statement, 32)),
                    attributes: attributes,
                    isSync: String(cString: sqlite3_column_text(statement, 35)),
                    isCompleted: String(cString: sqlite3_column_text(statement, 36)),
                    createdAt: String(cString: sqlite3_column_text(statement, 37)),
                    isNew: Int(sqlite3_column_int(statement, 38)),
                    externalId: String(cString: sqlite3_column_text(statement, 39)),
                    fromAppCompleted: String(cString: sqlite3_column_text(statement, 40)),
                    Contact_Person_Name__c: String(cString: sqlite3_column_text(statement, 41)),
                    Contact_Phone_Number__c : String(cString: sqlite3_column_text(statement, 42))
                )
                visits.append(visit)
            }
            sqlite3_finalize(statement)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
        }
        return visits
    }
    
    func getVisitsWhereIsSyncZero() -> [Visit] {
        var resultArray = [Visit]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM VisitsTable WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let accountReference = Visit.Account(
                    classification: String(cString: sqlite3_column_text(statement, 2)),
                    id: String(cString: sqlite3_column_text(statement, 3)),
                    name: String(cString: sqlite3_column_text(statement, 4)),
                    ownerId: String(cString: sqlite3_column_text(statement, 5)),
                    subChannel: String(cString: sqlite3_column_text(statement, 6))
                )
                
                let attributes = Visit.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 33)),
                    url: String(cString: sqlite3_column_text(statement, 34))
                )
                
                let visit = Visit(
                    localId: Int(sqlite3_column_int(statement, 0)),
                    accountId: String(cString: sqlite3_column_text(statement, 1)),
                    accountReference: accountReference,
                    actualEnd: String(cString: sqlite3_column_text(statement, 7)),
                    actualStart: String(cString: sqlite3_column_text(statement, 8)),
                    area: String(cString: sqlite3_column_text(statement, 9)),
                    beatRoute: String(cString: sqlite3_column_text(statement, 10)),
                    channel: String(cString: sqlite3_column_text(statement, 11)),
                    checkInLocation: String(cString: sqlite3_column_text(statement, 12)),
                    checkOutLocation: String(cString: sqlite3_column_text(statement, 13)),
                    checkedInLocationLatitude: String(cString: sqlite3_column_text(statement, 14)),
                    checkedInLocationLongitude: String(cString: sqlite3_column_text(statement, 15)),
                    checkedIn: Int(sqlite3_column_int(statement, 16)),
                    checkedOutGeolocationLatitude: String(cString: sqlite3_column_text(statement, 17)),
                    checkedOutGeolocationLongitude: String(cString: sqlite3_column_text(statement, 18)),
                    checkedOut: Int(sqlite3_column_int(statement, 19)),
                    empZone: String(cString: sqlite3_column_text(statement, 20)),
                    employeeCode: Int(sqlite3_column_int(statement, 21)),
                    id: String(cString: sqlite3_column_text(statement, 22)),
                    name: String(cString: sqlite3_column_text(statement, 23)),
                    oldPartyCode: String(cString: sqlite3_column_text(statement, 24)),
                    outletCreation: String(cString: sqlite3_column_text(statement, 25)),
                    outletType: String(cString: sqlite3_column_text(statement, 26)),
                    ownerId: String(cString: sqlite3_column_text(statement, 27)),
                    ownerArea: String(cString: sqlite3_column_text(statement, 28)),
                    partyCode: String(cString: sqlite3_column_text(statement, 29)),
                    remarks: String(cString: sqlite3_column_text(statement, 30)),
                    status: String(cString: sqlite3_column_text(statement, 31)),
                    visitPlanDate: String(cString: sqlite3_column_text(statement, 32)),
                    attributes: attributes,
                    isSync: String(cString: sqlite3_column_text(statement, 35)),
                    isCompleted: String(cString: sqlite3_column_text(statement, 36)),
                    createdAt: String(cString: sqlite3_column_text(statement, 37)),
                    isNew: Int(sqlite3_column_int(statement, 38)),
                    externalId: String(cString: sqlite3_column_text(statement, 39)),
                    fromAppCompleted: String(cString: sqlite3_column_text(statement, 40)),
                    Contact_Person_Name__c: String(cString: sqlite3_column_text(statement, 41)),
                    Contact_Phone_Number__c : String(cString: sqlite3_column_text(statement, 42))
                )
                resultArray.append(visit)
            }
            sqlite3_finalize(statement)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
        }
        return resultArray
    }
    
    func updateSyncStatusForMultipleVisitIds(localIds: [Int]) {
        for localId in localIds {
            updateSyncStatusForVisit(localId: localId)
        }
    }
    
    func updateSyncStatusForVisit(localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE VisitsTable SET isSync = '1' WHERE localId = ?"
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
