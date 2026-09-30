//
//  AssetRequisitionModel.swift
//  FRATELLI
//
//  Created by Sakshi on 20/01/25.
//

import Foundation

struct AssetRequisitionModel {
    var localId: String?
    var IsActive: Bool?
    var Label: String?
    var Value: String?
    var attributes: Attributes?
    var isSync: String?

    struct Attributes {
        var type: String?
        var url: String?
    }
}

