//
//  ContactModel.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation

struct Contact {
    var localId: Int?
    var aadharNo: String?
    var accountId: String?
    var email: String?
    var firstName: String?
    var contactId: String?
    var lastName: String?
    var middleName: String?
    var name: String?
    var ownerId: String?
    var phone: String?
    var remark: String?
    var salutation: String?
    var title: String?
    var attributes: Attributes?
    var isSync: String?
    var workingWithOutlet: Int?
    var createdAt: String?
    var Visit_Date_c: String?
    var Visit_Order_c: String?
    var External_id: String?

    struct Attributes {
        var type: String?
        var url: String?
    }
}


