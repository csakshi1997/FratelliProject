//
//  OutletsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation
import UIKit
import SQLite3

class OutletsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createOutletsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS OutletsTable (
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
                createdAt TEXT,
                Asset_Visibility__c TEXT,
                Current_Market_Share__c TEXT
        
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating OutletsTable")
        }
    }
    
    func saveOutlet(outlet: Outlet, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO OutletsTable (accountId, accountStatus, annualTargetData, area, billingCity, billingCountry, billingCountryCode, billingState, billingStateCode, billingStreet, channel, checkedInLocationLatitude, checkedInLocationLongitude, classification, distributorCode, distributorName, distributorPartyCode, email, gstNo, groupName, growth, outletId, industry, lastVisitDate, licenseCode, license, marketShare, name, outletType, ownerId, ownerManager, panNo, partyCodeOld, partyCode, phone, salesType, salesmanCode, status, subChannelType, subChannel,supplierGroup, supplierManufacturerUnit, type,yearLastYear, years, zone, parentId, attributesType, attributesUrl, isSync, createdAt, Asset_Visibility__c, Current_Market_Share__c) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        
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
            sqlite3_bind_text(statement, 52, outlet.Asset_Visibility__c ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 53, outlet.Current_Market_Share__c ?? "", -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting outlet: \(errorMsg)")
                completion(false, errorMsg) 
            } else {
                print("Outlet inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getOutlets() -> [Outlet] {
        var resultArray = [Outlet]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM OutletsTable"
        
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
                
                let attributes = Outlet.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 52))
                let currentMarketShare = String(cString: sqlite3_column_text(statement, 53))
                let outlet = Outlet(
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
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentMarketShare
                )
                
                resultArray.append(outlet)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlets.")
        }
        
        return resultArray
    }
    
    func getOutletDataForVisit(visitName: String) -> Outlet? {
        var resultOutlet: Outlet? = nil
        var statement: OpaquePointer?
        
        let query = "SELECT * FROM OutletsTable WHERE visitName = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, visitName, -1, SQLITE_TRANSIENT)
            
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
                
                let attributes = Outlet.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 52))
                let currentMarketShare = String(cString: sqlite3_column_text(statement, 53))
                let outlet = Outlet(
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
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentMarketShare
                )
                resultOutlet = outlet
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlet by visitName.")
        }
        return resultOutlet
    }
    
    func getOutletData(forAccountId accountId: String? = nil, forVisitName visitName: String? = nil) -> Outlet? {
        var resultOutlet: Outlet? = nil
        var statement: OpaquePointer?
        
        var query = "SELECT * FROM OutletsTable WHERE"
        if let accountId = accountId {
            query += " accountId = ?"
        } else if let visitName = visitName {
            query += " visitName = ?"
        } else {
            print("Error: Either accountId or visitName must be provided.")
            return nil
        }
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            
            if let accountId = accountId {
                sqlite3_bind_text(statement, 1, accountId, -1, SQLITE_TRANSIENT)
            } else if let visitName = visitName {
                sqlite3_bind_text(statement, 1, visitName, -1, SQLITE_TRANSIENT)
            }
            
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
                
                let attributes = Outlet.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 52))
                let currentMarketShare = String(cString: sqlite3_column_text(statement, 53))
                let outlet = Outlet(
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
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentMarketShare
                )
                resultOutlet = outlet
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlet by accountId or visitName.")
        }
        return resultOutlet
    }
    
