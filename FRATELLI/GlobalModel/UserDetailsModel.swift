//
//  UserDetailsModel.swift
//  FRATELLI
//
//  Created by Sakshi on 17/06/25.
//

import Foundation

struct UserDetailsModel {
    var id: String?
    var firstName: String?
    var lastName: String?
    var displayName: String?
    var email: String?
    var mobilePhone: String?
    var mobilePhoneVerified: Bool?
    var emailVerified: Bool?
    var pictureUrl: String?
    var thumbnailUrl: String?
    var userId: String?
    var organizationId: String?
    var timezone: String?
    var locale: String?
    var language: String?
    var username: String?
    var userType: String?
    var customDomain: String?
    
    // NEW address fields
    var addrStreet: String?
    var addrCity: String?
    var addrState: String?
    var addrCountry: String?
    var addrZip: String?
    
    // NEW additional fields
    var isLightningLoginUser: Bool?
    var status: Status?

    struct Status {
        var createdDate: String?
        var body: String?
    }
}
