//
//  AssetModel.swift
//  FRATELLI
//
//  Created by Sakshi on 29/11/24.
//

import Foundation

struct AssetModel {
    var localId: String?
    var IsActive: Int?
    var Label: String?
    var Value: String?
    var attributes: Attributes?

    struct Attributes {
        var type: String?
        var url: String?
    }
}

