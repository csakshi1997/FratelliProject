//
//  SalesOrderLineItems.swift
//  FRATELLI
//
//  Created by Sakshi on 16/12/24.
//

import Foundation

struct SalesOrderLineItems {
    var localId: Int?
    var External_Id__c: String?
    var Product__ID: String?
    var Product_Name: String?
    var Scheme_Type__c: String?
    var Total_Amount_INR__c: String?
    var Free_Issue_Quantity_In_Btls__c: String?
    var Scheme_Percentage__c: String?
    var Product_quantity_c: String?
    var dateTime: String?
    var ownerId: String?
    var createdAt: String?
    var isSync: String?
    var attributes: Attributes?
    var addRemark: String?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
}
