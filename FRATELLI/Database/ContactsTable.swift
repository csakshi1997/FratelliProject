//
//  ContactsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation
import UIKit
import SQLite3

class ContactsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    func createContactsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS ContactsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                contactId TEXT,
                aadharNo TEXT,
                firstName TEXT,
                middleName TEXT,
                lastName TEXT,
                email TEXT,
                phone TEXT,
                accountId TEXT,
                name TEXT,
                title TEXT,
                remark TEXT,
                ownerId TEXT,
                salutation TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT,
                workingWithOutlet TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating ContactsTable")
        }
        
        Database.alterTable(tableName: "ContactsTable", dictArray: [
            ["column": "Visit_Date_c", "defaultValue": ""],
            ["column": "Visit_Order_c", "defaultValue": ""],
            ["column": "External_id", "defaultValue": ""],
            
        ])
    }
    
    func saveContact(contact: Contact, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO ContactsTable (contactId, aadharNo, firstName, middleName, lastName, email, phone, accountId, name, title, remark, ownerId, salutation, attributesType, attributesUrl, isSync, workingWithOutlet, createdAt, Visit_Date_c, Visit_Order_c, External_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, contact.contactId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, contact.aadharNo ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, contact.firstName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, contact.middleName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, contact.lastName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, contact.email ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, contact.phone ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, contact.accountId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, contact.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, contact.title ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, contact.remark ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, contact.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, contact.salutation ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, contact.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, contact.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, contact.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 17, Int32(contact.workingWithOutlet ?? 0))
            sqlite3_bind_text(statement, 18, contact.createdAt ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, contact.Visit_Date_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, contact.Visit_Order_c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 21, contact.External_id ?? "", -1, SQLITE_TRANSIENT)

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
    
    func getContacts() -> [Contact] {
        var resultArray = [Contact]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ContactsTable"

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var contact = Contact()
                contact.localId = Int(sqlite3_column_int(statement, 0))
                contact.contactId = String(cString: sqlite3_column_text(statement, 1))
                contact.aadharNo = String(cString: sqlite3_column_text(statement, 2))
                contact.firstName = String(cString: sqlite3_column_text(statement, 3))
                contact.middleName = String(cString: sqlite3_column_text(statement, 4))
                contact.lastName = String(cString: sqlite3_column_text(statement, 5))
                contact.email = String(cString: sqlite3_column_text(statement, 6))
                contact.phone = String(cString: sqlite3_column_text(statement, 7))
                contact.accountId = String(cString: sqlite3_column_text(statement, 8))
                contact.name = String(cString: sqlite3_column_text(statement, 9))
                contact.title = String(cString: sqlite3_column_text(statement, 10))
                contact.remark = String(cString: sqlite3_column_text(statement, 11))
                contact.ownerId = String(cString: sqlite3_column_text(statement, 12))
                contact.salutation = String(cString: sqlite3_column_text(statement, 13))
                let attributesType = String(cString: sqlite3_column_text(statement, 14))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 15))
                contact.attributes = Contact.Attributes(type: attributesType, url: attributesUrl)
                contact.isSync = String(cString: sqlite3_column_text(statement, 16))
                contact.workingWithOutlet = Int(sqlite3_column_int(statement, 17))
                contact.createdAt = String(cString: sqlite3_column_text(statement, 18))
                contact.Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                contact.Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                contact.External_id = String(cString: sqlite3_column_text(statement, 21))
                resultArray.append(contact)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching contacts.")
        }
        
        return resultArray
    }
    
    func getContactsOnTheBasisOfAccountIds(forAccountId accountId: String) -> [Contact] {
        var resultArray = [Contact]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ContactsTable WHERE accountId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, accountId, -1, SQLITE_TRANSIENT)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                var contact = Contact()
                contact.localId = Int(sqlite3_column_int(statement, 0))
                contact.contactId = String(cString: sqlite3_column_text(statement, 1))
                contact.aadharNo = String(cString: sqlite3_column_text(statement, 2))
                contact.firstName = String(cString: sqlite3_column_text(statement, 3))
                contact.middleName = String(cString: sqlite3_column_text(statement, 4))
                contact.lastName = String(cString: sqlite3_column_text(statement, 5))
                contact.email = String(cString: sqlite3_column_text(statement, 6))
                contact.phone = String(cString: sqlite3_column_text(statement, 7))
                contact.accountId = String(cString: sqlite3_column_text(statement, 8))
                contact.name = String(cString: sqlite3_column_text(statement, 9))
                contact.title = String(cString: sqlite3_column_text(statement, 10))
                contact.remark = String(cString: sqlite3_column_text(statement, 11))
                contact.ownerId = String(cString: sqlite3_column_text(statement, 12))
                contact.salutation = String(cString: sqlite3_column_text(statement, 13))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 14))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 15))
                contact.attributes = Contact.Attributes(type: attributesType, url: attributesUrl)
                contact.isSync = String(cString: sqlite3_column_text(statement, 16))
                contact.workingWithOutlet = Int(sqlite3_column_int(statement, 17))
                contact.createdAt = String(cString: sqlite3_column_text(statement, 18))
                contact.Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                contact.Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                contact.External_id = String(cString: sqlite3_column_text(statement, 21))
                resultArray.append(contact)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching contacts based on accountId.")
        }
        
        return resultArray
    }
    
    func getContactsWhereIsSyncZero() -> [Contact] {
        var resultArray = [Contact]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ContactsTable WHERE isSync = '0'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var contact = Contact()
                contact.localId = Int(sqlite3_column_int(statement, 0))
                contact.contactId = String(cString: sqlite3_column_text(statement, 1))
                contact.aadharNo = String(cString: sqlite3_column_text(statement, 2))
                contact.firstName = String(cString: sqlite3_column_text(statement, 3))
                contact.middleName = String(cString: sqlite3_column_text(statement, 4))
                contact.lastName = String(cString: sqlite3_column_text(statement, 5))
                contact.email = String(cString: sqlite3_column_text(statement, 6))
                contact.phone = String(cString: sqlite3_column_text(statement, 7))
                contact.accountId = String(cString: sqlite3_column_text(statement, 8))
                contact.name = String(cString: sqlite3_column_text(statement, 9))
                contact.title = String(cString: sqlite3_column_text(statement, 10))
                contact.remark = String(cString: sqlite3_column_text(statement, 11))
                contact.ownerId = String(cString: sqlite3_column_text(statement, 12))
                contact.salutation = String(cString: sqlite3_column_text(statement, 13))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 14))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 15))
                contact.attributes = Contact.Attributes(type: attributesType, url: attributesUrl)
                contact.isSync = String(cString: sqlite3_column_text(statement, 16))
                contact.workingWithOutlet = Int(sqlite3_column_int(statement, 17))
                contact.createdAt = String(cString: sqlite3_column_text(statement, 18))
                contact.Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                contact.Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                contact.External_id = String(cString: sqlite3_column_text(statement, 21))
                
                resultArray.append(contact)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching contacts based on accountId.")
        }
        return resultArray
    }
    
    func getContactsWhereIsWorkingOutletsOne() -> [Contact] {
        var resultArray = [Contact]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ContactsTable WHERE workingWithOutlet = '1'"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var contact = Contact()
                contact.localId = Int(sqlite3_column_int(statement, 0))
                contact.contactId = String(cString: sqlite3_column_text(statement, 1))
                contact.aadharNo = String(cString: sqlite3_column_text(statement, 2))
                contact.firstName = String(cString: sqlite3_column_text(statement, 3))
                contact.middleName = String(cString: sqlite3_column_text(statement, 4))
                contact.lastName = String(cString: sqlite3_column_text(statement, 5))
                contact.email = String(cString: sqlite3_column_text(statement, 6))
                contact.phone = String(cString: sqlite3_column_text(statement, 7))
                contact.accountId = String(cString: sqlite3_column_text(statement, 8))
                contact.name = String(cString: sqlite3_column_text(statement, 9))
                contact.title = String(cString: sqlite3_column_text(statement, 10))
                contact.remark = String(cString: sqlite3_column_text(statement, 11))
                contact.ownerId = String(cString: sqlite3_column_text(statement, 12))
                contact.salutation = String(cString: sqlite3_column_text(statement, 13))
                
                let attributesType = String(cString: sqlite3_column_text(statement, 14))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 15))
                contact.attributes = Contact.Attributes(type: attributesType, url: attributesUrl)
                contact.isSync = String(cString: sqlite3_column_text(statement, 16))
                contact.workingWithOutlet = Int(sqlite3_column_int(statement, 17))
                contact.createdAt = String(cString: sqlite3_column_text(statement, 18))
                contact.Visit_Date_c = String(cString: sqlite3_column_text(statement, 19))
                contact.Visit_Order_c = String(cString: sqlite3_column_text(statement, 20))
                contact.External_id = String(cString: sqlite3_column_text(statement, 21))
                resultArray.append(contact)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching contacts based on accountId.")
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
        let query = "UPDATE ContactsTable SET isSync = '1' WHERE localId = ?"
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
    
    func updateWorkingWithOutleForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateWorkingWithOutletStatus(forLocalId: localId)
        }
    }
    
    func updateWorkingWithOutletStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE ContactsTable SET workingWithOutlet = '0' WHERE localId = ?"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated workingWithOutlet to 0 for localId: \(localId)")
            } else {
                print("Failed to update workingWithOutlet for localId: \(localId)")
            }
        } else {
            print("Failed to prepare statement for updating workingWithOutlet.")
        }
        sqlite3_finalize(statement)
    }
}