//    func getOutletsWithDetails() -> [Outlet] {
//        var resultArray = [Outlet]()
//        var statement: OpaquePointer?
//        let query = "SELECT B.*, A.* FROM VisitsTable A LEFT JOIN OutletsTable B ON A.accountId = B.accountId"
//        
//        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let localId = Int(sqlite3_column_int(statement, 0))
//                let accountId = String(cString: sqlite3_column_text(statement, 1))
//                let accountStatus = String(cString: sqlite3_column_text(statement, 2))
//                let annualTargetData = String(cString: sqlite3_column_text(statement, 3))
//                let area = String(cString: sqlite3_column_text(statement, 4))
//                let billingCity = String(cString: sqlite3_column_text(statement, 5))
//                let billingCountry = String(cString: sqlite3_column_text(statement, 6))
//                let billingCountryCode = String(cString: sqlite3_column_text(statement, 7))
//                let billingState = String(cString: sqlite3_column_text(statement, 8))
//                let billingStateCode = String(cString: sqlite3_column_text(statement, 9))
//                let billingStreet = String(cString: sqlite3_column_text(statement, 10))
//                let channel = String(cString: sqlite3_column_text(statement, 11))
//                let checkedInLocationLatitude = String(cString: sqlite3_column_text(statement, 12))
//                let checkedInLocationLongitude = String(cString: sqlite3_column_text(statement, 13))
//                let classification = String(cString: sqlite3_column_text(statement, 14))
//                let distributorCode = String(cString: sqlite3_column_text(statement, 15))
//                let distributorName = String(cString: sqlite3_column_text(statement, 16))
//                let distributorPartyCode = String(cString: sqlite3_column_text(statement, 17))
//                let email = String(cString: sqlite3_column_text(statement, 18))
//                let gstNo = String(cString: sqlite3_column_text(statement, 19))
//                let groupName = String(cString: sqlite3_column_text(statement, 20))
//                let growth = String(cString: sqlite3_column_text(statement, 21))
//                let id = String(cString: sqlite3_column_text(statement, 22))
//                let industry = String(cString: sqlite3_column_text(statement, 23))
//                let lastVisitDate = String(cString: sqlite3_column_text(statement, 24))
//                let licenseCode = String(cString: sqlite3_column_text(statement, 25))
//                let license = String(cString: sqlite3_column_text(statement, 26))
//                let marketShare = String(cString: sqlite3_column_text(statement, 27))
//                let name = String(cString: sqlite3_column_text(statement, 28))
//                let outletType = String(cString: sqlite3_column_text(statement, 29))
//                let ownerId = String(cString: sqlite3_column_text(statement, 30))
//                let ownerManager = String(cString: sqlite3_column_text(statement, 31))
//                let panNo = String(cString: sqlite3_column_text(statement, 32))
//                let partyCodeOld = String(cString: sqlite3_column_text(statement, 33))
//                let partyCode = String(cString: sqlite3_column_text(statement, 34))
//                let phone = String(cString: sqlite3_column_text(statement, 35))
//                let salesType = String(cString: sqlite3_column_text(statement, 36))
//                let salesmanCode = String(cString: sqlite3_column_text(statement, 37))
//                let status = Int(sqlite3_column_int(statement, 38))
//                let subChannelType = String(cString: sqlite3_column_text(statement, 39))
//                let subChannel = String(cString: sqlite3_column_text(statement, 40))
//                let supplierGroup = String(cString: sqlite3_column_text(statement, 41))
//                let supplierManufacturerUnit = String(cString: sqlite3_column_text(statement, 42))
//                let type = String(cString: sqlite3_column_text(statement, 43))
//                let yearLastYear = String(cString: sqlite3_column_text(statement, 44))
//                let years = String(cString: sqlite3_column_text(statement, 45))
//                let zone = String(cString: sqlite3_column_text(statement, 46))
//                
//                let attributes = Outlet.Attributes(
//                    type: String(cString: sqlite3_column_text(statement, 47)),
//                    url: String(cString: sqlite3_column_text(statement, 48))
//                )
//                let isSync = String(cString: sqlite3_column_text(statement, 49))
//                let checkIn = Int(sqlite3_column_int(statement, 62))
//                let createdAt = String(cString: sqlite3_column_text(statement, 63))
//                
//                let outlet = Outlet(
//                    localId: localId,
//                    accountId: accountId,
//                    accountStatus: accountStatus,
//                    annualTargetData: annualTargetData,
//                    area: area,
//                    billingCity: billingCity,
//                    billingCountry: billingCountry,
//                    billingCountryCode: billingCountryCode,
//                    billingState: billingState,
//                    billingStateCode: billingStateCode,
//                    billingStreet: billingStreet,
//                    channel: channel,
//                    checkedInLocationLatitude: checkedInLocationLatitude,
//                    checkedInLocationLongitude: checkedInLocationLongitude,
//                    classification: classification,
//                    distributorCode: distributorCode,
//                    distributorName: distributorName,
//                    distributorPartyCode: distributorPartyCode,
//                    email: email,
//                    gstNo: gstNo,
//                    groupName: groupName,
//                    growth: growth,
//                    id: id,
//                    industry: industry,
//                    lastVisitDate: lastVisitDate,
//                    licenseCode: licenseCode,
//                    license: license,
//                    marketShare: marketShare,
//                    name: name,
//                    outletType: outletType,
//                    ownerId: ownerId,
//                    ownerManager: ownerManager,
//                    panNo: panNo,
//                    partyCodeOld: partyCodeOld,
//                    partyCode: partyCode,
//                    phone: phone,
//                    salesType: salesType,
//                    salesmanCode: salesmanCode,
//                    status: status,
//                    subChannelType: subChannelType,
//                    subChannel: subChannel,
//                    supplierGroup: supplierGroup,
//                    supplierManufacturerUnit: supplierManufacturerUnit,
//                    type: type,
//                    yearLastYear: yearLastYear,
//                    years: years,
//                    zone: zone,
//                    attributes: attributes,
//                    isSync: isSync,
//                    checkIn: checkIn,
//                    createdAt: createdAt
//                )
//                resultArray.append(outlet)
//            }
//            
//            sqlite3_finalize(statement)
//        } else {
//            print("Error preparing query: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
//        }
//        
//        return resultArray
//    }
    
    
    func getOutletsWithDetails() -> [Outlet] {
        var resultArray = [Outlet]()
        var statement: OpaquePointer?
        let query = "SELECT B.*, A.* FROM VisitsTable A LEFT JOIN OutletsTable B ON A.accountId = B.accountId"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                func getStringValue(index: Int32) -> String {
                    return sqlite3_column_text(statement, index).flatMap { String(cString: $0) } ?? ""
                }
                func getIntValue(index: Int32) -> Int {
                    return Int(sqlite3_column_int(statement, index))
                }
                let localId = getIntValue(index: 0)
                let accountId = getStringValue(index: 1)
                let accountStatus = getStringValue(index: 2)
                let annualTargetData = getStringValue(index: 3)
                let area = getStringValue(index: 4)
                let billingCity = getStringValue(index: 5)
                let billingCountry = getStringValue(index: 6)
                let billingCountryCode = getStringValue(index: 7)
                let billingState = getStringValue(index: 8)
                let billingStateCode = getStringValue(index: 9)
                let billingStreet = getStringValue(index: 10)
                let channel = getStringValue(index: 11)
                let checkedInLocationLatitude = getStringValue(index: 12)
                let checkedInLocationLongitude = getStringValue(index: 13)
                let classification = getStringValue(index: 14)
                let distributorCode = getStringValue(index: 15)
                let distributorName = getStringValue(index: 16)
                let distributorPartyCode = getStringValue(index: 17)
                let email = getStringValue(index: 18)
                let gstNo = getStringValue(index: 19)
                let groupName = getStringValue(index: 20)
                let growth = getStringValue(index: 21)
                let id = getStringValue(index: 22)
                let industry = getStringValue(index: 23)
                let lastVisitDate = getStringValue(index: 24)
                let licenseCode = getStringValue(index: 25)
                let license = getStringValue(index: 26)
                let marketShare = getStringValue(index: 27)
                let name = getStringValue(index: 28)
                let outletType = getStringValue(index: 29)
                let ownerId = getStringValue(index: 30)
                let ownerManager = getStringValue(index: 31)
                let panNo = getStringValue(index: 32)
                let partyCodeOld = getStringValue(index: 33)
                let partyCode = getStringValue(index: 34)
                let phone = getStringValue(index: 35)
                let salesType = getStringValue(index: 36)
                let salesmanCode = getStringValue(index: 37)
                let status = getIntValue(index: 38)
                let subChannelType = getStringValue(index: 39)
                let subChannel = getStringValue(index: 40)
                let supplierGroup = getStringValue(index: 41)
                let supplierManufacturerUnit = getStringValue(index: 42)
                let type = getStringValue(index: 43)
                let yearLastYear = getStringValue(index: 44)
                let years = getStringValue(index: 45)
                let zone = getStringValue(index: 46)
                let parentId = getStringValue(index: 47)
                
                let attributes = Outlet.Attributes(
                    type: getStringValue(index: 48),
                    url: getStringValue(index: 49)
                )
                let isSync = getStringValue(index: 50)
                let checkIn = getIntValue(index: 62)
                let createdAt = getStringValue(index: 63)
                let assetVisibility = getStringValue(index: 64)
                let currentmarketShare = getStringValue(index: 65)
                
                let outlet = Outlet(
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
                    checkIn: checkIn,
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentmarketShare
                )
                resultArray.append(outlet)
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
        }
        
        return resultArray
    }
    
    
    
    
    func getOutletsByVisitIds(visitIds: [String]) -> [Outlet] {
        var resultArray = [Outlet]()
        var statement: OpaquePointer?
        
        let placeholders = visitIds.map { _ in "?" }.joined(separator: ", ")
        
        let query = "SELECT * FROM OutletsTable WHERE accountId IN (\(placeholders))"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            
            for (index, visitId) in visitIds.enumerated() {
                print("Binding visitId: \(visitId)")
                sqlite3_bind_text(statement, Int32(index + 1), visitId, -1, nil)
            }
            
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
                
                let attributes = Outlet.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 52))
                let currentMarketShare = String(cString: sqlite3_column_text(statement, 53))
                
                let outlet = Outlet(
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
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentMarketShare
                )
                
                resultArray.append(outlet)
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: \(String(cString: sqlite3_errmsg(Database.databaseConnection)))")
        }
        
        return resultArray
    }
    
    func getDataAccordingToIsSync() -> [Outlet] {
        var resultArray = [Outlet]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM OutletsTable WHERE isSync = 0"
        
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
                
                let attributes = Outlet.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 48)),
                    url: String(cString: sqlite3_column_text(statement, 49))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 50))
                let createdAt = String(cString: sqlite3_column_text(statement, 51))
                let assetVisibility = String(cString: sqlite3_column_text(statement, 52))
                let currentMarketShare = String(cString: sqlite3_column_text(statement, 53))
                let outlet = Outlet(
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
                    createdAt: createdAt,
                    Asset_Visibility__c: assetVisibility,
                    Current_Market_Share__c: currentMarketShare
                )
                
                resultArray.append(outlet)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching outlets.")
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
        let query = "UPDATE OutletsTable SET isSync = 1 WHERE localId = ?"
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

