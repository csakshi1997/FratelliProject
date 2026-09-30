//
//  VisibilityServerModel.swift
//  FRATELLI
//
//  Created by Sakshi on 20/06/25.
//

import Foundation

struct VisibilityServerModel {
    var localId:Int?
    var userId: String?
    var fileType: String?
    var fileName: String?
    var isSync: String?
    var createdAt: String
    
    var assetName: String?
    var externalId: String?
    var dealerDistributorCorpId: String?
    var deviceName: String?
    var deviceVersion: String?
    var deviceType: String?
    var visitOrderId: String?
    var imagePublicUrl: String? // to be filled after upload
    
}
