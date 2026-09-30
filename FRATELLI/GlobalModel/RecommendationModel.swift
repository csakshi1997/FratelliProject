//
//  RecommendationModel.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation

struct ProductName {
    var id: String
    var name: String
    var productDescription: String?
    var productImageLink: String?
    var attributes: Attributes?

    // Nested struct for attributes
    struct Attributes {
        var type: String
        var url: String
    }
}

// Struct representing a Recommendation
struct Recommendation {
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

