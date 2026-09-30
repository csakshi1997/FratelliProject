//
//  SalesOrderModel.swift
//  FRATELLI
//
//  Created by Sakshi on 16/12/24.
//

import Foundation

struct SalesOrderModel {
    var localId: Int?
    var External_Id__c: String?
    var Bulk_Upload__c: Bool
    var Distributor__Id: String?
    var DistributorName: String?
    var Customer__Id: String?
    var customerName: String?
    var Employee_Code__c: String?
    var Order_Booking_Data__c: String?
    var Distributor_Party_Code__c: String?
    var Customer_Party_Code__c: String?
    var Status__c: String?
    var dateTime: String?
    var ownerId: String?
    var addRemark: String?
    var createdAt: String?
    var isSync: String?
    var attributes: Attributes?
    var Visit_Date_c: String?
    var Visit_Order_c: String?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
}
