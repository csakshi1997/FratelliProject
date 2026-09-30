//
//  OutletsModel.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation

struct Outlet {
    let localId: Int?
    let accountId: String?
    let accountStatus: String?
    let annualTargetData: String?
    let area: String?
    let billingCity: String?
    let billingCountry: String?
    let billingCountryCode: String?
    let billingState: String?
    let billingStateCode: String?
    let billingStreet: String?
    let channel: String?
    let checkedInLocationLatitude: String?
    let checkedInLocationLongitude: String?
    let classification: String?
    let distributorCode: String?
    let distributorName: String?
    let distributorPartyCode: String?
    let email: String?
    let gstNo: String?
    let groupName: String?
    let growth: String?
    let id: String?  
    let industry: String?
    let lastVisitDate: String?
    let licenseCode: String?
    let license: String?
    let marketShare: String?
    let name: String?
    let outletType: String?
    let ownerId: String?
    let ownerManager: String?
    let panNo: String?
    let partyCodeOld: String?
    let partyCode: String?
    let phone: String?
    let salesType: String?
    let salesmanCode: String?
    let status: Int?
    let subChannelType: String?
    let subChannel: String?
    let supplierGroup: String?
    let supplierManufacturerUnit: String?
    let type: String?
    let yearLastYear: String?
    let years: String?
    let zone: String?
    let parentId: String?
    let attributes: Attributes?
    var isSync: String? 
    let checkIn: Int?
    let createdAt: String?
    let Asset_Visibility__c: String?
    let Current_Market_Share__c: String?

    struct Attributes {
        let type: String?
        let url: String?
    }
}


