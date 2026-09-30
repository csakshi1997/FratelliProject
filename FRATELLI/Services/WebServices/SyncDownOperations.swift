//
//  SyncDownOperations.swift
//  FRATELLI
//
//  Created by Sakshi on 29/11/24.
//

import Foundation
import UIKit
import Photos

class SyncDownOperations {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    let dateFormatter = DateFormatter()
    let outletsTable = OutletsTable()
    let rQCRTable = RQCRTable()
    let contactsTable = ContactsTable()
    let riskStockTable = RiskStockTable()
    let advocacyTable = AdvocacyTable()
    let riskStockLineItemsTable = RiskStockLineItemsTable()
    let pOSMTable = POSMTable()
    let pOSMLineItemsTable = POSMLineItemsTable()
    let allVisibilityTable = AllVisibilityTable()
    let addNewTaskTable = AddNewTaskTable()
    let visitsTable = VisitsTable()
    let skipTable = SkipTable()
    let otherActivityTable = OtherActivityTable()
    let salesOrderTable = SalesOrderTable()
    let salesOrderLineItemsTable = SalesOrderLineItemsTable()
    let visibilityServerTable = VisibilityServerTable()
    let assetRequisitionServerTable = AssetRequisitionServerTable()
    var completionhandler: (String) -> Void = {_ in }
    var customDateFormatter = CustomDateFormatter()
    var appVersionOperation = AppVersionOperation()
    var qCROperation = QCROperation()
    let uploader = UploadFileToServer()
    
