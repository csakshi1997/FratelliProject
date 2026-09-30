//
//  OtherActivityTable.swift
//  FRATELLI
//
//  Created by Sakshi on 18/06/25.
//

import Foundation
import SQLite3

class OtherActivityTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    func createOtherActivityTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS OtherActivityTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                referenceId TEXT,
                attributesType TEXT,
                checkedOut INTEGER,
                checkedIn INTEGER,
                ownerId TEXT,
                actualStart TEXT,
                actualEnd TEXT,
                checkedInLat TEXT,
                checkedInLong TEXT,
                checkedOutLat TEXT,
                checkedOutLong TEXT,
                outletCreation TEXT,
                name TEXT,
                remark TEXT,
                deviceVersion TEXT,
                deviceType TEXT,
                deviceName TEXT,
                isSync TEXT
            );
        """

        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating OtherActivityTable")
        } else {
            print("✅ OtherActivityTable created or already exists.")
        }
    }

    func saveOtherActivity(_ activity: OtherActivityModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?

        let insertQuery = """
            INSERT INTO OtherActivityTable (
                referenceId, attributesType, checkedOut, checkedIn, ownerId, actualStart,
                actualEnd, checkedInLat, checkedInLong, checkedOutLat, checkedOutLong,
                outletCreation, name, remark, deviceVersion, deviceType, deviceName, isSync
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {

            func bindText(_ index: Int32, _ value: String?) {
                sqlite3_bind_text(statement, index, value ?? "", -1, SQLITE_TRANSIENT)
            }

            func bindBool(_ index: Int32, _ value: Bool?) {
                sqlite3_bind_int(statement, index, (value ?? false) ? 1 : 0)
            }

            bindText(1, activity.attributes?.referenceId)
            bindText(2, activity.attributes?.type)
            bindBool(3, activity.checkedOut)
            bindBool(4, activity.checkedIn)
            bindText(5, activity.ownerId)
            bindText(6, activity.actualStart)
            bindText(7, activity.actualEnd)
            bindText(8, activity.checkedInLat)
            bindText(9, activity.checkedInLong)
            bindText(10, activity.checkedOutLat)
            bindText(11, activity.checkedOutLong)
            bindText(12, activity.outletCreation)
            bindText(13, activity.name)
            bindText(14, activity.remark)
            bindText(15, activity.deviceVersion)
            bindText(16, activity.deviceType)
            bindText(17, activity.deviceName)
            bindText(18, activity.isSync)

            if sqlite3_step(statement) != SQLITE_DONE {
                let error = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("❌ Failed to insert OtherActivity: \(error)")
                completion(false, error)
            } else {
                print("✅ OtherActivity saved: \(activity.name ?? "Unnamed")")
                completion(true, nil)
            }

        } else {
            let error = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("❌ Prepare failed: \(error)")
            completion(false, error)
        }

        sqlite3_finalize(statement)
    }

    func getAllActivities() -> [OtherActivityModel] {
        var results: [OtherActivityModel] = []
        var statement: OpaquePointer?

        let selectQuery = "SELECT * FROM OtherActivityTable"

        if sqlite3_prepare_v2(Database.databaseConnection, selectQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let referenceId = String(cString: sqlite3_column_text(statement, 1))
                let attributesType = String(cString: sqlite3_column_text(statement, 2))
                let checkedOut = sqlite3_column_int(statement, 3) != 0
                let checkedIn = sqlite3_column_int(statement, 4) != 0
                let ownerId = String(cString: sqlite3_column_text(statement, 5))
                let actualStart = String(cString: sqlite3_column_text(statement, 6))
                let actualEnd = String(cString: sqlite3_column_text(statement, 7))
                let checkedInLat = String(cString: sqlite3_column_text(statement, 8))
                let checkedInLong = String(cString: sqlite3_column_text(statement, 9))
                let checkedOutLat = String(cString: sqlite3_column_text(statement, 10))
                let checkedOutLong = String(cString: sqlite3_column_text(statement, 11))
                let outletCreation = String(cString: sqlite3_column_text(statement, 12))
                let name = String(cString: sqlite3_column_text(statement, 13))
                let remark = String(cString: sqlite3_column_text(statement, 14))
                let deviceVersion = String(cString: sqlite3_column_text(statement, 15))
                let deviceType = String(cString: sqlite3_column_text(statement, 16))
                let deviceName = String(cString: sqlite3_column_text(statement, 17))
                let isSync = String(cString: sqlite3_column_text(statement, 18))

                let attributes = OtherActivityModel.Attributes(referenceId: referenceId, type: attributesType)

                let model = OtherActivityModel(
                    localId: localId,
                    attributes: attributes,
                    checkedOut: checkedOut,
                    checkedIn: checkedIn,
                    ownerId: ownerId,
                    actualStart: actualStart,
                    actualEnd: actualEnd,
                    checkedInLat: checkedInLat,
                    checkedInLong: checkedInLong,
                    checkedOutLat: checkedOutLat,
                    checkedOutLong: checkedOutLong,
                    outletCreation: outletCreation,
                    name: name,
                    remark: remark,
                    deviceVersion: deviceVersion,
                    deviceType: deviceType,
                    deviceName: deviceName,
                    isSync: isSync
                )
                results.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("❌ Failed to prepare SELECT query for OtherActivityTable.")
        }

        return results
    }
    
    func getOtherActivitiesWhereIsSyncZero() -> [OtherActivityModel] {
        var results: [OtherActivityModel] = []
        var statement: OpaquePointer?
        let query = "SELECT * FROM OtherActivityTable WHERE isSync = 0"

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let referenceId = String(cString: sqlite3_column_text(statement, 1))
                let attributesType = String(cString: sqlite3_column_text(statement, 2))
                let checkedOut = sqlite3_column_int(statement, 3) != 0
                let checkedIn = sqlite3_column_int(statement, 4) != 0
                let ownerId = String(cString: sqlite3_column_text(statement, 5))
                let actualStart = String(cString: sqlite3_column_text(statement, 6))
                let actualEnd = String(cString: sqlite3_column_text(statement, 7))
                let checkedInLat = String(cString: sqlite3_column_text(statement, 8))
                let checkedInLong = String(cString: sqlite3_column_text(statement, 9))
                let checkedOutLat = String(cString: sqlite3_column_text(statement, 10))
                let checkedOutLong = String(cString: sqlite3_column_text(statement, 11))
                let outletCreation = String(cString: sqlite3_column_text(statement, 12))
                let name = String(cString: sqlite3_column_text(statement, 13))
                let remark = String(cString: sqlite3_column_text(statement, 14))
                let deviceVersion = String(cString: sqlite3_column_text(statement, 15))
                let deviceType = String(cString: sqlite3_column_text(statement, 16))
                let deviceName = String(cString: sqlite3_column_text(statement, 17))
                let isSync = String(cString: sqlite3_column_text(statement, 18))

                let attributes = OtherActivityModel.Attributes(referenceId: referenceId, type: attributesType)

                let model = OtherActivityModel(
                    attributes: attributes,
                    checkedOut: checkedOut,
                    checkedIn: checkedIn,
                    ownerId: ownerId,
                    actualStart: actualStart,
                    actualEnd: actualEnd,
                    checkedInLat: checkedInLat,
                    checkedInLong: checkedInLong,
                    checkedOutLat: checkedOutLat,
                    checkedOutLong: checkedOutLong,
                    outletCreation: outletCreation,
                    name: name,
                    remark: remark,
                    deviceVersion: deviceVersion,
                    deviceType: deviceType,
                    deviceName: deviceName,
                    isSync: isSync
                )
                results.append(model)
            }
            sqlite3_finalize(statement)
        } else {
            print("❌ Failed to prepare SELECT query for unsynced OtherActivityTable.")
        }

        return results
    }
    
    func updateActivitySyncStatusForMultipleIds(localIds: [Int]) {
        for localId in localIds {
            updateActivitySyncStatus(forLocalId: localId)
        }
    }

    func updateActivitySyncStatus(forLocalId localId: Int) {
        var statement: OpaquePointer?
        let query = "UPDATE OtherActivityTable SET isSync = 1 WHERE localId = ?"

        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(localId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Updated isSync to 1 for OtherActivity localId: \(localId)")
            } else {
                print("❌ Failed to update isSync for OtherActivity localId: \(localId)")
            }
        } else {
            print("❌ Failed to prepare update for isSync in OtherActivityTable.")
        }

        sqlite3_finalize(statement)
    }
}
