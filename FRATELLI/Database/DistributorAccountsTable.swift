//
//  DistributorAccountsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 26/02/25.
//

import Foundation
import UIKit
import SQLite3

class DistributorAccountsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createOutletsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS DistributorAccountsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                accountId TEXT,
                accountStatus TEXT,
                annualTargetData TEXT,
                area TEXT,
                billingCity TEXT,
                billingCountry TEXT,
                billingCountryCode TEXT,
                billingState TEXT,
                billingStateCode TEXT,
                billingStreet TEXT,
                channel TEXT,
                checkedInLocationLatitude TEXT,
                checkedInLocationLongitude TEXT,
                classification TEXT,
                distributorCode TEXT,
                distributorName TEXT,
                distributorPartyCode TEXT,
                email TEXT,
                gstNo TEXT,
                groupName TEXT,
                growth TEXT,
                outletId TEXT,
                industry TEXT,
                lastVisitDate TEXT,
                licenseCode TEXT,
                license TEXT,
                marketShare TEXT,
                name TEXT,
                outletType TEXT,
                ownerId TEXT,
                ownerManager TEXT,
                panNo TEXT,
                partyCodeOld TEXT,
                partyCode TEXT,
                phone TEXT,
                salesType TEXT,
                salesmanCode TEXT,
                status INTEGER,
                subChannelType TEXT,
                subChannel TEXT,
                supplierGroup TEXT,
                supplierManufacturerUnit TEXT,
                type TEXT,
                yearLastYear TEXT,
                years TEXT,
                zone TEXT,
                parentId TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT,
                createdAt TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating OutletsTable")
        }
    }
    
    // Insert data into OutletsTable
    func saveDistribitorOutlet(outlet: DistributorAccountsModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO DistributorAccountsTable (accountId, accountStatus, annualTargetData, area, billingCity, billingCountry, billingCountryCode, billingState, billingStateCode, billingStreet, channel, checkedInLocationLatitude, checkedInLocationLongitude, classification, distributorCode, distributorName, distributorPartyCode, email, gstNo, groupName, growth, outletId, industry, lastVisitDate, licenseCode, license, marketShare, name, outletType, ownerId, ownerManager, panNo, partyCodeOld, partyCode, phone, salesType, salesmanCode, status, subChannelType, subChannel,supplierGroup, supplierManufacturerUnit, type,yearLastYear, years, zone, parentId, attributesType, attributesUrl, isSync, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, outlet.accountId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, outlet.accountStatus, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, outlet.annualTargetData ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, outlet.area ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, outlet.billingCity ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, outlet.billingCountry, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 7, outlet.billingCountryCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, outlet.billingState, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, outlet.billingStateCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 10, outlet.billingStreet ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 11, outlet.channel, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, outlet.checkedInLocationLatitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, outlet.checkedInLocationLongitude ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 14, outlet.classification, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 15, outlet.distributorCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, outlet.distributorName ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, outlet.distributorPartyCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, outlet.email ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, outlet.gstNo ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, outlet.groupName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 21, outlet.growth ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 22, outlet.id, -1, SQLITE_TRANSIENT) // Use outletId
            sqlite3_bind_text(statement, 23, outlet.industry ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 24, outlet.lastVisitDate ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 25, outlet.licenseCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 26, outlet.license ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 27, outlet.marketShare ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 28, outlet.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 29, outlet.outletType, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 30, outlet.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 31, outlet.ownerManager ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 32, outlet.panNo ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 33, outlet.partyCodeOld ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 34, outlet.partyCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 35, outlet.phone ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 36, outlet.salesType, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 37, outlet.salesmanCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 38, Int32(outlet.status ?? 0)) // Assuming status is an Int
            sqlite3_bind_text(statement, 39, outlet.subChannelType, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 40, outlet.subChannel, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 41, outlet.supplierGroup ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 42, outlet.supplierManufacturerUnit ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 43, outlet.type, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 44, outlet.yearLastYear ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 45, outlet.years ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 46, outlet.zone ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 47, outlet.parentId ?? "", -1, SQLITE_TRANSIENT)
            
            sqlite3_bind_text(statement, 48, outlet.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 49, outlet.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 50, outlet.isSync ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 51, outlet.createdAt ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting outlet: \(errorMsg)")
                completion(false, errorMsg) // Call completion with failure
            } else {
                print("Outlet inserted successfully")
                completion(true, nil) // Call completion with success
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg) // Call completion with failure
        }
        
        sqlite3_finalize(statement)
    }
    
    func getDistributorOutlets() -> [DistributorAccountsModel] {
        var resultArray = [DistributorAccountsModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM DistributorAccountsTable"
        print(Defaults.userArea)
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let accountId = String(cString: sqlite3_column_text(statement, 1))
                let accountStatus = String(cString: sqlite3_column_text(statement, 2))
                let annualTargetData = String(cString: sqlite3_column_text(statement, 3))
                let area = String(cString: sqlite3_column_text(statement, 4))
                let billingCity = String(cString: sqlite3_column_text(statement, 5))
                let billingCountry = String(cString: sqlite3_column_text(statement, 6))
                let billingCountryCode = String(cString: sqlite3_column_text(statement, 7))
                let billingState = String(cString: sqlite3_column_text(statement, 8))
                let billingStateCode = String(cString: sqlite3_column_text(statement, 9))
                let billingStreet = String(cString: sqlite3_column_text(statement, 10))
                let channel = String(cString: sqlite3_column_text(statement, 11))
                let checkedInLocationLatitude = String(cString: sqlite3_column_text(statement, 12))
                let checkedInLocationLongitude = String(cString: sqlite3_column_text(statement, 13))
                let classification = String(cString: sqlite3_column_text(statement, 14))
                let distributorCode = String(cString: sqlite3_column_text(statement, 15))
                let distributorName = String(cString: sqlite3_column_text(statement, 16))
                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 17))
                let email = String(cString: sqlite3_column_text(statement, 18))
                let gstNo = String(cString: sqlite3_column_text(statement, 19))
                let groupName = String(cString: sqlite3_column_text(statement, 20))
                let growth = String(cString: sqlite3_column_text(statement, 21))
                let id = String(cString: sqlite3_column_text(statement, 22))
                let industry = String(cString: sqlite3_column_text(statement, 23))
                let lastVisitDate = String(cString: sqlite3_column_text(statement, 24))
                let licenseCode = String(cString: sqlite3_column_text(statement, 25))
                let license = String(cString: sqlite3_column_text(statement, 26))
                let marketShare = String(cString: sqlite3_column_text(statement, 27))
                let name = String(cString: sqlite3_column_text(statement, 28))
                let outletType = String(cString: sqlite3_column_text(statement, 29))
                let ownerId = String(cString: sqlite3_column_text(statement, 30))
                let ownerManager = String(cString: sqlite3_column_text(statement, 31))
                let panNo = String(cString: sqlite3_column_text(statement, 32))
                let partyCodeOld = String(cString: sqlite3_column_text(statement, 33))
                let partyCode = String(cString: sqlite3_column_text(statement, 34))
                let phone = String(cString: sqlite3_column_text(statement, 35))
                let salesType = String(cString: sqlite3_column_text(statement, 36))
                let salesmanCode = String(cString: sqlite3_column_text(statement, 37))
                let status = Int(sqlite3_column_int(statement, 38))
                let subChannelType = String(cString: sqlite3_column_text(statement, 39))
                let subChannel = String(cString: sqlite3_column_text(statement, 40))
                let supplierGroup = String(cString: sqlite3_column_text(statement, 41))
                let supplierManufacturerUnit = String(cString: sqlite3_column_text(statement, 42))
                let type = String(cString: sqlite3_column_text(statement, 43))
                let yearLastYear = String(cString: sqlite3_column_text(statement, 44))
                let years = String(cString: sqlite3_column_text(statement, 45))
                let zone = String(cString: sqlite3_column_text(statement, 46))
                let parentId = String(cString: sqlite3_column_text(statement, 47))
                
                let attributes = DistributorAccountsModel.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let outlet = DistributorAccountsModel(
                    localId: localId,
                    accountId: accountId,
                    accountStatus: accountStatus,
                    annualTargetData: annualTargetData,
                    area: area,
                    billingCity: billingCity,
                    billingCountry: billingCountry,
                    billingCountryCode: billingCountryCode,
                    billingState: billingState,
                    billingStateCode: billingStateCode,
                    billingStreet: billingStreet,
                    channel: channel,
                    checkedInLocationLatitude: checkedInLocationLatitude,
                    checkedInLocationLongitude: checkedInLocationLongitude,
                    classification: classification,
                    distributorCode: distributorCode,
                    distributorName: distributorName,
                    distributorPartyCode: distributorPartyCode,
                    email: email,
                    gstNo: gstNo,
                    groupName: groupName,
                    growth: growth,
                    id: id,
                    industry: industry,
                    lastVisitDate: lastVisitDate,
                    licenseCode: licenseCode,
                    license: license,
                    marketShare: marketShare,
                    name: name,
                    outletType: outletType,
                    ownerId: ownerId,
                    ownerManager: ownerManager,
                    panNo: panNo,
                    partyCodeOld: partyCodeOld,
                    partyCode: partyCode,
                    phone: phone,
                    salesType: salesType,
                    salesmanCode: salesmanCode,
                    status: status,
                    subChannelType: subChannelType,
                    subChannel: subChannel,
                    supplierGroup: supplierGroup,
                    supplierManufacturerUnit: supplierManufacturerUnit,
                    type: type,
                    yearLastYear: yearLastYear,
                    years: years,
                    zone: zone,
                    parentId: parentId,
                    attributes: attributes,
                    isSync: isSync,
                    checkIn: 0,
                    createdAt: createdAt
                )
                
                resultArray.append(outlet)
            }
            print(statement)
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlets.")
        }
        
        return resultArray
    }
    
    func getOutletDataForVisit(visitName: String) -> DistributorAccountsModel? {
        var resultOutlet: DistributorAccountsModel? = nil
        var statement: OpaquePointer?
        
        // Modify the query to filter by visitName instead of accountId or any other field
        let query = "SELECT * FROM DistributorAccountsTable WHERE visitName = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            // Bind the visitName parameter to the query
            sqlite3_bind_text(statement, 1, visitName, -1, SQLITE_TRANSIENT)
            
            // Step through the result rows and fetch the data for the matching outlet
            if sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let accountId = String(cString: sqlite3_column_text(statement, 1))
                let accountStatus = String(cString: sqlite3_column_text(statement, 2))
                let annualTargetData = String(cString: sqlite3_column_text(statement, 3))
                let area = String(cString: sqlite3_column_text(statement, 4))
                let billingCity = String(cString: sqlite3_column_text(statement, 5))
                let billingCountry = String(cString: sqlite3_column_text(statement, 6))
                let billingCountryCode = String(cString: sqlite3_column_text(statement, 7))
                let billingState = String(cString: sqlite3_column_text(statement, 8))
                let billingStateCode = String(cString: sqlite3_column_text(statement, 9))
                let billingStreet = String(cString: sqlite3_column_text(statement, 10))
                let channel = String(cString: sqlite3_column_text(statement, 11))
                let checkedInLocationLatitude = String(cString: sqlite3_column_text(statement, 12))
                let checkedInLocationLongitude = String(cString: sqlite3_column_text(statement, 13))
                let classification = String(cString: sqlite3_column_text(statement, 14))
                let distributorCode = String(cString: sqlite3_column_text(statement, 15))
                let distributorName = String(cString: sqlite3_column_text(statement, 16))
                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 17))
                let email = String(cString: sqlite3_column_text(statement, 18))
                let gstNo = String(cString: sqlite3_column_text(statement, 19))
                let groupName = String(cString: sqlite3_column_text(statement, 20))
                let growth = String(cString: sqlite3_column_text(statement, 21))
                let id = String(cString: sqlite3_column_text(statement, 22))
                let industry = String(cString: sqlite3_column_text(statement, 23))
                let lastVisitDate = String(cString: sqlite3_column_text(statement, 24))
                let licenseCode = String(cString: sqlite3_column_text(statement, 25))
                let license = String(cString: sqlite3_column_text(statement, 26))
                let marketShare = String(cString: sqlite3_column_text(statement, 27))
                let name = String(cString: sqlite3_column_text(statement, 28))
                let outletType = String(cString: sqlite3_column_text(statement, 29))
                let ownerId = String(cString: sqlite3_column_text(statement, 30))
                let ownerManager = String(cString: sqlite3_column_text(statement, 31))
                let panNo = String(cString: sqlite3_column_text(statement, 32))
                let partyCodeOld = String(cString: sqlite3_column_text(statement, 33))
                let partyCode = String(cString: sqlite3_column_text(statement, 34))
                let phone = String(cString: sqlite3_column_text(statement, 35))
                let salesType = String(cString: sqlite3_column_text(statement, 36))
                let salesmanCode = String(cString: sqlite3_column_text(statement, 37))
                let status = Int(sqlite3_column_int(statement, 38))
                let subChannelType = String(cString: sqlite3_column_text(statement, 39))
                let subChannel = String(cString: sqlite3_column_text(statement, 40))
                let supplierGroup = String(cString: sqlite3_column_text(statement, 41))
                let supplierManufacturerUnit = String(cString: sqlite3_column_text(statement, 42))
                let type = String(cString: sqlite3_column_text(statement, 43))
                let yearLastYear = String(cString: sqlite3_column_text(statement, 44))
                let years = String(cString: sqlite3_column_text(statement, 45))
                let zone = String(cString: sqlite3_column_text(statement, 46))
                let parentId = String(cString: sqlite3_column_text(statement, 47))
                
                let attributes = DistributorAccountsModel.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let outlet = DistributorAccountsModel(
                    localId: localId,
                    accountId: accountId,
                    accountStatus: accountStatus,
                    annualTargetData: annualTargetData,
                    area: area,
                    billingCity: billingCity,
                    billingCountry: billingCountry,
                    billingCountryCode: billingCountryCode,
                    billingState: billingState,
                    billingStateCode: billingStateCode,
                    billingStreet: billingStreet,
                    channel: channel,
                    checkedInLocationLatitude: checkedInLocationLatitude,
                    checkedInLocationLongitude: checkedInLocationLongitude,
                    classification: classification,
                    distributorCode: distributorCode,
                    distributorName: distributorName,
                    distributorPartyCode: distributorPartyCode,
                    email: email,
                    gstNo: gstNo,
                    groupName: groupName,
                    growth: growth,
                    id: id,
                    industry: industry,
                    lastVisitDate: lastVisitDate,
                    licenseCode: licenseCode,
                    license: license,
                    marketShare: marketShare,
                    name: name,
                    outletType: outletType,
                    ownerId: ownerId,
                    ownerManager: ownerManager,
                    panNo: panNo,
                    partyCodeOld: partyCodeOld,
                    partyCode: partyCode,
                    phone: phone,
                    salesType: salesType,
                    salesmanCode: salesmanCode,
                    status: status,
                    subChannelType: subChannelType,
                    subChannel: subChannel,
                    supplierGroup: supplierGroup,
                    supplierManufacturerUnit: supplierManufacturerUnit,
                    type: type,
                    yearLastYear: yearLastYear,
                    years: years,
                    zone: zone,
                    parentId: parentId,
                    attributes: attributes,
                    isSync: isSync,
                    checkIn: 0,
                    createdAt: createdAt
                    
                )
                
                resultOutlet = outlet
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlet by visitName.")
        }
        
        return resultOutlet
    }
    
    func getOutletData(forAccountId accountId: String? = nil, forVisitName visitName: String? = nil) -> DistributorAccountsModel? {
        var resultOutlet: DistributorAccountsModel? = nil
        var statement: OpaquePointer?
        
        // Prepare the query based on which parameter is provided (accountId or visitName)
        var query = "SELECT * FROM DistributorAccountsTable WHERE"
        if let accountId = accountId {
            query += " accountId = ?"
        } else if let visitName = visitName {
            query += " visitName = ?"
        } else {
            print("Error: Either accountId or visitName must be provided.")
            return nil
        }
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            
            // Bind the parameter based on whether accountId or visitName is passed
            if let accountId = accountId {
                sqlite3_bind_text(statement, 1, accountId, -1, SQLITE_TRANSIENT)
            } else if let visitName = visitName {
                sqlite3_bind_text(statement, 1, visitName, -1, SQLITE_TRANSIENT)
            }
            
            // Step through the result rows and fetch the data for the matching outlet
            if sqlite3_step(statement) == SQLITE_ROW {
                let localId = Int(sqlite3_column_int(statement, 0))
                let accountId = String(cString: sqlite3_column_text(statement, 1))
                let accountStatus = String(cString: sqlite3_column_text(statement, 2))
                let annualTargetData = String(cString: sqlite3_column_text(statement, 3))
                let area = String(cString: sqlite3_column_text(statement, 4))
                let billingCity = String(cString: sqlite3_column_text(statement, 5))
                let billingCountry = String(cString: sqlite3_column_text(statement, 6))
                let billingCountryCode = String(cString: sqlite3_column_text(statement, 7))
                let billingState = String(cString: sqlite3_column_text(statement, 8))
                let billingStateCode = String(cString: sqlite3_column_text(statement, 9))
                let billingStreet = String(cString: sqlite3_column_text(statement, 10))
                let channel = String(cString: sqlite3_column_text(statement, 11))
                let checkedInLocationLatitude = String(cString: sqlite3_column_text(statement, 12))
                let checkedInLocationLongitude = String(cString: sqlite3_column_text(statement, 13))
                let classification = String(cString: sqlite3_column_text(statement, 14))
                let distributorCode = String(cString: sqlite3_column_text(statement, 15))
                let distributorName = String(cString: sqlite3_column_text(statement, 16))
                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 17))
                let email = String(cString: sqlite3_column_text(statement, 18))
                let gstNo = String(cString: sqlite3_column_text(statement, 19))
                let groupName = String(cString: sqlite3_column_text(statement, 20))
                let growth = String(cString: sqlite3_column_text(statement, 21))
                let id = String(cString: sqlite3_column_text(statement, 22))
                let industry = String(cString: sqlite3_column_text(statement, 23))
                let lastVisitDate = String(cString: sqlite3_column_text(statement, 24))
                let licenseCode = String(cString: sqlite3_column_text(statement, 25))
                let license = String(cString: sqlite3_column_text(statement, 26))
                let marketShare = String(cString: sqlite3_column_text(statement, 27))
                let name = String(cString: sqlite3_column_text(statement, 28))
                let outletType = String(cString: sqlite3_column_text(statement, 29))
                let ownerId = String(cString: sqlite3_column_text(statement, 30))
                let ownerManager = String(cString: sqlite3_column_text(statement, 31))
                let panNo = String(cString: sqlite3_column_text(statement, 32))
                let partyCodeOld = String(cString: sqlite3_column_text(statement, 33))
                let partyCode = String(cString: sqlite3_column_text(statement, 34))
                let phone = String(cString: sqlite3_column_text(statement, 35))
                let salesType = String(cString: sqlite3_column_text(statement, 36))
                let salesmanCode = String(cString: sqlite3_column_text(statement, 37))
                let status = Int(sqlite3_column_int(statement, 38))
                let subChannelType = String(cString: sqlite3_column_text(statement, 39))
                let subChannel = String(cString: sqlite3_column_text(statement, 40))
                let supplierGroup = String(cString: sqlite3_column_text(statement, 41))
                let supplierManufacturerUnit = String(cString: sqlite3_column_text(statement, 42))
                let type = String(cString: sqlite3_column_text(statement, 43))
                let yearLastYear = String(cString: sqlite3_column_text(statement, 44))
                let years = String(cString: sqlite3_column_text(statement, 45))
                let zone = String(cString: sqlite3_column_text(statement, 46))
                let parentId = String(cString: sqlite3_column_text(statement, 47))
                
                let attributes = DistributorAccountsModel.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                // Create an Outlet object with the fetched data
                let outlet = DistributorAccountsModel(
                    localId: localId,
                    accountId: accountId,
                    accountStatus: accountStatus,
                    annualTargetData: annualTargetData,
                    area: area,
                    billingCity: billingCity,
                    billingCountry: billingCountry,
                    billingCountryCode: billingCountryCode,
                    billingState: billingState,
                    billingStateCode: billingStateCode,
                    billingStreet: billingStreet,
                    channel: channel,
                    checkedInLocationLatitude: checkedInLocationLatitude,
                    checkedInLocationLongitude: checkedInLocationLongitude,
                    classification: classification,
                    distributorCode: distributorCode,
                    distributorName: distributorName,
                    distributorPartyCode: distributorPartyCode,
                    email: email,
                    gstNo: gstNo,
                    groupName: groupName,
                    growth: growth,
                    id: id,
                    industry: industry,
                    lastVisitDate: lastVisitDate,
                    licenseCode: licenseCode,
                    license: license,
                    marketShare: marketShare,
                    name: name,
                    outletType: outletType,
                    ownerId: ownerId,
                    ownerManager: ownerManager,
                    panNo: panNo,
                    partyCodeOld: partyCodeOld,
                    partyCode: partyCode,
                    phone: phone,
                    salesType: salesType,
                    salesmanCode: salesmanCode,
                    status: status,
                    subChannelType: subChannelType,
                    subChannel: subChannel,
                    supplierGroup: supplierGroup,
                    supplierManufacturerUnit: supplierManufacturerUnit,
                    type: type,
                    yearLastYear: yearLastYear,
                    years: years,
                    zone: zone,
                    parentId: parentId,
                    attributes: attributes,
                    isSync: isSync,
                    checkIn: 0,
                    createdAt: createdAt
                )
                
                resultOutlet = outlet
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlet by accountId or visitName.")
        }
        
        return resultOutlet
    }
    
}

