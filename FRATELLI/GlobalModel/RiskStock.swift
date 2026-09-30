//
//  RiskStock.swift
//  FRATELLI
//
//  Created by Sakshi on 28/11/24.
//

import Foundation

struct RiskStock {
    var localId: Int?
    var externalid: String?
    var DateTime: String?
    var outletId: String?
    var ownerId: String?
    var isInitiateCustomerPromotion: Bool?
    var remarks: String?
    var isSync: String?
    var createdAt: String?
    var attributes: Attributes?
    var Visit_Date_c: String?
    var Visit_Order_c: String?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
}
