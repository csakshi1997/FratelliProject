//
//  AddNewTaskModel.swift
//  FRATELLI
//
//  Created by Sakshi on 23/12/24.
//

import Foundation


struct AddNewTaskModel {
    var localId: Int?
    var Id: String?
    var priority: String?
    var Settlement_Data__c: String?
    var External_Id__c: String?
    var OutletId: String?
    var whatId: String?
    var TaskSubject: String?
    var TaskSubtype: String?
    var IsTaskRequired: String?
    var TaskStatus: String?
    var OwnerId: String?
    var Visit_Date_c: String?
    var Visit_Order_c: String?
    var CreatedTime: String?
    var CreatedDate: String?
    var createdAt: String?
    var isSync: String?
    var attributes: Attributes?
    
    struct Attributes {
        var type: String?
        var url: String?
    }
}


