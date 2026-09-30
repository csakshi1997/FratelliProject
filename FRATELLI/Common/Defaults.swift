//
//  Defaults.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import Foundation
import UIKit

class Defaults {
    static var accessToken: String? {
        get {
            return UserDefaults.standard.object(forKey: "accessToken") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var refreshToken: String? {
        get {
            return UserDefaults.standard.object(forKey: "Refresh_Token") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Refresh_Token")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func storeCheckInStatus(isCheckedIn: Bool) {
        UserDefaults.standard.set(isCheckedIn, forKey: "checkIn")
    }
    
    static var isSyncUpComplete: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "LoginFirstTime") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LoginFirstTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isTrackingStart: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsTrackingStart") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsTrackingStart")
            UserDefaults.standard.synchronize()
        }
    }

    static func storeCheckOutStatus(isCheckedOut: Bool) {
        UserDefaults.standard.set(isCheckedOut, forKey: "checkOut")
    }
    
    static var instanceUrl: String? {
        get {
            return UserDefaults.standard.object(forKey: "Instance_Url") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Instance_Url")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userId: String? {
        get {
            return UserDefaults.standard.object(forKey: "UserId") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserId")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var id: String? {
        get {
            return UserDefaults.standard.object(forKey: "Id") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Id")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userArea: String? {
        get {
            return UserDefaults.standard.object(forKey: "UserArea") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserArea")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var savedCurrentDate: String? {
        get {
            return UserDefaults.standard.string(forKey: "savedCurrentDate") ?? EMPTY
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "savedCurrentDate")
        }
    }

    static var savedCurrentTime: String? {
        get {
            return UserDefaults.standard.string(forKey: "savedCurrentTime") ?? EMPTY
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "savedCurrentTime")
        }
    }
    
    static var organizationToken: String? {
        get {
            return UserDefaults.standard.object(forKey: "OrganizationToken") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "OrganizationToken")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var signature: String? {
        get {
            return UserDefaults.standard.object(forKey: "Signature") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Signature")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var tokenType: String? {
        get {
            return UserDefaults.standard.object(forKey: "Token_Type") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Token_Type")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isFirstTimeLogin: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "LoginFirstTime") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LoginFirstTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var incompleteVisitName: String? {
        get {
            return UserDefaults.standard.object(forKey: "IncompleteVisitName") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IncompleteVisitName")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isIncompleteVisitName: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsIncompleteVisitName") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsIncompleteVisitName")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isSyncUpDone: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "SyncUpDone") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SyncUpDone")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userName: String? {
        get {
            return UserDefaults.standard.object(forKey: "UserName") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserName")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var Location_Proximity__c: Int? {
        get {
            return UserDefaults.standard.object(forKey: "Location_Proximity__c") as? Int ?? 60
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Location_Proximity__c")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var Tracking_Interval_Sec__c: Int? {
        get {
            return UserDefaults.standard.object(forKey: "Tracking_Interval_Sec__c") as? Int ?? 30
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Tracking_Interval_Sec__c")
            UserDefaults.standard.synchronize()
        }
    }
    

    static var userEmail: String? {
        get {
            return UserDefaults.standard.object(forKey: "UserEmail") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserEmail")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userPassword: String? {
        get {
            return UserDefaults.standard.object(forKey: "UserPassword") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserPassword")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userLastName: String? {
        get {
            return UserDefaults.standard.object(forKey: "userLastName") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userLastName")
            UserDefaults.standard.synchronize()
        }
    }

    static func storeLastChcekInDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: currentDate)
        UserDefaults.standard.set(formattedDate, forKey: "lastSyncDate")
    }
    
    static var userFirstName: String? {
        get {
            return UserDefaults.standard.object(forKey: "userFirstName") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userFirstName")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userMobileNumber: String? {
        get {
            return UserDefaults.standard.object(forKey: "userMobileNumber") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userMobileNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isUserLoggedIn: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsUserLoggedIn") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsUserLoggedIn")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isAuthenticationfailedAtTheTimeOfSync: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsAuthenticationfailedAtTheTimeOfSync") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsAuthenticationfailedAtTheTimeOfSync")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isSyncUpProcessCompleted: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsSyncUpProcessCompleted") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsSyncUpProcessCompleted")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isStartDay: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "IsStartDay") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IsStartDay")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var trackingStartDate: String? {
        get {
            return UserDefaults.standard.string(forKey: "TrackingStartDate") ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TrackingStartDate")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userImage: UIImage? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "UserProfileImage") else { return UIImage(named: "HomeProfileIcon") }
            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
            let image = UIImage(data: decoded)
            return image
        }
        set {
            guard let data = newValue?.jpegData(compressionQuality: 0.5) else { return }
            let encoded = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: "UserProfileImage")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func removeUserImage() {
        UserDefaults.standard.removeObject(forKey: "UserProfileImage")
        UserDefaults.standard.synchronize()
    }
 
    static var APNSTokenSave: String? {
        get {
            if let previousAppVersion = UserDefaults.standard.object(forKey: "apnstoken") as? String {
                return previousAppVersion
            }
            return EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apnstoken")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isCalenderSync: Bool? {
        get {
            return UserDefaults.standard.object(forKey: "CalenderSync") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CalenderSync")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var inCompleteVisitName: String? {
        get {
            return UserDefaults.standard.object(forKey: "InCompleteVisitName") as? String ?? EMPTY
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "InCompleteVisitName")
            UserDefaults.standard.synchronize()
        }
    }
}
