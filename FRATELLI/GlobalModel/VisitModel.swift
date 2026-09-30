//
//  VisitModel.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation

struct Visit {
    var localId: Int?
    var accountId: String?
    var accountReference: Account?
    var actualEnd: String?
    var actualStart: String?
    var area: String?
    var beatRoute: String?
    var channel: String?
    var checkInLocation: String?
    var checkOutLocation: String?
    var checkedInLocationLatitude: String?
    var checkedInLocationLongitude: String?
    var checkedIn: Int
    var checkedOutGeolocationLatitude: String?
    var checkedOutGeolocationLongitude: String?
    var checkedOut: Int
    var empZone: String
    var employeeCode: Int
    var id: String?
    var name: String
    var oldPartyCode: String?
    var outletCreation: String
    var outletType: String?
    var ownerId: String
    var ownerArea: String
    var partyCode: String?
    var remarks: String?
    var status: String
    var visitPlanDate: String
    var attributes: Attributes?
    var isSync: String?
    var isCompleted: String?
    var createdAt: String?
    var isNew: Int?
    var externalId: String?
    var fromAppCompleted: String?
    var Contact_Person_Name__c: String?
    var Contact_Phone_Number__c: String?

    // Nested struct for attributes
    struct Attributes {
        var type: String
        var url: String
    }
    
    struct Account {
            let classification: String
            let id: String
            let name: String
            let ownerId: String
            let subChannel: String
        }
}



