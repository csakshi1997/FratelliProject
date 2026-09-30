//
//  LocationModel.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation

struct LocationModel {
    var id: Int?
    var isOfflineRecord: Bool?
    var latitude: Double?
    var longitude: Double?
    var diffrenceBetweenCurrentAndLastLatLong: Double?
    var address: String?
    var isMockLocation: Int?
    var dateTime: String?
    var batteryPercentage: Int?
    var deviceModel: String?
    var deviceManufacturer: String?
}