    func syncInDataForAccount() {
        var outlets = [Outlet]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        outlets = outletsTable.getDataAccordingToIsSync()
        if !(outlets.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, outlet) in outlets.enumerated() {
                let outletPayload: [String: Any] = [
                    "Name": outlet.name ?? "",
                    "License_Code__c": outlet.licenseCode ?? EMPTY,
                    "ParentId": EMPTY,
                    "Zone__c": EMPTY,
                    "Area__c": EMPTY,
                    "Type": "Retail",
                    "City__c": outlet.billingCity ?? EMPTY,
                    "Channel__c": outlet.channel ?? EMPTY,
                    "Sub_Channel__c": outlet.subChannel ?? EMPTY,
                    "Classification__c": outlet.classification ?? EMPTY,
                    "Created_TimeStamp__c": outlet.createdAt ?? EMPTY,
                    "OwnerId": outlet.ownerId ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Account"
                    ]
                ]
                recordsArray.append(outletPayload)
                localIds.append(outlet.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            executeSyncForAccount(localId: localIds, param: payload, syncType: "Account", syncName: "Outlet Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    self.reportSyncError(
                        objectName: "Account",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForRQCR()
                    }
                } else {
                    print("Successfully synced Account:")
                    self.syncInDataForRQCR()
                }
            }
        } else {
            syncInDataForRQCR()
        }
    }
    
    func executeSyncForAccount(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_ACCOUNT)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Outlet Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.outletsTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForRQCR()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForRQCR() {
        var rQCRModel = [RQCRModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        rQCRModel = rQCRTable.getRQCRsWhereIsSyncZero()
        if !(rQCRModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, rQCRData) in rQCRModel.enumerated() {
                let outletPayload: [String: Any] = [
                    "External_ID__c": rQCRData.externalId ?? "",
                    "Regional_Sales_Person__c": rQCRData.regionalSalesPerson,
                    "Territory_Sales_Person_In_Charge__c": rQCRData.territorySalesPersonInCharge,
                    "Date_of_Grievances__c": rQCRData.dateOfGrievances,
                    "Location_Details__c": rQCRData.locationDetails,
                    "Can_Bottle__c": rQCRData.canBottle,
                    "Concern_Details__c": rQCRData.concernDetails,
                    "Complaint__c": rQCRData.concernDetails,
                    "Brand_Name__c": rQCRData.brandName,
                    "Particular_Brand_Closing_Stock_Received__c": rQCRData.particularBrandClosingStockReceived,
                    "Stock_Details__c": rQCRData.stockDetails,
                    "Manufacturing_Date__c": rQCRData.manufacturingDate,
                    "Debit_Note_Cost__c": rQCRData.debitNoteCost,
                    "Defected_Quantity__c": rQCRData.defectedQuantity,
                    "Remark__c": rQCRData.remark,
                    "Created_TimeStamp__c": rQCRData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "QCR__c"
                    ]
                ]
                recordsArray.append(outletPayload)
                localIds.append(rQCRData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            executeSyncForQCR(localId: localIds, param: payload, syncType: "QCR__c", syncName: "QCR Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "QCR__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForAdvocacyReq()
                    }
                } else {
                    print("Successfully synced QCR:")
                    self.syncInDataForAdvocacyReq()
                }
            }
            
        } else {
            self.syncInDataForAdvocacyReq()
        }
    }
    
    func executeSyncForQCR(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_QCR)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post QCR Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            
            if let results = responseData["results"] as? [[String: Any]] {
                self.rQCRTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForAdvocacyReq()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForAdvocacyReq() {
        var advocacyRequest = [AdvocacyRequest]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        advocacyRequest = advocacyTable.getAdvocacyRequestsWhereIsSyncZero()
        if !(advocacyRequest.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, advocacyRequestData) in advocacyRequest.enumerated() {
                let advocacyRequestPayload: [String: Any] = [
                    "External_ID__c": advocacyRequestData.ExternalId ?? EMPTY,
                    "Outlet_Name__c": advocacyRequestData.outerId ?? EMPTY,
                    "Advocacy_Date__c": advocacyRequestData.advocacyDate ?? EMPTY,
                    "Product_Name__c": advocacyRequestData.productId ?? EMPTY,
                    "PAX__c": advocacyRequestData.pax ?? EMPTY,
                    "Created_TimeStamp__c": advocacyRequestData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Advocacy_Request__c"
                    ]
                ]
                recordsArray.append(advocacyRequestPayload)
                localIds.append(advocacyRequestData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            executeSyncForAdvocacyReq(localId: localIds, param: payload, syncType: "Advocacy_Request__c", syncName: "Advocacy_Request__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Advocacy_Request__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForAdvocacyReq()
                    }
                }else {
                    print("Successfully synced Advocacy_Request__c:")
                    self.syncInDataForContact()
                }
                
            }
        } else {
            self.syncInDataForContact()
        }
    }
    
    func executeSyncForAdvocacyReq(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_ADVOCACY_REQUEST)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Contact Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.contactsTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForContact()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForContact() {
        var contact = [Contact]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        contact = contactsTable.getContactsWhereIsSyncZero()
        if !(contact.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, contactData) in contact.enumerated() {
                let contactPayload: [String: Any] = [
                    "AccountId": contactData.accountId ?? EMPTY,
                    "Salutation": contactData.salutation ?? EMPTY,
                    "FirstName": contactData.firstName ?? EMPTY,
                    "LastName": contactData.lastName ?? EMPTY,
                    "Title": contactData.title ?? EMPTY,
                    "Phone": contactData.phone ?? EMPTY,
                    "Email": contactData.email ?? EMPTY,
                    "Created_TimeStamp__c": contactData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "Visit_Date__c": contactData.Visit_Date_c ?? EMPTY,
                    "Visit_Order__c": contactData.Visit_Order_c ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Contact"
                    ]
                ]
                recordsArray.append(contactPayload)
                localIds.append(contactData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload Contact: \(payload)")
            executeSyncForContact(localId: localIds, param: payload, syncType: "Contact", syncName: "Contact Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Contact",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForAdvocacyReq()
                    }
                } else {
                    print("Successfully synced Contact:")
                    self.syncInDataForRiskStock()
                }
                
            }
        } else {
            self.syncInDataForRiskStock()
        }
    }
    
    func executeSyncForContact(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.CONATCT)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Contact Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.contactsTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForRiskStock()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForRiskStock() {
        var riskStock = [RiskStock]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        riskStock = riskStockTable.getRiskStocksWhereIsSyncZero()
        if !(riskStock.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, riskStockData) in riskStock.enumerated() {
                let riskStockDataPayload: [String: Any] = [
                    "External_ID__c": riskStockData.externalid ?? EMPTY,
                    "Initiate_the_Customer_Promotion__c": riskStockData.isInitiateCustomerPromotion ?? EMPTY,
                    "Risk_Stock_Outlet_Name__c": riskStockData.outletId ?? EMPTY,
                    "Remarks__c": riskStockData.remarks ?? EMPTY,
                    "Created_TimeStamp__c": riskStockData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "Visit_Date__c": riskStockData.Visit_Date_c ?? EMPTY,
                    "Visit_Order__c": riskStockData.Visit_Order_c ?? EMPTY,
                    "Outlet_Name__c": riskStockData.outletId ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Risk_Stock__c"
                    ]
                ]
                recordsArray.append(riskStockDataPayload)
                localIds.append(riskStockData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload Risk_Stock__c: \(payload)")
            executeSyncForRiskStock(localId: localIds, param: payload, syncType: "Risk_Stock__c", syncName: "Risk_Stock__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Risk_Stock__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForRiskStockLineItems()
                    }
                } else {
                    print("Successfully synced Risk_Stock__c:")
                    self.syncInDataForRiskStockLineItems()
                }
                
            }
        } else {
            self.syncInDataForRiskStockLineItems()
        }
    }
    
    func executeSyncForRiskStock(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_RISK_STOCKS)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Risk_Stock__c Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.riskStockTable.updateRiskStockSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForRiskStockLineItems()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForRiskStockLineItems() {
        var riskStockLineItem = [RiskStockLineItem]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        riskStockLineItem = riskStockLineItemsTable.getRiskStockLineItemsWhereIsSyncZero()
        if !(riskStockLineItem.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, riskStockLineItemData) in riskStockLineItem.enumerated() {
                let riskStockLineItemkDataPayload: [String: Any] = [
                    "Product_Name__c": riskStockLineItemData.Product_Name__c ?? "",
                    "Outlet_Stock_In_Btls__c": riskStockLineItemData.Outlet_Stock_In_Btls__c ?? "",
                    "Risk_Stock_In_Btls__c": riskStockLineItemData.Risk_Stock_In_Btls__c ?? "",
                    "Created_TimeStamp__c": riskStockLineItemData.createdAt ?? "",
                    "External_ID__c": riskStockLineItemData.externalid ?? "",
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Risk_Stock_Line_Item__c"
                    ]
                ]
                recordsArray.append(riskStockLineItemkDataPayload)
                localIds.append(riskStockLineItemData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            executeSyncForRiskStockLineItems(localId: localIds, param: payload, syncType: "Risk_Stock_Line_Item__c", syncName: "Risk_Stock_Line_Item__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Risk_Stock_Line_Item__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForPOSMReq()
                    }
                } else {
                    print("Successfully synced Risk_Stock_Line_Item__c:")
                    self.syncInDataForPOSMReq()
                }
            }
        } else {
            self.syncInDataForPOSMReq()
        }
    }
    
    func executeSyncForRiskStockLineItems(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_RISK_STOCK_LINE_ITEMS)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Risk_Stock_Line_Item__c Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.riskStockLineItemsTable.updateRiskStockLineItemSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForPOSMReq()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForPOSMReq() {
        var pOSMModel = [POSMModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        pOSMModel = pOSMTable.getPOSMsWhereIsSyncZero()
        if !(pOSMModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, pOSMModelData) in pOSMModel.enumerated() {
                let pOSMModelDataPayload: [String: Any] = [
                    "External_ID__c": pOSMModelData.ExternalId ?? EMPTY,
                    "Outlet_Name__c": pOSMModelData.outerId ?? EMPTY,
                    "Created_TimeStamp__c": pOSMModelData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "Visit__c": pOSMModelData.Visit_Order_c ?? EMPTY,
                    "Visit_Date__c": pOSMModelData.Visit_Date_c ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "POSM__c"
                    ]
                ]
                recordsArray.append(pOSMModelDataPayload)
                localIds.append(pOSMModelData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload POSM__c: \(payload)")
            executeSyncForPOSMReq(localId: localIds, param: payload, syncType: "POSM__c", syncName: "POSM__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "POSM__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForPOSMLineItems()
                    }
                } else {
                    print("Successfully synced POSM__c:")
                    self.syncInDataForPOSMLineItems()
                }
                
            }
        } else {
            self.syncInDataForPOSMLineItems()
        }
    }
    
    func executeSyncForPOSMReq(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_POSM_REQUEST)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post POSM__c Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.pOSMTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForPOSMLineItems()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForPOSMLineItems() {
        var pOSMLineItemsModel = [POSMLineItemsModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        pOSMLineItemsModel = pOSMLineItemsTable.getPOSMLineItemsWhereIsSyncZero()
        if !(pOSMLineItemsModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, pOSMLineItemsModelData) in pOSMLineItemsModel.enumerated() {
                let pOSMLineItemsModelDataDataPayload: [String: Any] = [
                    "External_ID__c": pOSMLineItemsModelData.ExternalId ?? EMPTY,
                    "POSM_Asset_name__c": pOSMLineItemsModelData.PosmItemId ?? EMPTY,
                    "Quantity__c": pOSMLineItemsModelData.Quantity__c ?? EMPTY,
                    "Created_TimeStamp__c": pOSMLineItemsModelData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "POSM_Line_Item__c"
                    ]
                ]
                recordsArray.append(pOSMLineItemsModelDataDataPayload)
                localIds.append(pOSMLineItemsModelData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            executeSyncForPOSMLineItems(localId: localIds, param: payload, syncType: "POSM_Line_Item__c", syncName: "POSM_Line_Item__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    // Log the error
                    self.reportSyncError(
                        objectName: "POSM_Line_Item__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForSalesOrder()
                    }
                } else {
                    print("Successfully synced POSM_Line_Item__c:")
                    self.syncInDataForSalesOrder()
                }
            }
        } else {
            self.syncInDataForSalesOrder()
        }
    }
    
    func executeSyncForPOSMLineItems(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_POSM_LINE_ITEMS_REQUEST)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Risk_Stock_Line_Item__c Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.pOSMLineItemsTable.updateSyncStatusForMultiplePOSMLineItems(localIds: localId)
                self.syncInDataForSalesOrder()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForSalesOrder() {
        var salesOrderModel = [SalesOrderModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        salesOrderModel = salesOrderTable.getAdhocSalesOrdersWhereIsSyncZero()
        if !(salesOrderModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, salesOrderData) in salesOrderModel.enumerated() {
                let salesOrderDataPayload: [String: Any] = [
                    "External_ID__c": salesOrderData.External_Id__c ?? EMPTY,
                    "Bulk_Upload__c": salesOrderData.Bulk_Upload__c,
                    "Customer__c": salesOrderData.Customer__Id ?? EMPTY,
                    "Distributor__c": salesOrderData.Distributor__Id ?? EMPTY,
                    "Order_Booking_Data__c": salesOrderData.dateTime ?? EMPTY,
                    "Remarks__c": salesOrderData.addRemark ?? EMPTY,
                    "Status__c": "Submitted",
                    "Created_TimeStamp__c": salesOrderData.createdAt ?? EMPTY,
                    "OwnerId": Defaults.userId ?? EMPTY,
                    "Visit_Date__c": salesOrderData.Visit_Date_c ?? EMPTY,
                    "Visit_Order__c": salesOrderData.Visit_Order_c ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Sales_Order__c"
                    ]
                ]
                recordsArray.append(salesOrderDataPayload)
                localIds.append(salesOrderData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("Sales_Order__c payload: \(payload)")
            executeSyncForSalesOrder(localId: localIds, param: payload, syncType: "Sales_Order__c", syncName: "Sales_Order__c Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Sales_Order__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForSalesOrderLineItems()
                    }
                } else {
                    print("Successfully synced Sales_Order__c:")
                    self.syncInDataForSalesOrderLineItems()
                }
            }
        } else {
            self.syncInDataForSalesOrderLineItems()
        }
    }
    
    func executeSyncForSalesOrder(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_SALES_ORDER)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Sales_Order__c Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.salesOrderTable.updateSyncStatusForMultipleIds(localIds: localId)
                self.syncInDataForSalesOrderLineItems()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForSalesOrderLineItems() {
        var salesOrderLineItems = [SalesOrderLineItems]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        salesOrderLineItems = salesOrderLineItemsTable.getSalesOrderLineItemsWhereIsSyncZero()
        if !(salesOrderLineItems.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, salesOrderLineItemsData) in salesOrderLineItems.enumerated() {
                let salesOrderLineItemsDataPayload: [String: Any] = [
                    "External_ID__c": salesOrderLineItemsData.External_Id__c ?? EMPTY,
                    "Product__c": salesOrderLineItemsData.Product__ID ?? EMPTY,
                    "Scheme_Type__c": salesOrderLineItemsData.Scheme_Type__c ?? EMPTY,
                    "Scheme_Percentage__c": salesOrderLineItemsData.Scheme_Percentage__c ?? EMPTY,
                    "Quantity__c": salesOrderLineItemsData.Product_quantity_c ?? EMPTY,
                    "Free_Issue_Quantity_In_Btls__c": salesOrderLineItemsData.Free_Issue_Quantity_In_Btls__c ?? EMPTY,
                    "Total_Amount_INR__c": salesOrderLineItemsData.Total_Amount_INR__c ?? EMPTY,
                    "Created_TimeStamp__c": salesOrderLineItemsData.createdAt ?? EMPTY,
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Order_Item__c"
                    ]
                ]
                recordsArray.append(salesOrderLineItemsDataPayload)
                localIds.append(salesOrderLineItemsData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("Order_Item__c payload: \(payload)")
            executeSyncForSalesOrderLineItems(localId: localIds, param: payload, syncType: "Order_Item__c", syncName: "Order_Item__c Sync") { error, response, status in
                if let error = error {
                    print(status)
                    print(response)
                    print(error)
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Order_Item__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForAddNewTasks()
                    }
                } else {
                    print("Successfully synced Order_Item__c:")
                    self.syncInDataForAddNewTasks()
                }
                
            }
        } else {
            self.syncInDataForAddNewTasks()
        }
    }
    
    func executeSyncForSalesOrderLineItems(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_SALES_ORDER_LINE_ITEMS)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Order_Item__c Table Data ")
            print(result)
            print(statusCode)
            print(val)
            print(error )
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                print(results)
                self.salesOrderLineItemsTable.updateSyncStatusForMultipleLocalIds(localIds: localId)
                self.syncInDataForAddNewTasks()
            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForAddNewTasks() {
        var addNewTaskModel = [AddNewTaskModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        addNewTaskModel = addNewTaskTable.getTasksWhereIsSyncZero()
        print(addNewTaskModel)
        if !(addNewTaskModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, addNewTaskModelData) in addNewTaskModel.enumerated() {
                let addNewTaskModelDataPayload: [String: Any] = [
                    "External_ID__c": addNewTaskModelData.External_Id__c ?? "",
                    "WhatId": addNewTaskModelData.OutletId ?? "",
                    "Subject": addNewTaskModelData.TaskSubject ?? "",
                    "Status": "Open",
                    "Priority": "Normal",
                    "Settlement_Data__c": customDateFormatter.getDateForSettlement(dateString: addNewTaskModelData.createdAt ?? ""),
                    "Created_TimeStamp__c": addNewTaskModelData.createdAt ?? "",
                    "OwnerId": Defaults.userId ?? "",
                    "Visit_Date__c": addNewTaskModelData.Visit_Date_c ?? "",
                    "Visit_Order__c": addNewTaskModelData.Visit_Order_c ?? "",
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Task"
                    ]
                ]
                recordsArray.append(addNewTaskModelDataPayload)
                localIds.append(addNewTaskModelData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload Add New tasks: \(payload)")
            executeSyncForAddNewTasks(localId: localIds, param: payload, syncType: "Add New tasks", syncName: "Contact Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    
                    
                    // Get current timestamp
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    // Log the error
                    self.reportSyncError(
                        objectName: "Task",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForSkip()
                    }
                }   else {
                    print("Successfully synced Contact:")
                    self.syncInDataForSkip()
                }
                
            }
        } else {
            self.syncInDataForSkip()
        }
    }
    
    func executeSyncForAddNewTasks(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_ACTION_ITEMS)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post Add New tasks Table Data ")
            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            if let results = responseData["results"] as? [[String: Any]] {
                self.addNewTaskTable.updateSyncStatusForMultipleTaskIds(localIds: localId)
                self.syncInDataForSkip()
            } else {
                _ = "No records found in the response"
            }
        }
    }
    
    func syncInDataForSkip() {
        var skipModel = [SkipModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        skipModel = skipTable.getSkipEntriesWhereIsSyncZero()
        if !(skipModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, skipModelData) in skipModel.enumerated() {
                let skipModelDataPayload: [String: Any] = [
                    "Dealer_Distributor_CORP__c": skipModelData.Dealer_Distributor_CORP__c ?? "",
                    "OwnerId": Defaults.userId ?? "",
                    "Meet_Greet__c": skipModelData.Meet_Greet__c == "1" ? true : false,
                    "Risk_Stock__c": skipModelData.Risk_Stock__c == "1" ? true : false,
                    "Asset_Visibility__c": skipModelData.Asset_Visibility__c == "1" ? true : false,
                    "POSM_Request__c": skipModelData.POSM_Request__c == "1" ? true : false,
                    "Sales_Order__c": skipModelData.Sales_Order__c == "1" ? true : false,
                    "QCR__c": skipModelData.QCR__c == "1" ? true : false,
                    "Follow_up_task__c": skipModelData.Follow_up_task__c == "1" ? true : false,
                    "Device_Type__c": "iOS",
                    "Device_Name__c": UIDevice.current.name,
                    "Device_Version__c": appVersionOperation.getCurrentAppVersion() ?? "",
                    "Visit_Date__c": skipModelData.Visit_Date_c ?? "",
                    "Visit_Order__c": skipModelData.Visit_Order_c ?? "",
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Outlet_Adherance_Report__c"
                    ]
                ]
                recordsArray.append(skipModelDataPayload)
                localIds.append(skipModelData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload Skip tasks: \(payload)")
            executeSyncForSkip(localId: localIds, param: payload, syncType: "Skip", syncName: "Skip Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing outlet: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    self.reportSyncError(
                        objectName: "Outlet_Adherance_Report__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForOtherActivity()
                    }
                } else {
                    print("Successfully synced Skip tasks:")
                    self.syncInDataForOtherActivity()
                }
            }
        } else {
            self.syncInDataForOtherActivity()
        }
    }
    
    func executeSyncForSkip(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_SKIP)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post syncType Table Data ")

            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }

            if let results = responseData["results"] as? [[String: Any]] {
                var hasRecordLevelError = false
                var aggregatedErrorMessages = [String]()

                for record in results {
                    if let errors = record["errors"] as? [[String: Any]], !errors.isEmpty {
                        hasRecordLevelError = true
                        for errorObj in errors {
                            if let message = errorObj["message"] as? String {
                                aggregatedErrorMessages.append(message)
                            }
                        }
                    }
                }

                if hasRecordLevelError {
                    let fullErrorMessage = aggregatedErrorMessages.joined(separator: "; ")
                    outerClosure(fullErrorMessage, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
                } else {
                    self.skipTable.updateSyncStatusForMultipleSkipIds(localIds: localId)
                    self.syncInDataForOtherActivity()
                }

            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForOtherActivity() {
        var otherActivityModel = [OtherActivityModel]()
        var localIds = [Int]()
        var recordsArray = [[String: Any]]()
        otherActivityModel = otherActivityTable.getOtherActivitiesWhereIsSyncZero()
        if !(otherActivityModel.isEmpty) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            for (index, otherActivityModelData) in otherActivityModel.enumerated() {
                let otherActivityModelDataPayload: [String: Any] = [
                    "Checked_Out__c": otherActivityModelData.checkedOut ?? EMPTY,
                    "Checked_In__c": otherActivityModelData.checkedIn ?? EMPTY,
                    "ownerId": Defaults.userId ?? EMPTY,
                    "Actual_Start__c": otherActivityModelData.actualStart ?? EMPTY,
                    "Actual_End__c": otherActivityModelData.actualEnd ?? EMPTY,
                    "Checked_In_Location__Latitude__s": otherActivityModelData.checkedInLat ?? EMPTY,
                    "Checked_In_Location__Longitude__s": otherActivityModelData.checkedInLong ?? EMPTY,
                    "Checked_Out_Geolocation__Latitude__s": otherActivityModelData.checkedOutLat ?? EMPTY,
                    "Checked_Out_Geolocation__Longitude__s": otherActivityModelData.checkedOutLong ?? EMPTY,
                    "Outlet_Creation__c": "Other Activity",
                    "name": otherActivityModelData.name ?? EMPTY,
                    "Remark_s__c": otherActivityModelData.remark ?? EMPTY,
                    "Device_Version__c": self.appVersionOperation.getCurrentAppVersion() ?? "",
                    "Device_Type__c": "iOS",
                    "Device_Name__c": UIDevice.current.name,
                    "attributes": [
                      "referenceId": "ref\(index)",
                      "type": "Visits__c"
                    ]
                ]
                recordsArray.append(otherActivityModelDataPayload)
                localIds.append(otherActivityModelData.localId ?? 0)
            }
            let payload: [String: Any] = [
                "records": recordsArray
            ]
            print("payload SEND_OTHER_ACTIVITIES tasks: \(payload)")
            executeSyncForOtherActivity(localId: localIds, param: payload, syncType: "SEND_OTHER_ACTIVITIES", syncName: "SEND_OTHER_ACTIVITIES Sync") { error, response, status in
                if let error = error {
                    print("❌ Error syncing SEND_OTHER_ACTIVITIES: \(error)")
                    print("📦 Payload that caused error: \(payload)")
                    let issueDateTime = self.dateFormatter.string(from: Date())
                    
                    self.reportSyncError(
                        objectName: "Visits__c",
                        errorMessage: error,
                        errorBody: payload,
                        Issue_DateTime__c: issueDateTime
                    ) {
                        self.syncInDataForVisibility()
                    }
                } else {
                    print("Successfully synced SEND_OTHER_ACTIVITIES tasks:")
                    self.syncInDataForVisibility()
                }
            }
        } else {
            self.syncInDataForVisibility()
        }
    }
    
    func executeSyncForOtherActivity(localId: [Int], param: [String : Any], syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.SEND_OTHER_ACTIVITIES)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post SEND_OTHER_ACTIVITIES Table Data ")

            guard let responseData = result as? [String: Any] else {
                let errorMessage = "Invalid response format"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }

            if let results = responseData["results"] as? [[String: Any]] {
                var hasRecordLevelError = false
                var aggregatedErrorMessages = [String]()

                for record in results {
                    if let errors = record["errors"] as? [[String: Any]], !errors.isEmpty {
                        hasRecordLevelError = true
                        for errorObj in errors {
                            if let message = errorObj["message"] as? String {
                                aggregatedErrorMessages.append(message)
                            }
                        }
                    }
                }

                if hasRecordLevelError {
                    let fullErrorMessage = aggregatedErrorMessages.joined(separator: "; ")
                    outerClosure(fullErrorMessage, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
                } else {
                    self.otherActivityTable.updateActivitySyncStatusForMultipleIds(localIds: localId)
                    self.syncInDataForVisibility()
                }

            } else {
                let errorMessage = "No records found in the response"
                outerClosure(errorMessage, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func syncInDataForVisibility() {
        let allVisibilityModel = visibilityServerTable.getUnsyncedRecords()
        guard !allVisibilityModel.isEmpty else {
            self.syncInDataForAssetVisibility()
            return
        }

        func syncNext(index: Int) {
            if index >= allVisibilityModel.count {
                print("✅ All visibility items synced")
                self.syncInDataForAssetVisibility()
                return
            }

            let item = allVisibilityModel[index]
            let localId = Int(item.localId ?? 0)
            let fileName = item.fileName ?? ""
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            print(fileName)
            print(fileURL)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("❌ File not found for LocalId \(localId): \(fileName)")
                syncNext(index: index + 1)
                return
            }

            do {
                let fileData = try Data(contentsOf: fileURL)

                let mimeType: String
                if fileName.lowercased().hasSuffix(".pdf") {
                    mimeType = "application/pdf"
                } else if fileName.lowercased().hasSuffix(".jpg") || fileName.lowercased().hasSuffix(".jpeg") {
                    mimeType = "image/jpeg"
                } else if fileName.lowercased().hasSuffix(".png") {
                    mimeType = "image/png"
                } else {
                    mimeType = "application/octet-stream"
                }
                print(mimeType)
                UploadFileToServer().uploadFileToServer(
                    userId: item.dealerDistributorCorpId ?? EMPTY,
                    fileData: fileData,
                    fileName: fileName,
                    mimeType: mimeType
                ) { success, responseURL in
                    DispatchQueue.main.async {
                        guard success, let publicUrl = responseURL else {
                            print("❌ Upload failed for LocalId: \(localId)")
                            syncNext(index: index + 1)
                            return
                        }

                        self.visibilityServerTable.updatePublicURL(forLocalId: localId, url: publicUrl)

                        var updatedItem = item
                        updatedItem.imagePublicUrl = publicUrl
                        let payload = self.buildSalesforceImagePayload(from: updatedItem)

                        self.sendToSalesforce(payload: payload) { sfSuccess in
                            if sfSuccess {
                                self.visibilityServerTable.updateSyncStatus(forLocalId: localId)
                                print("✅ Synced to Salesforce for LocalId: \(localId)")
                            } else {
                                print("❌ Salesforce sync failed for LocalId: \(localId)")
                            }
                            syncNext(index: index + 1)
                        }
                    }
                }
            } catch {
                print("❌ File read error for LocalId \(localId): \(error.localizedDescription)")
                syncNext(index: index + 1)
            }
        }
        syncNext(index: 0)
    }

    func buildSalesforceImagePayload(from model: VisibilityServerModel) -> [String: Any] {
        let attributes: [String: Any] = [
            "referenceId": "ref1",
            "type": "Image_Visibility__c"
        ]
        
        let record: [String: Any] = [
            "attributes": attributes,
            "OwnerId": model.userId ?? "",
            "Asset_name__c": "Asset Visibility.\(model.assetName ?? "")",
            "External_Id__c": model.externalId ?? "",
            "Dealer_Distributor_CORP__c": model.dealerDistributorCorpId ?? "",
            "Device_Name__c": model.deviceName ?? "",
            "Device_Version__c": model.deviceVersion ?? "",
            "Device_Type__c": model.deviceType ?? "",
            "Image_Url__c": model.imagePublicUrl ?? "",
            "Visit_Order__c": model.visitOrderId ?? ""
        ]
        print("VisibilityServerModel VisibilityServerModel \(record)")
        return ["records": [record]]
    }
    
    func sendToSalesforce(payload: [String: Any], completion: @escaping (Bool) -> Void) {
        print("📤 Payload to Salesforce:\n\(payload)")
        print("🌍 URL:\(apiUrl)\(endPoint.SALESFORCE_IMAGE_UPLOAD)")
        
        webRequest.processRequestUsingPostMethod(
            url: "\(apiUrl)\(endPoint.SALESFORCE_IMAGE_UPLOAD)",
            parameters: payload,
            showLoader: true,
            contentType: .json
        ) { error, val, result, statusCode in
            
            if let error = error {
                print("❌ Salesforce API error:", error)
                completion(false)
                return
            }
            
            guard let responseData = result as? [String: Any] else {
                print("❌ Invalid Salesforce response")
                completion(false)
                return
            }
            
            print("📦 Raw Salesforce response:\n\(responseData)")
            if let hasErrorsAny = responseData["hasErrors"] {
                let hasErrors: Bool
                if let boolValue = hasErrorsAny as? Bool {
                    hasErrors = boolValue
                } else if let intValue = hasErrorsAny as? Int {
                    hasErrors = intValue != 0
                } else {
                    hasErrors = true
                }
                
                if let results = responseData["results"] as? [[String: Any]] {
                    if !hasErrors {
                        print("✅ Salesforce sync SUCCESS")
                        for result in results {
                            if let id = result["id"] as? String {
                                print("📌 Salesforce record ID: \(id)")
                            }
                        }
                        completion(true)
                    } else {
                        print("❌ Salesforce reported errors")
                        for result in results {
                            if let errors = result["errors"] as? [[String: Any]] {
                                for error in errors {
                                    print("Salesforce error message:", error["message"] ?? "Unknown error")
                                }
                            }
                        }
                        completion(false)
                    }
                    return
                }
            }
        }
    }
    
    func syncInDataForAssetVisibility() {
        let allVisibilityModel = assetRequisitionServerTable.getUnsyncedRecords()
        guard !allVisibilityModel.isEmpty else {
            self.syncInDataForVisits()
            return
        }

        func syncNext(index: Int) {
            if index >= allVisibilityModel.count {
                print("✅ All visibility items synced")
                self.syncInDataForVisits()
                return
            }

            let item = allVisibilityModel[index]
            let localId = Int(item.localId ?? 0)
            let fileName = item.fileName ?? ""
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("❌ File not found for LocalId \(localId): \(fileName)")
                syncNext(index: index + 1)
                return
            }

            do {
                let fileData = try Data(contentsOf: fileURL)

                let mimeType: String
                if fileName.lowercased().hasSuffix(".pdf") {
                    mimeType = "application/pdf"
                } else if fileName.lowercased().hasSuffix(".jpg") || fileName.lowercased().hasSuffix(".jpeg") {
                    mimeType = "image/jpeg"
                } else if fileName.lowercased().hasSuffix(".png") {
                    mimeType = "image/png"
                } else {
                    mimeType = "application/octet-stream"
                }

                UploadFileToServer().uploadFileToServer(
                    userId: item.dealerDistributorCorpId ?? EMPTY,
                    fileData: fileData,
                    fileName: fileName,
                    mimeType: mimeType
                ) { success, responseURL in
                    DispatchQueue.main.async {
                        guard success, let publicUrl = responseURL else {
                            print("❌ Upload failed for LocalId: \(localId)")
                            syncNext(index: index + 1)
                            return
                        }

                        self.assetRequisitionServerTable.updatePublicURL(forLocalId: localId, url: publicUrl)
                        print(publicUrl)
                        var updatedItem = item
                        updatedItem.imagePublicUrl = publicUrl
                        let payload = self.buildSalesforceImagePayloadForAsset(from: updatedItem)
                        print(payload)

                        self.sendAssetToSalesforce(payload: payload) { sfSuccess in
                            if sfSuccess {
                                self.assetRequisitionServerTable.updateSyncStatus(forLocalId: localId)
                                print("✅ Synced to Salesforce for LocalId: \(localId)")
                            } else {
                                print("❌ Salesforce sync failed for LocalId: \(localId)")
                            }
                            syncNext(index: index + 1)
                        }
                    }
                }

            } catch {
                print("❌ File read error for LocalId \(localId): \(error.localizedDescription)")
                syncNext(index: index + 1)
            }
        }

        syncNext(index: 0) 
    }
    
    func buildSalesforceImagePayloadForAsset(from model: AssetRequisitionServerModel) -> [String: Any] {
        let attributes: [String: Any] = [
            "referenceId": "ref1",
            "type": "Image_Visibility__c"
        ]
        
        let record: [String: Any] = [
            "attributes": attributes,
            "OwnerId": model.userId ?? "",
            "Asset_name__c": "Asset Requisition.\(model.assetName ?? "")",
            "External_Id__c": model.externalId ?? "",
            "Dealer_Distributor_CORP__c": model.dealerDistributorCorpId ?? "",
            "Device_Name__c": model.deviceName ?? "",
            "Device_Version__c": model.deviceVersion ?? "",
            "Device_Type__c": model.deviceType ?? "",
            "Image_Url__c": model.imagePublicUrl ?? "",
            "Visit_Order__c": model.visitOrderId ?? ""
        ]
        print("AssetRequisitionServerModel AssetRequisitionServerModel \(record)")
        return ["records": [record]]
       
    }
    
    func sendAssetToSalesforce(payload: [String: Any], completion: @escaping (Bool) -> Void) {
        webRequest.processRequestUsingPostMethod(
            url: "\(apiUrl)\(endPoint.SALESFORCE_IMAGE_UPLOAD)",
            parameters: payload,
            showLoader: true,
            contentType: .json
        ) { error, val, result, statusCode in

            guard let responseData = result as? [String: Any] else {
                print("❌ Invalid Salesforce response")
                completion(false)
                return
            }

            if let records = responseData["records"] as? [[String: Any]] {
                print("✅ Salesforce responded with \(records.count) records")
                completion(true)
            } else if let results = responseData["results"] as? [[String: Any]] {
                print("✅ Salesforce responded with \(results.count) results")
                completion(true)
            } else {
                print("⚠️ No 'records' or 'results' key found in Salesforce response")
                completion(false)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func syncInDataForVisits() {
        var visits = visitsTable.getVisitsWhereIsSyncZero()
        guard !visits.isEmpty else {
            DispatchQueue.main.async {
                self.sendObjects()
//                self.completionhandler(EMPTY)
//                Utility.showAlertForSyncDown()
            }
            return
        }
        var recordsArray = [[String: Any]]()
        var newRecordsArray = [[String: Any]]()
        
        for (index, visitData) in visits.enumerated() {
            guard let visitID = visitData.id else { continue }
            
            recordsArray.removeAll()
            newRecordsArray.removeAll()
            
            if visitData.isNew == 0 {
                let visitDataPayload: [String: Any] = [
                    "Id": visitID,
                    "External_Id__c": visitData.externalId ?? "",
                    "Checked_In_Location__Latitude__s": visitData.checkedInLocationLatitude ?? "",
                    "Checked_In_Location__Longitude__s": visitData.checkedInLocationLongitude ?? "",
                    "Checked_Out_Geolocation__Latitude__s": visitData.checkedOutGeolocationLatitude ?? "",
                    "Checked_Out_Geolocation__Longitude__s": visitData.checkedOutGeolocationLongitude ?? "",
                    "Actual_Start__c": visitData.actualStart ?? "",
                    "Actual_End__c": visitData.actualEnd ?? "",
                    "Created_TimeStamp__c": visitData.createdAt ?? "",
                    "Device_Name__c": UIDevice.current.name,
                    "Device_Type__c": "iOS",
                    "Device_Version__c": appVersionOperation.getCurrentAppVersion() ?? "",
                    "OwnerId": Defaults.userId ?? "",
                    "Name": visitData.name,
                    "Checked_In__c": visitData.checkedOut == 1,
                    "Checked_Out__c": visitData.checkedOut == 1,
                    "Contact_Person_Name__c": visitData.Contact_Person_Name__c ?? "",
                    "Contact_Phone_No__c": visitData.Contact_Phone_Number__c ?? "",
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Visits__c"
                    ]
                ]
                recordsArray.append(visitDataPayload)
                let payload: [String: Any] = ["records": recordsArray]
                
                executeSyncForVisit(localId: visitData.localId ?? 0, id: visitID, param: payload) { error, response, status in
                    if let error = error {
                        print("❌ Error syncing outlet: \(error)")
                        print("📦 Payload that caused error: \(payload)")
                        let issueDateTime = self.dateFormatter.string(from: Date())
                        
                        self.reportSyncError(
                            objectName: "Visits__c",
                            errorMessage: error,
                            errorBody: payload,
                            Issue_DateTime__c: issueDateTime
                        ) {
                            print("Successfully synced Visit ID \(visitID)")
                            DispatchQueue.main.async {
//                                NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil)
                                Utility.showAlertForSyncDown()
//                                self.sendObjects()
                            }
                        }
                    } else {
                        print("Successfully synced Visit ID \(visitID)")
                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil)
//                            Utility.showAlertForSyncDown()
                            self.sendObjects()
                        }
                    }
                }
            } else {
                let newVisitDataPayload: [String: Any] = [
                    "Account__c": visitData.accountId ?? "",
                    "External_Id__c": visitData.externalId ?? "",
                    "Checked_In_Location__Latitude__s": visitData.checkedInLocationLatitude ?? "",
                    "Checked_In_Location__Longitude__s": visitData.checkedInLocationLongitude ?? "",
                    "Checked_Out_Geolocation__Latitude__s": visitData.checkedOutGeolocationLatitude ?? "",
                    "Checked_Out_Geolocation__Longitude__s": visitData.checkedOutGeolocationLongitude ?? "",
                    "Actual_Start__c": visitData.actualStart ?? "",
                    "Name": visitData.name,
                    "Actual_End__c": visitData.actualEnd ?? "",
                    "Created_TimeStamp__c": visitData.createdAt ?? "",
                    "Device_Name__c": UIDevice.current.name,
                    "Device_Type__c": "iOS",
                    "Device_Version__c": appVersionOperation.getCurrentAppVersion() ?? "",
                    "Planned_Start__c": visitData.actualStart ?? "",
                    "OwnerId": Defaults.userId ?? "",
                    "Checked_In__c": visitData.checkedOut == 1,
                    "Checked_Out__c": visitData.checkedOut == 1,
                    "Adhoc_Visit__c": "Adhoc Visit",
                    "Visit_Type__c": "ADHOC",
                    "Contact_Person_Name__c": visitData.Contact_Person_Name__c ?? "",
                    "Contact_Phone_No__c": visitData.Contact_Phone_Number__c ?? "",
                    "attributes": [
                        "referenceId": "ref\(index)",
                        "type": "Visits__c"
                    ]
                ]
                newRecordsArray.append(newVisitDataPayload)
                let payload: [String: Any] = ["records": newRecordsArray]
                
                executeSyncForNewVisit(localId: visitData.localId ?? 0, id: visitID, param: payload) { error, response, status in
                    if let error = error {
                        print("❌ Error syncing outlet: \(error)")
                        print("📦 Payload that caused error: \(payload)")
                        let issueDateTime = self.dateFormatter.string(from: Date())
                        self.reportSyncError(
                            objectName: "Visits__c",
                            errorMessage: error,
                            errorBody: payload,
                            Issue_DateTime__c: issueDateTime
                        ) {
                            print("Successfully synced Visit ID \(visitID)")
                            DispatchQueue.main.async {
//                                self.sendObjects()
//                                NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil)
                                Utility.showAlertForSyncDown()
                            }
                        }
                    } else {
                        print("Successfully synced Visit ID \(visitID)")
                        DispatchQueue.main.async {
                            self.sendObjects()
//                            NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil)
//                            Utility.showAlertForSyncDown()
                        }
                    }
                }
            }
        }
    }
    
    func executeSyncForVisit(localId: Int, id: String, param: [String: Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        let url = "\(apiUrl)\(endPoint.SEND_VISIT)\(id)"
        webRequest.processRequestUsingPatchMethod(url: url, parameters: param, showLoader: true) { error, val, result, statusCode in
            print("Post Visit Data for ID \(id)")
            let responseArr = result as? [[String: Any]] ?? []
            let resArr = responseArr.first
            let responseDict = resArr
            if (responseDict?["success"] as? Int == 1 ) {
                self.visitsTable.updateSyncStatusForVisit(localId: localId)
                outerClosure(nil, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            } else {
                let errorMessage = "No records found in the response for ID \(id)"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func executeSyncForNewVisit(localId: Int, id: String, param: [String: Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        let url = "\(apiUrl)\(endPoint.SEND_VISIT)"
        webRequest.processRequestUsingPatchMethod(url: url, parameters: param, showLoader: true) { error, val, result, statusCode in
            let responseArr = result as? [[String: Any]] ?? []
            let resArr = responseArr.first
            let responseDict = resArr
            print("Post Visit Data for ID \(responseDict?["id"] ?? "")")
            if (responseDict?["success"] as? Int == 1 ) {
                self.visitsTable.updateSyncStatusForVisit(localId: localId)
                outerClosure(nil, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            } else {
                let errorMessage = "No records found in the response for ID \(id)"
                outerClosure(errorMessage, nil, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func sendObjects() {
        let authOperation = AuthOperation()
        let userData = [
            "Sync_Type__c": "Sync Up",
            "Sync_Date_Time__c": customDateFormatter.getFormattedDateForAccount(),
            "Login_User__c": Defaults.userId ?? "",
            "Device_Id__c": DeviceId,
            "Device_Type__c": "iOS",
            "Device_Name__c": UIDevice.current.name,
            "New_Outlet_Count__c": 0,
            "Photo_Upload_Count__c": 0,
            "Visit_Count__c": 0,
            "Device_Version__c": appVersionOperation.getCurrentAppVersion() ?? "",
            "attributes": [
                "referenceId": "ref1",
                "type": "Application_Sync_Configurer__c"
            ]
        ] as [String : Any]
        var userDataDict: [String : Any] = [:]
        userDataDict = ["records": [userData]]
        print(userDataDict)
        authOperation.sendSobjects(details: userDataDict) { error , resposne, statusCode in
            if statusCode == .success {
                Defaults.isSyncUpProcessCompleted = true
                Defaults.isSyncUpComplete = false
                Utility.showAlertForSyncDown()
            }
        }
    }
    
    func reportSyncError(
        objectName: String,
        errorMessage: String,
        errorBody: [String: Any],
        Issue_DateTime__c: String,
        completion: @escaping () -> Void
    ) {
        var errorBodyString = ""
        if let jsonData = try? JSONSerialization.data(withJSONObject: errorBody, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            errorBodyString = jsonString
        }
        
        let errorLog: [String: Any] = [
            "attributes": [
                "referenceId": "ref1",
                "type": "Error_log__c"
            ],
            "User__c": Defaults.userId ?? "",
            "Device_Name__c": UIDevice.current.name,
            "Error_Message__c": errorMessage,
            "Error_Body__c": errorBodyString,
            "Issue_DateTime__c": Issue_DateTime__c,
            "Object__c": objectName,
            "Device_Version__c": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "Device_Type__c": "iOS"
        ]
        let finalPayload: [String: Any] = [
            "records": [errorLog]
        ]
        print("finalPayloadddddd\(finalPayload)")
        
        webRequest.processRequestUsingPostMethod(url: "\(apiUrl)\(endPoint.ERROR_LOG)", parameters: finalPayload, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Error logged: \(result ?? [:])")
            completion()
        }
    }
}
        




