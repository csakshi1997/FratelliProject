//
//  OtherActivityModel.swift
//  FRATELLI
//
//  Created by Sakshi on 18/06/25.
//

import Foundation

struct OtherActivityModel {
    var localId: Int?
    var attributes: Attributes?
    var checkedOut: Bool?
    var checkedIn: Bool?
    var ownerId: String?
    var actualStart: String?
    var actualEnd: String?
    var checkedInLat: String?
    var checkedInLong: String?
    var checkedOutLat: String?
    var checkedOutLong: String?
    var outletCreation: String?
    var name: String?
    var remark: String?
    var deviceVersion: String?
    var deviceType: String?
    var deviceName: String?
    var isSync: String?

    struct Attributes {
        var referenceId: String?
        var type: String?
    }
}
