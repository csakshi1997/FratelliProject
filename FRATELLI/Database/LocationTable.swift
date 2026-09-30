//
//  LocationTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation
import SQLite3

class LocationTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createLocationTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS LocationTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                isOfflineRecord INTEGER,
                latitude REAL,
                longitude REAL,
                diffrenceBetweenCurrentAndLastLatLong Real,
                address TEXT,
                isMockLocation INTEGER,
                dateTime TEXT,
                batteryPercentage INTEGER,
                deviceModel TEXT,
                deviceManufacturer TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating LocationTable")
        }
    }
    
    func saveLocation(location: LocationModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO LocationTable (isOfflineRecord, latitude, longitude, diffrenceBetweenCurrentAndLastLatLong, address, isMockLocation, dateTime, batteryPercentage, deviceModel, deviceManufacturer) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, location.isOfflineRecord ?? false ? 1 : 0)
            sqlite3_bind_double(statement, 2, location.latitude ?? 0)
            sqlite3_bind_double(statement, 3, location.longitude ?? 0.0)
            sqlite3_bind_double(statement, 4, location.diffrenceBetweenCurrentAndLastLatLong ?? 0.0)
            sqlite3_bind_text(statement, 5, location.address, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 6, Int32(location.isMockLocation ?? 0))
            sqlite3_bind_text(statement, 7, location.dateTime, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 8, Int32(location.batteryPercentage ?? 0))
            sqlite3_bind_text(statement, 9, location.deviceModel, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, location.deviceManufacturer, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting location: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Location inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
//    func getLocation() -> LocationModel {
//        var locationModel = LocationModel()
//        var statement: OpaquePointer?
//        let query = "SELECT * FROM LocationTable ORDER BY id ASC LIMIT 1"
//        
//        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
//            while sqlite3_step(statement) == SQLITE_ROW {
//                locationModel = LocationModel(
//                    id: Int(sqlite3_column_int(statement, 0)),
//                    isOfflineRecord: sqlite3_column_int(statement, 1) == 1,
//                    latitude: sqlite3_column_double(statement, 2),
//                    longitude: sqlite3_column_double(statement, 3),
//                    diffrenceBetweenCurrentAndLastLatLong: sqlite3_column_double(statement, 4),
//                    address: String(cString: sqlite3_column_text(statement, 5)),
//                    isMockLocation: Int(sqlite3_column_int(statement, 6)),
//                    dateTime: String(cString: sqlite3_column_text(statement, 7)),
//                    batteryPercentage: Int(sqlite3_column_int(statement, 8)),
//                    deviceModel: String(cString: sqlite3_column_text(statement, 9)),
//                    deviceManufacturer: String(cString: sqlite3_column_text(statement, 10))
//                )
//            }
//            sqlite3_finalize(statement)
//        } else {
//            print("Failed to prepare statement for fetching locations.")
//        }
//        return locationModel
//    }
    
    func getLocations(limit: Int) -> [LocationModel] {
        var locations: [LocationModel] = []
        var statement: OpaquePointer?

        let query = "SELECT * FROM LocationTable ORDER BY id ASC LIMIT \(limit)"

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {

                let location = LocationModel(
                    id: Int(sqlite3_column_int(statement, 0)),
                    isOfflineRecord: sqlite3_column_int(statement, 1) == 1,
                    latitude: sqlite3_column_double(statement, 2),
                    longitude: sqlite3_column_double(statement, 3),
                    diffrenceBetweenCurrentAndLastLatLong: sqlite3_column_double(statement, 4),
                    address: sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : "",
                    isMockLocation: Int(sqlite3_column_int(statement, 6)),
                    dateTime: sqlite3_column_text(statement, 7) != nil ? String(cString: sqlite3_column_text(statement, 7)) : "",
                    batteryPercentage: Int(sqlite3_column_int(statement, 8)),
                    deviceModel: sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)) : "",
                    deviceManufacturer: sqlite3_column_text(statement, 10) != nil ? String(cString: sqlite3_column_text(statement, 10)) : ""
                )

                locations.append(location)
            }

            sqlite3_finalize(statement)

        } else {
            print("Failed to prepare statement for fetching locations.")
        }

        return locations
    }
    
    func getLocationCount() -> Int {
        var count = 0
        var statement: OpaquePointer?

        let query = "SELECT COUNT(*) FROM LocationTable"

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
            sqlite3_finalize(statement)
        }

        return count
    }
    
    func deleteLocationsByIds(ids: [Int], completion: (Bool, String?) -> Void) {
        guard !ids.isEmpty else {
            completion(false, "No IDs provided")
            return
        }

        let idsString = ids.map { String($0) }.joined(separator: ",")

        let query = "DELETE FROM LocationTable WHERE id IN (\(idsString))"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                completion(true, nil)
            } else {
                completion(false, "Failed to delete records")
            }
            sqlite3_finalize(statement)
        } else {
            completion(false, "Failed to prepare delete statement")
        }
    }
    
    func deleteLocationById(id: Int, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let deleteQuery = "DELETE FROM LocationTable WHERE id = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Location deleted successfully")
                completion(true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error deleting location: \(errorMsg)")
                completion(false, errorMsg)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing delete statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        sqlite3_finalize(statement)
    }
}
