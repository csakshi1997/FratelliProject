//
//  SkipModel.swift
//  FRATELLI
//
//  Created by Sakshi on 05/02/25.
//

import Foundation

struct SkipModel {
    var localId: Int?
    var accountId: String?
    var accountReference: Account?
    var Visit_Order__c: String?
    var Dealer_Distributor_CORP__c: String?
    var OwnerId: String?
    var Meet_Greet__c: String?
    var Risk_Stock__c: String?
    var Asset_Visibility__c: String?
    var POSM_Request__c: String?
    var Sales_Order__c: String?
    var QCR__c: String?
    var Follow_up_task__c: String?
    var isNew: String?
    var attributes: Attributes?
    var isSync: String?
    var Visit_Date_c: String?
    var Visit_Order_c: String?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
    
    struct Account {
        let classification: String
        let id: String
        let name: String
        let ownerId: String
        let subChannel: String
    }
}

