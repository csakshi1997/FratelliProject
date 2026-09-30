//
//  SyncOperation.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation
import UIKit

class SyncOperation {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    let dateFormatter = DateFormatter()
    
    func executeSync(syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingGetMethod(url: "\(Defaults.instanceUrl ?? "")/services/data/v59.0/query/?q=\(syncType)", parameters: nil, showLoader: true) { error, val, result, statusCode in
            print("Gettttt \(syncName): \(syncType) ")
            
            guard error == nil else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            
            guard let responseData = result as? [String: Any], let records = responseData["records"] as? [[String: Any]] else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            switch syncName {
            case SyncEnum.contacts.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let contact = self.parseContact(record: record) {
                        let contactsTable = ContactsTable()
                        contactsTable.saveContact(contact: contact) { success, errorMessage in
                            if success {
                                print("Contact \(contact.contactId ?? "") saved successfully.")
                            } else {
                                print("Failed to save contact \(contact.contactId ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse contact for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.visits.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let visit = self.parseVisit(record: record) {
                        let visitsTable = VisitsTable()
                        visitsTable.saveVisit(visit: visit) { success, errorMessage in
                            if success {
                                print("Visit \(visit.id ?? "") saved successfully.")
                            } else {
                                print("Failed to save visit \(visit.id ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse visit for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
//            case SyncEnum.products.rawValue:
//                for record in records {
//                    dispatchGroup.enter()
//                    if let product = self.parseProduct(record: record) {
//                        let productsTable = ProductsTable()
//                        productsTable.saveProduct(product: product) { success, errorMessage in
//                            if success {
//                                print("Product \(product.id) saved successfully.")
//                            } else {
//                                print("Failed to save product \(product.id): \(errorMessage ?? "Unknown error")")
//                            }
//                            dispatchGroup.leave()
//                        }
//                    } else {
//                        print("Failed to parse product for record: \(record)")
//                        dispatchGroup.leave()
//                    }
//                }
                
            case SyncEnum.products.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    print("hello hello \(record)")
                    
                    let product = self.parseProduct(record: record)
                    let productsTable = ProductsTable()
                    productsTable.saveProduct(product: product) { success, errorMessage in
                        if success {
                            print("✅ Product \(product.id ?? "nil") saved successfully.")
                        } else {
                            print("hello hello hello hello hello  \(record)")
                            print("🔴 Failed to save product \(product.id ?? "nil"): \(errorMessage ?? "Unknown error")")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                
            case SyncEnum.outlets.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let outlet = self.parseOutlet(record: record) {
                        let outletsTable = OutletsTable()
                        outletsTable.saveOutlet(outlet: outlet) { success, errorMessage in
                            if success {
                                print("Outlet \(outlet.id ?? "") saved successfully.")
                            } else {
                                print("Failed to save outlet \(outlet.id ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse outlet for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.distributorAccount.rawValue:
                print(records)
                for record in records {
                    dispatchGroup.enter()
                    if let outlet = self.parseDistributorAccounts(record: record) {
                        let distributorAccountsTable = DistributorAccountsTable()
                        distributorAccountsTable.saveDistribitorOutlet(outlet: outlet) { success, errorMessage in
                            if success {
                                print("distributorAccount \(outlet.id ?? "") saved successfully.")
                            } else {
                                print("Failed to save distributorAccount \(outlet.id ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse outdistributorAccountlet for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.recommendations.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let recommendation = self.parseRecommendation(record: record) {
                        let recommendationsTable = RecommendationsTable()
                        recommendationsTable.saveRecommendation(recommendation: recommendation) { success, errorMessage in
                            if success {
                                print("Recommendation \(recommendation.id) saved successfully.")
                            } else {
                                print("Failed to save recommendation \(recommendation.id): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse recommendation for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.promotion.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let promotion = self.parsePromotion(record: record) {
                        let promotionsTable = PromotionsTable()
                        promotionsTable.savePromotion(promotion: promotion) { success, errorMessage in
                            if success {
                                print("Promotion \(promotion.id) saved successfully.")
                            } else {
                                print("Failed to save promotion \(promotion.id): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse promotion for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.posmRequest.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let posm = self.parsePosm(record: record) {
                        let pOSMRequisitionTable = POSMRequisitionTable()
                        pOSMRequisitionTable.savePOSMRequisition(model: posm) { success, errorMessage in
                            if success {
                                print("Promotion \(posm.localId ?? "") saved successfully.")
                            } else {
                                print("Failed to save promotion \(posm.localId ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse promotion for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.assetRequest.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let asset = self.parseAsset(record: record) {
                        let assetRequisitionTable = AssetRequisitionTable()
                        assetRequisitionTable.saveAssetRequisition(model: asset) { success, errorMessage in
                            if success {
                                print("Asset \(asset.localId ?? "") saved successfully.")
                            } else {
                                print("Failed to save Asset \(asset.localId ?? ""): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse Asset for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            case SyncEnum.actionItems.rawValue:
                for record in records {
                    dispatchGroup.enter()
                    if let tasks = self.parseTasks(record: record) {
                        let addNewTaskTable = AddNewTaskTable()
                        addNewTaskTable.saveTasksFromSalesForce(task: tasks){ success, errorMessage in
                            if success {
                                print("Promotion \(tasks.localId ?? 0) saved successfully.")
                            } else {
                                print("Failed to save promotion \(tasks.localId ?? 0): \(errorMessage ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        print("Failed to parse promotion for record: \(record)")
                        dispatchGroup.leave()
                    }
                }
            default:
                print("Sync name \(syncName) not recognized. Skipping.")
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                print("All records for \(syncName) have been processed.")
                outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
            }
        }
    }
    
    func parseContact(record: [String: Any]) -> Contact? {
        guard let id = record["Id"] as? String,
              let name = record["Name"] as? String else {
            return nil
        }
        
        // Optional fields
        let firstName = record["FirstName"] as? String
        let lastName = record["LastName"] as? String
        let middleName = record["MiddleName"] as? String
        let phone = record["Phone"] as? String
        let email = record["Email"] as? String
        let salutation = record["Salutation"] as? String
        let title = record["Title"] as? String
        let ownerId = record["OwnerId"] as? String
        let aadharNumber = record["Aadhar_No__c"] as? String
        let accountId = record["AccountId"] as? String
        let remark = record["Remark__c"] as? String
        let isSync = "1"
        
        return Contact(
            aadharNo: aadharNumber,
            accountId: accountId ?? "",
            email: email ?? "",
            firstName: firstName ?? "",
            contactId: id,
            lastName: lastName ?? "",
            middleName: middleName,
            name: name,
            ownerId: ownerId ?? "",
            phone: phone ?? "",
            remark: remark,
            salutation: salutation ?? "",
            title: title,
            isSync: isSync,
            workingWithOutlet: 0
        )
    }
    
    
//    func parseVisit(record: [String: Any]) -> Visit? {
//        print(record)
//        let id = record["Id"] as? String ?? ""
//        let name = record["Name"] as? String ?? ""
//        let checkedIn = record["Checked_In__c"] as? Int ?? 0
//        let checkedOut = record["Checked_Out__c"]as? Int ?? 0
//        let empZone = record["EMP_Zone__c"] as? String ?? ""
//        let employeeCode = record["Employee_Code__c"] as? String ?? ""
//        let outletCreation = record["Outlet_Creation__c"] as? String ?? ""
//        let ownerId = record["OwnerId"] as? String ?? ""
//        let ownerArea = record["Owner_Area__c"] as? String ?? ""
//        let status = record["Status__c"] as? String ?? ""
//        let visitPlanDate = record["Visit_plan_date__c"] as? String ?? ""
//        
//        // Optional fields (can be nil)
//        let accountId = record["Account__c"] as? String
//        let accountReference = record["Account__r"] as? String
//        let actualEnd = record["Actual_End__c"] as? String
//        let actualStart = record["Actual_Start__c"] as? String
//        let area = record["Area__c"] as? String
//        let beatRoute = record["Beat_Route__c"] as? String
//        let channel = record["Channel__c"] as? String
//        let checkInLocation = record["Check_In_Location__c"] as? String
//        let checkOutLocation = record["Check_Out_Location__c"] as? String
//        let checkedInLocationLatitude = record["Checked_In_Location__Latitude__s"]
//        let checkedInLocationLongitude = record["Checked_In_Location__Longitude__s"]
//        let checkedOutGeolocationLatitude = record["Checked_Out_Geolocation__Latitude__s"]
//        let checkedOutGeolocationLongitude = record["Checked_Out_Geolocation__Longitude__s"]
//        let oldPartyCode = record["Old_Party_Code__c"] as? String
//        let outletType = record["Outlet_Type__c"] as? String
//        let partyCode = record["Party_Code__c"] as? String
//        let remarks = record["Remarks__c"] as? String
//        let isSync = status == "Completed" ? "1" : "0"
//        let isCompleted = status == "Completed" ? "1" : "0"
//        let createdAt = ""
//        let isNew = 0
//        let fromAppCompleted = ""
//        
//        // Attributes (must be non-nil if present)
//        if let attributesDict = record["attributes"] as? [String: Any],
//           let type = attributesDict["type"] as? String,
//           let url = attributesDict["url"] as? String {
//            let attributes = Visit.Attributes(type: type, url: url)
//            
//            // Return a Visit object
//            return Visit(
//                accountId: accountId,
//                accountReference: accountReference,
//                actualEnd: actualEnd,
//                actualStart: actualStart,
//                area: area,
//                beatRoute: beatRoute,
//                channel: channel,
//                checkInLocation: checkInLocation,
//                checkOutLocation: checkOutLocation,
//                checkedInLocationLatitude: "\(checkedInLocationLatitude ?? "")",
//                checkedInLocationLongitude: "\(checkedInLocationLongitude ?? "")",
//                checkedIn: checkedIn == 1 ? 0 : 0,
//                checkedOutGeolocationLatitude: "\(checkedOutGeolocationLatitude ?? "")",
//                checkedOutGeolocationLongitude: "\(checkedOutGeolocationLongitude ?? "")",
//                checkedOut: checkedOut,
//                empZone: empZone,
//                employeeCode: Int(employeeCode) ?? 0,
//                id: id,
//                name: name,
//                oldPartyCode: oldPartyCode,
//                outletCreation: outletCreation,
//                outletType: outletType,
//                ownerId: ownerId,
//                ownerArea: ownerArea,
//                partyCode: partyCode,
//                remarks: remarks,
//                status: status,
//                visitPlanDate: visitPlanDate,
//                attributes: attributes,
//                isSync: isSync,
//                isCompleted: isCompleted,
//                createdAt: createdAt,
//                isNew: isNew,
//                fromAppCompleted: fromAppCompleted
//            )
//        }
//        
//        // Return nil if attributes are missing
//        return nil
//    }
    
    
    
    func parseVisit(record: [String: Any]) -> Visit? {
        print(record)
        let id = record["Id"] as? String
        let name = record["Name"] as? String ?? ""
        let checkedIn = record["Checked_In__c"] as? Int ?? 0
        let checkedOut = record["Checked_Out__c"] as? Int ?? 0
        let empZone = record["Emp_Zone__c"] as? String ?? ""
        let employeeCode = Int(record["Employee_Code__c"] as? String ?? "0") ?? 0
        let outletCreation = record["Outlet_Creation__c"] as? String ?? ""
        let outletType = record["Outlet_Type__c"] as? String
        let ownerId = record["OwnerId"] as? String ?? ""
        let ownerArea = record["Owner_Area__c"] as? String ?? ""
        let area = record["Area__c"] as? String
        let channel = record["Channel__c"] as? String
        let visitPlanDate = record["Visit_plan_date__c"] as? String ?? ""
        let status = record["Status__c"] as? String ?? ""
        let oldPartyCode = record["Old_Party_Code__c"] as? String
        let remarks = record["Remarks__c"] as? String
        let partyCode = record["Party_Code__c"] as? String
        let actualStart = record["Actual_Start__c"] as? String
        let actualEnd = record["Actual_End__c"] as? String
        let checkedInLocationLatitude = record["Checked_In_Location__Latitude__s"] as? String
        let checkedInLocationLongitude = record["Checked_In_Location__Longitude__s"] as? String
        let checkedOutGeolocationLatitude = record["Checked_Out_Geolocation__Latitude__s"] as? String
        let checkedOutGeolocationLongitude = record["Checked_Out_Geolocation__Longitude__s"] as? String
        let isSync = status == "Completed" ? "1" : ""
        let isCompleted = status == "Completed" ? "1" : "0"
        let createdAt = ""
        let isNew = 0
        let fromAppCompleted = ""

        // Parse Account__r
        var accountReference: Visit.Account? = nil
        if let accountDict = record["Account__r"] as? [String: Any],
           let classification = accountDict["Classification__c"] as? String,
           let accountId = accountDict["Id"] as? String,
           let accountName = accountDict["Name"] as? String,
           let accountOwnerId = accountDict["OwnerId"] as? String,
           let subChannel = accountDict["Sub_Channel__c"] as? String,
           let attributesDict = accountDict["attributes"] as? [String: Any],
           let type = attributesDict["type"] as? String,
           let url = attributesDict["url"] as? String {
            let attributes = Visit.Attributes(type: type, url: url)
            accountReference = Visit.Account(
                classification: classification,
                id: accountId,
                name: accountName,
                ownerId: accountOwnerId,
                subChannel: subChannel
            )
        }

        // Parse Attributes
        let attributes: Visit.Attributes?
        if let attributesDict = record["attributes"] as? [String: Any],
           let type = attributesDict["type"] as? String,
           let url = attributesDict["url"] as? String {
            attributes = Visit.Attributes(type: type, url: url)
        } else {
            attributes = nil
        }

        // Return a Visit object
        return Visit(
            localId: nil,
            accountId: record["Account__c"] as? String,
            accountReference: accountReference,
            actualEnd: actualEnd,
            actualStart: actualStart,
            area: area,
            beatRoute: record["Beat_Route__c"] as? String,
            channel: channel,
            checkInLocation: record["Check_In_Location__c"] as? String,
            checkOutLocation: record["Check_Out_Location__c"] as? String,
            checkedInLocationLatitude: checkedInLocationLatitude,
            checkedInLocationLongitude: checkedInLocationLongitude,
            checkedIn: checkedIn == 1 ? 0 : 0,
            checkedOutGeolocationLatitude: checkedOutGeolocationLatitude,
            checkedOutGeolocationLongitude: checkedOutGeolocationLongitude,
            checkedOut: checkedOut,
            empZone: empZone,
            employeeCode: employeeCode,
            id: id,
            name: name,
            oldPartyCode: oldPartyCode,
            outletCreation: outletCreation,
            outletType: outletType,
            ownerId: ownerId,
            ownerArea: ownerArea,
            partyCode: partyCode,
            remarks: remarks,
            status: status,
            visitPlanDate: visitPlanDate,
            attributes: attributes,
            isSync: isSync,
            isCompleted: isCompleted,
            createdAt: createdAt,
            isNew: isNew,
            fromAppCompleted: fromAppCompleted,
            Contact_Person_Name__c: "",
            Contact_Phone_Number__c: ""
        )
    }
    
    
    
    
    
    
//    func parseProduct(record: [String: Any]) -> Product? {
//        guard let abbreviation = record["Abbreviation__c"] as? String else {
//            return nil
//        }
//        guard let brandCode = record["Brand_Code__c"] as? String else {
//            return nil
//        }
//        guard let category = record["Category__c"] as? String else {
//            return nil
//        }
//        guard let conversionRatio = record["Conversion_Ratio__c"] as? Int else {
//            return nil
//        }
//        guard let createdDate = record["CreatedDate"] as? String else {
//            return nil
//        }
//        guard let createdDate = record["Id"] as? String else {
//            return nil
//        }
//        guard let id = record["Id"] as? String else {
//            return nil
//        }
//        guard let isDeleted = record["IsDeleted"] as? Bool else {
//            return nil
//        }
//        guard let itemType = record["Item_Type__c"] as? String else {
//            return nil
//        }
//        guard let name = record["Name"] as? String else {
//            return nil
//        }
//        guard let ownerId = record["OwnerId"] as? String else {
//            return nil
//        }
//        guard let priority = record["Priority__c"] as? Int else {
//            return nil
//        }
//        guard let productId = record["Product_ID__c"] as? String else {
//            return nil
//        }
//        guard let sizeCode = record["Size_Code__c"] as? String else {
//            return nil
//        }
//        guard let sizeInMl = record["Size_In_ML__c"] as? String else {
//            return nil
//        }
//        guard let type = record["Type__c"] as? String else {
//            return nil
//        }
//        
//        let bottleCan = record["Bottle_CAN__c"] as? String
//        let bottleSize = record["Bottle_Size__c"] as? String
//        let gst = record["GST__c"] as? String
//        let productCategory = record["Product_Category__c"] as? String
//        let productCode = record["Product_Code__c"] as? String
//        let productFamily = record["Product_Family__c"] as? String
//        let productType = record["Product_Type__c"] as? String
//        let isSync = "0"
//        
//        if let attributesDict = record["attributes"] as? [String: Any],
//           let type = attributesDict["type"] as? String,
//           let url = attributesDict["url"] as? String {
//            let attributes = Product.Attributes(type: type, url: url)
//            
//            return Product(
//                abbreviation: abbreviation,
//                bottleCan: bottleCan,
//                bottleSize: bottleSize,
//                brandCode: brandCode,
//                category: category,
//                conversionRatio: conversionRatio,
//                createdDate: createdDate,
//                gst: gst,
//                id: id,
//                isDeleted: isDeleted,
//                itemType: itemType,
//                name: name,
//                ownerId: ownerId,
//                priority: priority,
//                productCategory: productCategory,
//                productCode: productCode,
//                productFamily: productFamily,
//                productId: productId,
//                productType: productType,
//                sizeCode: sizeCode,
//                sizeInMl: Int(sizeInMl) ?? 0,
//                type: type,
//                attributes: attributes,
//                isSync: isSync
//            )
//        }
//        
//        return nil
//    }
    
    func parseProduct(record: [String: Any]) -> Product {
        let abbreviation = record["Abbreviation__c"] as? String ?? ""
        let bottleCan = record["Bottle_CAN__c"] as? String ?? ""
        let bottleSize = record["Bottle_Size__c"] as? String ?? ""
        let brandCode = record["Brand_Code__c"] as? String ?? ""
        let category = record["Category__c"] as? String ?? ""
        let conversionRatio = record["Conversion_Ratio__c"] as? Int ?? 0
        let createdDate = record["CreatedDate"] as? String ?? ""
        let gst = record["GST__c"] as? String ?? ""
        let id = record["Id"] as? String ?? ""
        let isDeleted = (record["IsDeleted"] as? Int ?? 0) == 1
        let itemType = record["Item_Type__c"] as? String ?? ""
        let name = record["Name"] as? String ?? ""
        let ownerId = record["OwnerId"] as? String ?? ""
        let priority = record["Priority__c"] as? Int ?? 0
        let productCategory = record["Product_Category__c"] as? String ?? ""
        let productCode = record["Product_Code__c"] as? String ?? ""
        let productFamily = record["Product_Family__c"] as? String ?? ""
        let productId = record["Product_ID__c"] as? String ?? ""
        let productType = record["Product_Type__c"] as? String ?? ""
        let sizeCode = record["Size_Code__c"] as? String ?? ""
        let sizeInMl = record["Size_In_ML__c"] as? Int ?? 0
        let type = record["Type__c"] as? String ?? ""

        // Parse nested attributes
        var attributes: Product.Attributes? = nil
        if let attrDict = record["attributes"] as? [String: Any] {
            let attrType = attrDict["type"] as? String ?? ""
            let attrUrl = attrDict["url"] as? String ?? ""
            attributes = Product.Attributes(type: attrType, url: attrUrl)
        }

        return Product(
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
            isSync: ""
        )
    }
    
    func parseOutlet(record: [String: Any]) -> Outlet? {
        print("parseOutlet \(record)")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let currentDateTime = dateFormatter.string(from: Date())
        let accountId = record["Account_ID__c"] as? String ?? ""
        let accountStatus = record["Account_Status__c"] as? String ?? ""
        let channel = record["Channel__c"] as? String ?? ""
        let classification = record["Classification__c"] as? String ?? ""
        let groupName = record["Group__c"] as? String ?? ""
        let id = record["Id"] as? String ?? ""
        let name = record["Name"] as? String ?? "Unnamed Outlet"
        let outletType = record["Outlet_Type__c"] as? String ?? ""
        let ownerId = record["Owner_ID__c"] as? String ?? ""
        let partyCode = record["Party_Code__c"] as? String ?? ""
        let salesType = record["Sales_Type__c"] as? String ?? ""
        let salesmanCode = record["Salesman_Code__c"] as? String ?? ""
        let status = record["Status__c"] as? Int ?? 0
        let subChannelType = record["Sub_Channel_Type__c"] as? String ?? ""
        let subChannel = record["Sub_Channel__c"] as? String ?? ""
        let type = record["Type"] as? String ?? ""
        let attributesDict = record["attributes"] as? [String: Any] ?? [:]
        let attributesType = attributesDict["type"] as? String ?? ""
        let attributesUrl = attributesDict["url"] as? String ?? ""
        
        let annualTargetData = (record["Annual_Target_Data__c"] as? Int) ?? 0
        let area = record["Area__c"] ?? ""
        let billingCity = (record["BillingAddress"] as? [String: Any])?["city"] as? String ?? ""
        let billingCountry = (record["BillingAddress"] as? [String: Any])?["country"] as? String ?? ""
        let billingCountryCode = (record["BillingAddress"] as? [String: Any])?["countryCode"] as? String ?? ""
        let billingState = (record["BillingAddress"] as? [String: Any])?["state"] as? String ?? ""
        let billingStateCode = (record["BillingAddress"] as? [String: Any])?["stateCode"] as? String ?? ""
        let billingStreet = (record["BillingAddress"] as? [String: Any])?["street"] as? String ?? ""
        let checkedInLocationLatitude = record["Checked_In_Location__Latitude__s"] as? String ?? ""
        let checkedInLocationLongitude = record["Checked_In_Location__Longitude__s"] as? String ?? ""
        let distributorCode = record["Distributor_Code__c"] as? String ?? ""
        let distributorName = record["Distributor_Name__c"] as? String ?? ""
        let distributorPartyCode = record["Distributor_Party_Code__c"] as? String ?? ""
        let email = record["Email__c"] as? String ?? ""
        let gstNo = record["GST_No__c"] as? String ?? ""
        let growth = (record["Growth__c"] as? Int) ?? 0
        let industry = record["Industry"] as? String ?? ""
        let lastVisitDate = record["Last_Visit_Date__c"] as? String ?? ""
        let parentId = record["ParentId"] as? String ?? ""
        let licenseCode = record["License_Code__c"] as? String ?? ""
        let license = record["License__c"] as? String ?? ""
        let marketShare = (record["Market_Share__c"] as? Int) ?? 0
        let panNo = record["PAN_No__c"] as? String ?? ""
        let partyCodeOld = record["Party_Code_Old__c"] as? String ?? ""
        let phone = record["Phone"] as? String ?? ""
        let supplierGroup = record["Supplier_Group__c"] as? String ?? ""
        let supplierManufacturerUnit = record["Supplier_Manufacturer_Unit__c"] as? String ?? ""
        let yearLastYear = (record["Year_LastYear__c"] as? Int) ?? 0
        let years = (record["Years__c"] as? Int) ?? 0
        let zone = record["Zone__c"] as? String ?? ""
        let OwnerManager = record["Owner_Manager__c"] as? String ?? ""
        let isSync = "1"
        let assetVisibility = record["Asset_Visibility__c"] as? String ?? ""
        let currentMarketShare = (record["Current_Market_Share__c"] as? Double) ?? 0.0
        let createdAt = currentDateTime
       
        
        let attributes = Outlet.Attributes(type: attributesType, url: attributesUrl)
        
        return Outlet(
            localId: nil,
            accountId: accountId,
            accountStatus: accountStatus,
            annualTargetData: "\(annualTargetData)",
            area: area as? String,
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
            growth: "\(growth)",
            id: id,
            industry: industry,
            lastVisitDate: "\(lastVisitDate)",
            licenseCode: licenseCode,
            license: license,
            marketShare: "\(marketShare)",
            name: name,
            outletType: outletType,
            ownerId: ownerId,
            ownerManager: OwnerManager,
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
            yearLastYear: "\(yearLastYear)",
            years: "\(years)",
            zone: zone,
            parentId: parentId,
            attributes: attributes,
            isSync: isSync,
            checkIn: 0,
            createdAt: createdAt,
            Asset_Visibility__c: assetVisibility,
            Current_Market_Share__c: "\(currentMarketShare)"
        )
    }
    
    func parseDistributorAccounts(record: [String: Any]) -> DistributorAccountsModel? {
        print(record)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let currentDateTime = dateFormatter.string(from: Date())
        let accountId = record["Account_ID__c"] as? String ?? ""
        let accountStatus = record["Account_Status__c"] as? String ?? ""
        let channel = record["Channel__c"] as? String ?? ""
        let classification = record["Classification__c"] as? String ?? ""
        let groupName = record["Group__c"] as? String ?? ""
        let id = record["Id"] as? String ?? ""
        let name = record["Name"] as? String ?? "Unnamed Outlet"
        let outletType = record["Outlet_Type__c"] as? String ?? ""
        let ownerId = record["Owner_ID__c"] as? String ?? ""
        let partyCode = record["Party_Code__c"] as? String ?? ""
        let salesType = record["Sales_Type__c"] as? String ?? ""
        let salesmanCode = record["Salesman_Code__c"] as? String ?? ""
        let status = record["Status__c"] as? Int ?? 0
        let subChannelType = record["Sub_Channel_Type__c"] as? String ?? ""
        let subChannel = record["Sub_Channel__c"] as? String ?? ""
        let type = record["Type"] as? String ?? ""
        let attributesDict = record["attributes"] as? [String: Any] ?? [:]
        let attributesType = attributesDict["type"] as? String ?? ""
        let attributesUrl = attributesDict["url"] as? String ?? ""
        
        let annualTargetData = (record["Annual_Target_Data__c"] as? Int) ?? 0
        let area = record["Area__c"] ?? ""
        let billingCity = (record["BillingAddress"] as? [String: Any])?["city"] as? String ?? ""
        let billingCountry = (record["BillingAddress"] as? [String: Any])?["country"] as? String ?? ""
        let billingCountryCode = (record["BillingAddress"] as? [String: Any])?["countryCode"] as? String ?? ""
        let billingState = (record["BillingAddress"] as? [String: Any])?["state"] as? String ?? ""
        let billingStateCode = (record["BillingAddress"] as? [String: Any])?["stateCode"] as? String ?? ""
        let billingStreet = (record["BillingAddress"] as? [String: Any])?["street"] as? String ?? ""
        let checkedInLocationLatitude = record["Checked_In_Location__Latitude__s"] as? String ?? ""
        let checkedInLocationLongitude = record["Checked_In_Location__Longitude__s"] as? String ?? ""
        let distributorCode = record["Distributor_Code__c"] as? String ?? ""
        let distributorName = record["Distributor_Name__c"] as? String ?? ""
        let distributorPartyCode = record["Distributor_Party_Code__c"] as? String ?? ""
        let email = record["Email__c"] as? String ?? ""
        let gstNo = record["GST_No__c"] as? String ?? ""
        let growth = (record["Growth__c"] as? Int) ?? 0
        let industry = record["Industry"] as? String ?? ""
        let lastVisitDate = record["Last_Visit_Date__c"] as? String ?? ""
        let parentId = record["ParentId"] as? String ?? ""
        let licenseCode = record["License_Code__c"] as? String ?? ""
        let license = record["License__c"] as? String ?? ""
        let marketShare = (record["Market_Share__c"] as? Int) ?? 0
        let panNo = record["PAN_No__c"] as? String ?? ""
        let partyCodeOld = record["Party_Code_Old__c"] as? String ?? ""
        let phone = record["Phone"] as? String ?? ""
        let supplierGroup = record["Supplier_Group__c"] as? String ?? ""
        let supplierManufacturerUnit = record["Supplier_Manufacturer_Unit__c"] as? String ?? ""
        let yearLastYear = (record["Year_LastYear__c"] as? Int) ?? 0
        let years = (record["Years__c"] as? Int) ?? 0
        let zone = record["Zone__c"] as? String ?? ""
        let OwnerManager = record["Owner_Manager__c"] as? String ?? ""
        let isSync = "1"
        let createdAt = currentDateTime
        
        let attributes = DistributorAccountsModel.Attributes(type: attributesType, url: attributesUrl)
        
        return DistributorAccountsModel(
            localId: nil,
            accountId: accountId,
            accountStatus: accountStatus,
            annualTargetData: "\(annualTargetData)",
            area: area as? String,
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
            growth: "\(growth)",
            id: id,
            industry: industry,
            lastVisitDate: "\(lastVisitDate)",
            licenseCode: licenseCode,
            license: license,
            marketShare: "\(marketShare)",
            name: name,
            outletType: outletType,
            ownerId: ownerId,
            ownerManager: OwnerManager,
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
            yearLastYear: "\(yearLastYear)",
            years: "\(years)",
            zone: zone,
            parentId: parentId,
            attributes: attributes,
            isSync: isSync,
            checkIn: 0,
            createdAt: createdAt
        )
    }

    
    func parseRecommendation(record: [String: Any]) -> Recommendation? {
        guard let id = record["Id"] as? String,
              let name = record["Name"] as? String,
              let ownerId = record["OwnerId"] as? String,
              let productDescription = record["Product_Description__c"] as? String,
              let productNameId = record["Product_Name__c"] as? String,
              let productNameDict = record["Product_Name__r"] as? [String: Any],
              let productName = productNameDict["Name"] as? String,
              let productNameAttributesDict = productNameDict["attributes"] as? [String: Any],
              let productNameAttributesType = productNameAttributesDict["type"] as? String,
              let productNameAttributesUrl = productNameAttributesDict["url"] as? String else {
            return nil
        }
        
        let productImageLink = productNameDict["Product_Image_Link__c"] as? String
        let productAttributes = ProductName.Attributes(type: productNameAttributesType, url: productNameAttributesUrl)
        let product = ProductName(
            id: productNameId,
            name: productName,
            productDescription: nil,
            productImageLink: productImageLink,
            attributes: productAttributes
        )
        let attributesDict = record["attributes"] as? [String: Any]
        let attributesType = attributesDict?["type"] as? String
        let attributesUrl = attributesDict?["url"] as? String
        let attributes = attributesType != nil && attributesUrl != nil ? Recommendation.Attributes(type: attributesType!, url: attributesUrl!) : nil
        return Recommendation(
            id: id,
            name: name,
            ownerId: ownerId,
            productDescription: productDescription,
            productNameId: productNameId,
            productName: product,
            attributes: attributes
        )
    }
    
    func parsePromotion(record: [String: Any]) -> Promotion? {
        guard let id = record["Id"] as? String,
              let name = record["Name"] as? String,
              let ownerId = record["OwnerId"] as? String,
              let productDescription = record["Product_Description__c"] as? String,
              let productNameId = record["Product_Name__c"] as? String,
              let productNameDict = record["Product_Name__r"] as? [String: Any],
              let productName = productNameDict["Name"] as? String else {
            return nil
        }
        
        let productImageLink = productNameDict["Product_Image_Link__c"] as? String
        let productDescriptionDetail = productNameDict["Product_Description__c"] as? String
        let productAttributesDict = productNameDict["attributes"] as? [String: Any]
        let productAttributesType = productAttributesDict?["type"] as? String
        let productAttributesUrl = productAttributesDict?["url"] as? String
        let product = ProductName(
            id: productNameId,
            name: productName,
            productDescription: productDescriptionDetail,
            productImageLink: productImageLink,
            attributes: productAttributesType != nil && productAttributesUrl != nil
            ? ProductName.Attributes(type: productAttributesType!, url: productAttributesUrl!)
            : nil
        )
        let attributesDict = record["attributes"] as? [String: Any]
        let attributesType = attributesDict?["type"] as? String
        let attributesUrl = attributesDict?["url"] as? String
        let attributes = attributesType != nil && attributesUrl != nil
        ? Promotion.Attributes(type: attributesType!, url: attributesUrl!)
        : nil
        return Promotion(
            id: id,
            name: name,
            ownerId: ownerId,
            productDescription: productDescription,
            productNameId: productNameId,
            productName: product,
            attributes: attributes
        )
    }
    
    func parseOnTrade(record: [String: Any]) -> OnTrade? {
        guard let id = record["Id"] as? String,
              let durableId = record["DurableId"] as? String,
              let label = record["Label"] as? String,
              let value = record["Value"] as? String else {
            return nil
        }
        return OnTrade(Id: id, DurableId: durableId, Label: label, Value: value)
    }
    
    func parseTradeOnTradeOffAssets(record: [String: Any]) -> AssetModel? {
        guard let label = record["Label"] as? String,
              let value = record["Value"] as? String,
              let IsActive = record["IsActive"] as? Int,
              let attributesDict = record["attributes"] as? [String: Any],
              let attributesType = attributesDict["type"] as? String,
              let attributesUrl = attributesDict["url"] as? String else {
            return nil
        }
        let attributes = AssetModel.Attributes(type: attributesType, url: attributesUrl)
        
        return AssetModel(
            localId: nil,
            IsActive: IsActive,
            Label: label,
            Value: value,
            attributes: attributes
            
        )
    }
    
    func parseAsset(record: [String: Any]) -> AssetRequisitionModel? {
        guard let IsActive = record["IsActive"] as? Bool,
              let label = record["Label"] as? String,
              let value = record["Value"] as? String,
              let attributesDict = record["attributes"] as? [String: Any],
              let attributesType = attributesDict["type"] as? String,
              let attributesUrl = attributesDict["url"] as? String else {
            return nil
        }
        let attributes = AssetRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
        
        return AssetRequisitionModel(
            IsActive : IsActive,
            Label: label,
            Value: value,
            attributes: attributes
        )
    }
    
    func parsePosm(record: [String: Any]) -> POSMRequisitionModel? {
        guard let IsActive = record["IsActive"] as? Bool,
              let label = record["Label"] as? String,
              let value = record["Value"] as? String,
              let attributesDict = record["attributes"] as? [String: Any],
              let attributesType = attributesDict["type"] as? String,
              let attributesUrl = attributesDict["url"] as? String else {
            return nil
        }
        let attributes = POSMRequisitionModel.Attributes(type: attributesType, url: attributesUrl)
        
        return POSMRequisitionModel(
            IsActive : IsActive,
            Label: label,
            Value: value,
            attributes: attributes
        )
    }
    
    func parseTasks(record: [String: Any]) -> AddNewTaskModel? {
        guard let Id = record["Id"] as? String,
              let Subject = record["Subject"] as? String,
              let Priority = record["Priority"] as? String,
              let External_Id__c = record["External_Id__c"] as? String,
              let OwnerId = record["OwnerId"] as? String,
              let Created_TimeStamp__c = record["Created_TimeStamp__c"] as? String,
//              let Settlement_Data__c = record["Settlement_Data__c"] as? String,
              let WhatId = record["WhatId"] as? String,
              let Status = record["Status"] as? String,
              let attributesDict = record["attributes"] as? [String: Any],
              let attributesType = attributesDict["type"] as? String,
              let attributesUrl = attributesDict["url"] as? String else {
            return nil
        }
        let Settlement_Data__c = record["Settlement_Data__c"] as? String ?? ""
        let attributes = AddNewTaskModel.Attributes(type: attributesType, url: attributesUrl)
        return AddNewTaskModel(
            localId: nil,
            Id: Id,
            priority: Priority,
            Settlement_Data__c: Settlement_Data__c,
            External_Id__c: External_Id__c,
            OutletId: "",
            whatId: WhatId,
            TaskSubject: Subject,
            TaskSubtype: "",
            IsTaskRequired: "",
            TaskStatus: Status,
            OwnerId: OwnerId,
            CreatedTime: Created_TimeStamp__c,
            CreatedDate: Created_TimeStamp__c,
            createdAt: Created_TimeStamp__c,
            isSync: "1",
            attributes: attributes
        )
    }
    
    
    func executeSyncForOnTradeOffTrade(syncType: String, syncName: String, outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        print(checkIsCRM())
        let syncDownQuery = checkIsCRM()
        print(syncDownQuery)
        webRequest.processRequestUsingGetMethod(url: "\(Defaults.instanceUrl ?? "")/services/data/v59.0/query/?q=\(syncDownQuery)", parameters: nil, showLoader: true) { error, val, result, statusCode in
            print("Gettttt \(syncName): \(syncType) ")
            print(result)
            guard error == nil else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            
            guard let responseData = result as? [String: Any], let records = responseData["records"] as? [[String: Any]] else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            
            for record in records {
                if let assetModel = self.parseTradeOnTradeOffAssets(record: record) {
                    let onAssetsTable = OnAssetsTable()
                    onAssetsTable.saveAsset(assetModel: assetModel) { success, errorMessage in
                        if success {
                            print("Contact \(assetModel.Label ?? "") saved successfully.")
                        } else {
                            print("Failed to save contact \(assetModel.Label ?? ""): \(errorMessage ?? "Unknown error")")
                        }
                    }
                } else {
                    print("Failed to parse contact for record: \(record)")
                }
            }
        }
    }
}
        



