//
//  RiskStockLineItemsModel.swift
//  FRATELLI
//
//  Created by Sakshi on 28/11/24.
//

import Foundation

struct RiskStockLineItem {
    var localId: Int?
    var externalid: String?
    var Product_Name__c: String?
    var Outlet_Stock_In_Btls__c: Int?
    var Risk_Stock_In_Btls__c: Int?
    var DateTime: String?
    var ownerId: String?
    var isSync: String?
    var createdAt: String?
    var attributes: Attributes?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
}

