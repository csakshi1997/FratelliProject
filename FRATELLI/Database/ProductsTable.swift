//
//  ProductsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation
import SQLite3

class ProductsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createProductsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS ProductsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                abbreviation TEXT,
                bottleCan TEXT,
                bottleSize TEXT,
                brandCode TEXT,
                category TEXT,
                conversionRatio INTEGER,
                createdDate TEXT,
                gst TEXT,
                id TEXT UNIQUE,
                isDeleted INTEGER,
                itemType TEXT,
                name TEXT,
                ownerId TEXT,
                priority INTEGER,
                productCategory TEXT,
                productCode TEXT,
                productFamily TEXT,
                productId TEXT,
                productType TEXT,
                sizeCode TEXT,
                sizeInMl INTEGER,
                type TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating ProductsTable")
        }
    }
    
    func saveProduct(product: Product, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT OR REPLACE INTO ProductsTable (
                abbreviation, bottleCan, bottleSize, brandCode,
                category, conversionRatio, createdDate, gst,
                id, isDeleted, itemType, name,
                ownerId, priority, productCategory, productCode,
                productFamily, productId, productType, sizeCode,
                sizeInMl, type, attributesType, attributesUrl, isSync
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            
            func bindText(_ index: Int32, _ value: String?) {
                sqlite3_bind_text(statement, index, value ?? "", -1, SQLITE_TRANSIENT)
            }
            
            func bindInt(_ index: Int32, _ value: Int?) {
                sqlite3_bind_int(statement, index, Int32(value ?? 0))
            }
            
            func bindDouble(_ index: Int32, _ value: Double?) {
                sqlite3_bind_double(statement, index, value ?? 0.0)
            }
            
            bindText(1, product.abbreviation)
            bindText(2, product.bottleCan)
            bindText(3, product.bottleSize)
            bindText(4, product.brandCode)
            bindText(5, product.category)
            bindInt(6, product.conversionRatio)
            bindText(7, product.createdDate)
            bindText(8, product.gst)
            bindText(9, product.id)
            sqlite3_bind_int(statement, 10, (product.isDeleted ?? false) ? 1 : 0)
            bindText(11, product.itemType)
            bindText(12, product.name)
            bindText(13, product.ownerId)
            bindInt(14, product.priority)
            bindText(15, product.productCategory)
            bindText(16, product.productCode)
            bindText(17, product.productFamily)
            bindText(18, product.productId)
            bindText(19, product.productType)
            bindText(20, product.sizeCode)
            bindInt(21, product.sizeInMl)
            bindText(22, product.type)
            bindText(23, product.attributes?.type)
            bindText(24, product.attributes?.url)
            bindText(25, product.isSync)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("""
                🔴 Insert failed for Product:
                ID: \(product.id ?? "nil"), Name: \(product.name ?? "nil")
                Error: \(errorMsg)
                """)
                completion(false, errorMsg)
            } else {
                print("✅ Saved: \(product.name ?? "Unnamed") (\(product.id ?? "nil"))")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("🔴 Failed to prepare insert: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getProducts() -> [Product] {
        var resultArray = [Product]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ProductsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let abbreviation = String(cString: sqlite3_column_text(statement, 1))
                let bottleCan = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
                let bottleSize = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : nil
                let brandCode = String(cString: sqlite3_column_text(statement, 4))
                let category = String(cString: sqlite3_column_text(statement, 5))
                let conversionRatio = Int(sqlite3_column_int(statement, 6))
                let createdDate = String(cString: sqlite3_column_text(statement, 7))
                let gst = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : nil
                let id = String(cString: sqlite3_column_text(statement, 9))
                let isDeleted = sqlite3_column_int(statement, 10) != 0
                let itemType = String(cString: sqlite3_column_text(statement, 11))
                let name = String(cString: sqlite3_column_text(statement, 12))
                let ownerId = String(cString: sqlite3_column_text(statement, 13))
                let priority = Int(sqlite3_column_int(statement, 14))
                let productCategory = sqlite3_column_text(statement, 15) != nil ? String(cString: sqlite3_column_text(statement, 15)) : nil
                let productCode = sqlite3_column_text(statement, 16) != nil ? String(cString: sqlite3_column_text(statement, 16)) : nil
                let productFamily = sqlite3_column_text(statement, 17) != nil ? String(cString: sqlite3_column_text(statement, 17)) : nil
                let productId = String(cString: sqlite3_column_text(statement, 18))
                let productType = sqlite3_column_text(statement, 19) != nil ? String(cString: sqlite3_column_text(statement, 19)) : nil
                let sizeCode = String(cString: sqlite3_column_text(statement, 20))
                let sizeInMl = Int(sqlite3_column_int(statement, 21))
                let type = String(cString: sqlite3_column_text(statement, 22))
                
                let attributes = Product.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 23)),
                    url: String(cString: sqlite3_column_text(statement, 24))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 25))
                
                let product = Product(
                    abbreviation: abbreviation,
                    bottleCan: bottleCan,
                    bottleSize: bottleSize,
                    brandCode: brandCode,
                    category: category,
                    conversionRatio: conversionRatio,
                    createdDate: createdDate,
                    gst: gst,
                    id: id,
                    isDeleted: isDeleted,
                    itemType: itemType,
                    name: name,
                    ownerId: ownerId,
                    priority: priority,
                    productCategory: productCategory,
                    productCode: productCode,
                    productFamily: productFamily,
                    productId: productId,
                    productType: productType,
                    sizeCode: sizeCode,
                    sizeInMl: sizeInMl,
                    type: type,
                    attributes: attributes,
                    isSync: isSync
                )
                
                resultArray.append(product)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching products.")
        }
        return resultArray
    }
}

