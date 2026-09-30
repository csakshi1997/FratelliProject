//
//  PromotionModel.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import Foundation

struct Promotion {
    var id: String
    var name: String
    var ownerId: String
    var productDescription: String
    var productNameId: String
    var productName: ProductName?
    var attributes: Attributes?

    // Nested struct for attributes
    struct Attributes {
        var type: String
        var url: String
    }
}
