//
//  RecommendationTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation
import SQLite3
import UIKit

class RecommendationsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createRecommendationsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS RecommendationsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                id TEXT UNIQUE,
                name TEXT,
                ownerId TEXT,
                productDescription TEXT,
                productNameId TEXT,
                productName TEXT,
                productImageLink TEXT,
                attributesType TEXT,
                attributesUrl TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating RecommendationsTable")
        }
    }
    
    func saveRecommendation(recommendation: Recommendation, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT OR REPLACE INTO RecommendationsTable (
                id, name, ownerId, productDescription, 
                productNameId, productName, productImageLink, 
                attributesType, attributesUrl
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, recommendation.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, recommendation.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, recommendation.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, recommendation.productDescription, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, recommendation.productNameId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, recommendation.productName?.name ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, recommendation.productName?.productImageLink ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, recommendation.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, recommendation.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting recommendation: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Recommendation inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
    
    func getRecommendations() -> [Recommendation] {
        var recommendations: [Recommendation] = []
        let query = """
            SELECT id, name, ownerId, productDescription, 
                   productNameId, productName, productImageLink, 
                   attributesType, attributesUrl
            FROM RecommendationsTable
        """
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let ownerId = String(cString: sqlite3_column_text(statement, 2))
                let productDescription = String(cString: sqlite3_column_text(statement, 3))
                let productNameId = String(cString: sqlite3_column_text(statement, 4))
                let productName = String(cString: sqlite3_column_text(statement, 5))
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
                let recommendationAttributes = Recommendation.Attributes(type: attributesType, url: attributesUrl)
                
                let recommendation = Recommendation(
                    id: id,
                    name: name,
                    ownerId: ownerId,
                    productDescription: productDescription,
                    productNameId: productNameId,
                    productName: product,
                    attributes: recommendationAttributes
                )
                recommendations.append(recommendation)
            }
        } else {
            print("Error fetching recommendations: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
        }
        
        sqlite3_finalize(statement)
        return recommendations
    }
}

