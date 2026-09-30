//
//  PromotionsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import Foundation
import Foundation
import SQLite3

import SQLite3

class PromotionsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    func createPromotionsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS PromotionsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                id TEXT UNIQUE,
                name TEXT,
                ownerId TEXT,
                productNameId TEXT,
                productName TEXT,
                productDescription TEXT,
                productImageLink TEXT,
                attributesType TEXT,
                attributesUrl TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating PromotionsTable: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
        }
    }

    func savePromotion(promotion: Promotion, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT OR REPLACE INTO PromotionsTable (
                id, name, ownerId, productNameId, 
                productName, productDescription, 
                productImageLink, attributesType, attributesUrl
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, promotion.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, promotion.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, promotion.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, promotion.productNameId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, promotion.productName?.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, promotion.productDescription, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, promotion.productName?.productImageLink, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, promotion.attributes?.type, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, promotion.attributes?.url, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting promotion: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Promotion inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }

    func getPromotions() -> [Promotion] {
        var promotions: [Promotion] = []
        let query = """
            SELECT id, name, ownerId, productNameId, 
                   productName, productDescription, 
                   productImageLink, attributesType, attributesUrl
            FROM PromotionsTable
        """
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let ownerId = String(cString: sqlite3_column_text(statement, 2))
                let productNameId = String(cString: sqlite3_column_text(statement, 3))
                let productName = String(cString: sqlite3_column_text(statement, 4))
                let productDescription = String(cString: sqlite3_column_text(statement, 5))
                let productImageLink = String(cString: sqlite3_column_text(statement, 6))
                let attributesType = String(cString: sqlite3_column_text(statement, 7))
                let attributesUrl = String(cString: sqlite3_column_text(statement, 8))
                
                let productAttributes = ProductName.Attributes(type: attributesType, url: attributesUrl)
                
                let product = ProductName(
                    id: productNameId,
                    name: productName,
                    productDescription: nil,
                    productImageLink: productImageLink,
                    attributes: productAttributes
                )
                
                let promotionAttributes = Promotion.Attributes(type: attributesType, url: attributesUrl)
                
                let promotion = Promotion(
                    id: id,
                    name: name,
                    ownerId: ownerId,
                    productDescription: productDescription,
                    productNameId: productNameId,
                    productName: product,
                    attributes: promotionAttributes
                )
                promotions.append(promotion)
            }
        } else {
            print("Error fetching promotions: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
        }
        
        sqlite3_finalize(statement)
        return promotions
    }
}
