//
//  OnTrade.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import Foundation

struct OnTrade {
    var localId: String?
    var Id: String?
    var DurableId: String?
    var Label: String?
    var Value: String?
    var attributes: Attributes?
    var isSync: String?

    struct Attributes {
        var type: String?
        var url: String?
    }
}
