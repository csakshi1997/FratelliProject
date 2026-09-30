//
//  ProductModel.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation

struct Product {
    var abbreviation: String?
    var bottleCan: String?
    var bottleSize: String?
    var brandCode: String?
    var category: String?
    var conversionRatio: Int?
    var createdDate: String?
    var gst: String?
    var id: String?
    var isDeleted: Bool?
    var itemType: String?
    var name: String?
    var ownerId: String?
    var priority: Int?
    var productCategory: String?
    var productCode: String?
    var productFamily: String?
    var productId: String?
    var productType: String?
    var sizeCode: String?
    var sizeInMl: Int?
    var type: String?
    var attributes: Attributes?
    var isSync: String? 

    // Nested struct for attributes
    struct Attributes {
        var type: String?
        var url: String?
    }
}

