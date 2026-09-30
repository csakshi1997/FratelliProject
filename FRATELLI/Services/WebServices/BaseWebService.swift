//
//  BaseWebService.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import Foundation
import UIKit
import Alamofire

struct EndPoints {
    var SEND_QCR = "composite/tree/QCR__c/"
    var SEND_ACCOUNT = "composite/tree/Account/"
    var SEND_ADVOCACY_REQUEST = "composite/tree/Advocacy_Request__c/"
    var CONATCT = "composite/tree/Contact/"
    var SEND_SALES_ORDER = "composite/tree/Sales_Order__c/"
    var SEND_SALES_ORDER_LINE_ITEMS = "composite/tree/Order_Item__c/"
    var SEND_RISK_STOCKS = "composite/tree/Risk_Stock__c/"
    var SEND_RISK_STOCK_LINE_ITEMS = "composite/tree/Risk_Stock_Line_Item__c/"
    var SEND_POSM_REQUEST = "composite/tree/POSM__c/"
    var SEND_POSM_LINE_ITEMS_REQUEST = "composite/tree/POSM_Line_Item__c/"
    var SEND_SALES_ORDERS = "composite/tree/Sales_Order__c/"
    var SEND_ORDER_LINE_ITEMS = "composite/tree/Order_Item__c/"
    var SEND_ASSET_VISIBILITY = "composite/tree/Order_Item__c/"
    var SEND_ASSET_REQUEST = "composite/tree/Order_Item__c/"
    var SEND_ASSET_LINE_ITEMS_REQUEST = "composite/tree/Order_Item__c/"
    var SEND_ACTION_ITEMS = "composite/tree/Task/"
    var SEND_CALL_FOR_HELP = "composite/tree/Call_For_Help__c/"
    var SEND_LOCATION = "composite/tree/HMI__User_Location_Track__c/"
    var SEND_SKIP = "composite/tree/Outlet_Adherance_Report__c/"
    var SEND_OTHER_ACTIVITIES = "composite/tree/Visits__c/"
    var SEND_VISIT = "composite/sobjects/Visits__c/Id/"
    var QCR_IMAGE_UPLOAD = "services/apexrest/fileUpload"
    var SEND_DEVICE_TOKEN = "services/apexrest/checkUserDevice"
    var S_OBJECTS = "services/data/v59.0/composite/Sobjects"
    var GET_TIMEINTERVAL = "services/data/v59.0/query/?q=SELECT Id, Username, LastName, FirstName, MiddleName, Suffix, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, StateCode, CountryCode, Latitude, Longitude, GeocodeAccuracy, Address, Email, IsProfilePhotoActive, Branch__c, Employee_Code__c, Field_Sales_User__c, EMP_Channel__c, EMP_Zone__c, Area__c, Channel__c, State__c, Zone__c, Sub_Manager__c, Shift_Timing__c, First_Check_In__c, Last_Check_Out__c, Visit_Activity__c, Count__c, Remark_s__c, Check_In_Date_Time__c, Check_Out_Date_Time__c, Check_In_Geolocation__Latitude__s, Check_In_Geolocation__Longitude__s, Check_In_Geolocation__c, Check_Out_Geolocation__Latitude__s, Check_Out_Geolocation__Longitude__s, Check_Out_Geolocation__c, Comment__c, CheckInDate__c, CheckOut_Date__c, User_CheckIn_Update__c, Location_Proximity__c, Tracking_Interval_Sec__c, Device_Id__c FROM User where Id='\(Defaults.userId ?? "")'"
    var ERROR_LOG = "composite/tree/Error_log__c"
    var SALESFORCE_IMAGE_UPLOAD = "composite/tree/Image_Visibility__c/"
}

enum ContentType: String {
    case multipart = "multipart/form-data"
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
    case none = ""
}

let tokenExpiredErrorMessage = "Session expired or invalid"

class BaseWebService {
    let validation = Validation()
    let reachabilityManager = NetworkReachabilityManager()
    func setLoader() {
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 100
        config.spinnerColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        config.foregroundColor = .black
        config.foregroundAlpha = 0.5
        SwiftLoader.setConfig(config: config)
    }
    
    func getHeader(contentType: ContentType = .json) ->  [String: String] {
        var header: [String: String] = [:]
        if !(Defaults.accessToken ?? "").isEmpty {
            header["Authorization"] = "Bearer \(Defaults.accessToken ?? "")"
        }
        if contentType == .multipart {
            header["Content-Type"] = "multipart/form-data"
        } else if contentType == .json  {
            header["Content-Type"] = "application/json"
            header["accept"] = "application/json"
        } else if contentType == .urlEncoded  {
            header["Content-Type"] = "application/x-www-form-urlencoded"
        } else if contentType == .none {
        }
        return header
    }
    
//    func processRequestUsingPostMethod(url: String, parameters: [String: Any]?, showLoader: Bool, contentType: ContentType, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
//        print(url)
//        setLoader()
//        if !reachabilityManager!.isReachable {
//            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
//            return
//        }
//        if showLoader == true {
//            SwiftLoader.show(title: "Loading...", animated: true)
//        }
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getHeader(contentType: contentType)))
//            .responseJSON { response in
//                print(response)
//                SwiftLoader.hide()
//                let dict = response.value as? [String : Any] ?? [:]
//                print(dict)
//                let errorDict = dict["error"] as? [String : Any] ?? [:]
//                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
//                if let statusCode = response.response?.statusCode {
//                    if (statusCode == 401) {
//                        if errorMessage == tokenExpiredErrorMessage {
//                            Utility.tokenExpiredAction()
//                            self.logInAPI()
//                            closure(errorMessage, false, nil, statusCode)
//                        } else {
//                            closure(errorMessage, false, nil, statusCode)
//                        }
//                        self.logInAPI()
////                        return
//                    }
//                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
//                        closure(nil, true, response.value, statusCode)
//                    } else {
//                        let dict = response.value as? [String : Any] ?? [:]
//                        closure(errorMessage, false, dict, statusCode)
//                    }
//                } else {
//                    closure(errorMessage, false, nil, response.response?.statusCode)
//                }
//            }
//    }
    
    func processRequestUsingPostMethod(url: String, parameters: [String: Any]?, showLoader: Bool, contentType: ContentType, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        print("Requesting: \(url)")
        setLoader()

        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }

        if showLoader {
            SwiftLoader.show(title: "Loading...", animated: true)
        }

        let headers = HTTPHeaders(getHeader(contentType: contentType))
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                SwiftLoader.hide()
                print("Response: \(response)")
                
                let dict = response.value as? [String: Any] ?? [:]
                let errorDict = dict["error"] as? [String: Any] ?? [:]
                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
                
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.logInAPI { success in
                            if success {
                                self.processRequestUsingPostMethod(url: url, parameters: parameters, showLoader: showLoader, contentType: contentType, closure: closure)
                            } else {
                                // Redirect to Login Screen if auto-login fails
                                self.redirectToLoginScreen(withMessage: "Your password has changed. Please log in again.")
                                closure(errorMessage, false, nil, statusCode)
                            }
                        }
                        return
                    }
                    
                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                        closure(nil, true, response.value, statusCode)
                    } else {
                        closure(errorMessage, false, dict, statusCode)
                    }
                } else {
                    closure(errorMessage, false, nil, response.response?.statusCode)
                }
            }
    }
    
//    func processRequestUsingPostMethodForSync(url: String, parameters: [String: Any]?, showLoader: Bool, contentType: ContentType, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
//        print("Requesting: \(url)")
//        setLoader()
//
//        if !reachabilityManager!.isReachable {
//            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
//            return
//        }
//
//        if showLoader {
//            SwiftLoader.show(title: "Loading...", animated: true)
//        }
//
//        let headers = HTTPHeaders(getHeader(contentType: contentType))
//        
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .responseJSON { response in
//                SwiftLoader.hide()
//                print("Response: \(response)")
//                
//                let dict = response.value as? [[String: Any]] ?? []
//                let errorDict = dict["error"] as? [String: Any] ?? [:]
//                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
//                
//                if let statusCode = response.response?.statusCode {
//                    if statusCode == 401 {
//                        // Auto-login when 401 is received
//                        self.logInAPI { success in
//                            if success {
//                                // Retry the API request after successful login
//                                self.processRequestUsingPostMethod(url: url, parameters: parameters, showLoader: showLoader, contentType: contentType, closure: closure)
//                            } else {
//                                // Redirect to Login Screen if auto-login fails
//                                self.redirectToLoginScreen(withMessage: "Your password has changed. Please log in again.")
//                                closure(errorMessage, false, nil, statusCode)
//                            }
//                        }
//                        return
//                    }
//                    
//                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
//                        closure(nil, true, response.value, statusCode)
//                    } else {
//                        closure(errorMessage, false, dict, statusCode)
//                    }
//                } else {
//                    closure(errorMessage, false, nil, response.response?.statusCode)
//                }
//            }
//    }
    
    func redirectToLoginScreen(withMessage message: String) {
        DispatchQueue.main.async {
            Defaults.isUserLoggedIn = false
            let alert = UIAlertController(title: "Session Expired", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                Utility.logoutWithoutDatabaseAffection(sessionTimeOutAtTheTimeOfSync: true)
            }))
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func logInAPI(completion: @escaping (Bool) -> Void) {
        let authOperation = AuthOperation()
        let userData = [
            "grant_type": grant_type,
            "client_id": client_id,
            "client_secret": client_secret,
            "username": Defaults.userEmail ?? "",
            "password": Defaults.userPassword ?? ""
        ] as [String: Any]
        
        authOperation.executLogin(userDetail: userData) { error, response, status in
            if status == .success {
                let dict = response ?? [:]
                Defaults.accessToken = dict["access_token"] as? String
                Defaults.instanceUrl = dict["instance_url"] as? String
                Defaults.signature = dict["signature"] as? String
                Defaults.tokenType = dict["token_type"] as? String
                
                if isProduction {
                    let tokens = self.validation.extractTokensForProduction(from: dict["id"] as? String ?? EMPTY)
                    Defaults.userId = tokens.uID
                    Defaults.organizationToken = tokens.orgToken
                } else {
                    let tokens = self.validation.extractTokens(from: dict["id"] as? String ?? EMPTY)
                    Defaults.userId = tokens.uID
                    Defaults.organizationToken = tokens.orgToken
                }

                Defaults.isUserLoggedIn = true
                print("Auto-login successful")
                completion(true)  // Notify success
            } else {
                print("Auto-login failed")
                completion(false) // Notify failure
            }
        }
    }
    
    func processRequestUsingGetMethod(url: String, parameters: [String: Any]?, showLoader: Bool,  closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        print("urlllll \(url)")
        setLoader()
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }
        if showLoader == true {
            SwiftLoader.show(title: "Loading...", animated: true)
        }
        AF.request(url, method: .get, parameters: parameters, headers: HTTPHeaders(getHeader()))
            .responseJSON { response in
                SwiftLoader.hide()
                let dict = response.value as? [String : Any] ?? [:]
                let errorDict = dict["error"] as? [String : Any] ?? [:]
                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
                if let statusCode = response.response?.statusCode {
                    if (statusCode == 401) {
                        if errorMessage == tokenExpiredErrorMessage {
                            Utility.tokenExpiredAction()
                            closure(errorMessage, false, nil, statusCode)
                        } else {
                            closure(errorMessage, false, nil, statusCode)
                        }
                        return
                    }
                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                        closure(nil, true, response.value, statusCode)
                    } else {
                        let dict = response.value as? [String : Any] ?? [:]
                        closure(dict["message"] as? String ?? ERROR_OCCURRED, false, dict, statusCode)
                    }
                } else {
                    closure(errorMessage, false, nil, response.response?.statusCode)
                }
            }
    }
    
    func processRequestUsingPutMethod(url: String, parameters: [String: Any]?, showLoader: Bool, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        setLoader()
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }
        if showLoader {
            DispatchQueue.main.async() {
                SwiftLoader.show(title: "Loading...", animated: true)
            }
        }
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getHeader(contentType: .json))) .responseJSON { response in
            SwiftLoader.hide()
            let dict = response.value as? [String : Any] ?? [:]
            let errorDict = dict["error"] as? [String : Any] ?? [:]
            let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
            if let statusCode = response.response?.statusCode {
                if (statusCode == 401) {
                    if errorMessage == tokenExpiredErrorMessage {
                        Utility.tokenExpiredAction()
                        closure(errorMessage, false, nil, statusCode)
                    } else {
                        closure(errorMessage, false, nil, statusCode)
                    }
                    return
                }
                if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                    closure(nil, true, response.value, statusCode)
                } else {
                    let dict = response.value as? [String : Any] ?? [:]
                    closure(dict["message"] as? String ?? ERROR_OCCURRED, false, dict, statusCode)
                }
            } else {
                closure(errorMessage, false, nil, response.response?.statusCode)
            }
        }
    }
    
    func processRequestUsingDeleteMethod(url: String, parameters: [String: Any]?, showLoader: Bool, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        setLoader()
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }
        if showLoader {
            DispatchQueue.main.async() {
                SwiftLoader.show(title: "Loading...", animated: true)
            }
        }
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getHeader(contentType: .json)))
            .responseJSON { response in
                SwiftLoader.hide()
                let dict = response.value as? [String : Any] ?? [:]
                let errorDict = dict["error"] as? [String : Any] ?? [:]
                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
                if let statusCode = response.response?.statusCode {
                    if (statusCode == 401) {
                        if errorMessage == tokenExpiredErrorMessage {
                            Utility.tokenExpiredAction()
                            closure(errorMessage, false, nil, statusCode)
                        } else {
                            closure(errorMessage, false, nil, statusCode)
                        }
                        return
                    }
                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                        closure(nil, true, response.value, statusCode)
                    } else {
                        let dict = response.value as? [String : Any] ?? [:]
                        closure(dict["message"] as? String ?? ERROR_OCCURRED, false, dict, statusCode)
                    }
                } else {
                    closure(errorMessage, false, nil, response.response?.statusCode)
                }
            }
    }
    
    func multipartSingleImageUpload(isUpdate: Bool, url: String, imageKey: String, image: UIImage, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }
        setLoader()
        SwiftLoader.show(title: "Loading...", animated: true)
        var httpMethod = HTTPMethod(rawValue: "POST")
        if isUpdate {
            httpMethod =  HTTPMethod(rawValue: "PUT")
        }
        AF.upload(multipartFormData: { multiPart in
            multiPart.append((image.jpegData(compressionQuality: 1.0)!), withName: imageKey, fileName: "\(Utility.getUniqueName()).jpeg", mimeType: "image/jpeg")
        }, to: url, method: httpMethod , headers: HTTPHeaders(getHeader(contentType: .multipart)))
        .uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { response in
            SwiftLoader.hide()
            let dict = response.value as? [String : Any] ?? [:]
            let errorDict = dict["error"] as? [String : Any] ?? [:]
            let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
            if let statusCode = response.response?.statusCode {
                if (statusCode == 401) {
                    if errorMessage == tokenExpiredErrorMessage {
                        Utility.tokenExpiredAction()
                        closure(errorMessage, false, nil, statusCode)
                    } else {
                        closure(errorMessage, false, nil, statusCode)
                    }
                }
                if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                    closure(nil, true, response.value, statusCode)
                } else {
                    let dict = response.value as? [String : Any] ?? [:]
                    closure(errorMessage, false, dict, statusCode)
                }
            } else {
                closure(errorMessage, false, nil, response.response?.statusCode)
            }
        })
    }
    
    func multipartUploadImagewithParam(url: String, parameters: [String: Any]?, multupleImages: [UIImage], isUpdate: Bool = false, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }
        setLoader()
        SwiftLoader.show(title: "Loading...", animated: true)
        var httpMethod = HTTPMethod(rawValue: "POST")
        if isUpdate {
            httpMethod = HTTPMethod(rawValue: "PUT")
        }
        AF.upload(multipartFormData:{
            (multipartFormData) in
            for (key, value) in parameters! {
                if value is [String] {
                    let array = value as? [String] ?? []
                    for data in array {
                        multipartFormData.append((data as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key, mimeType: "text")
                    }
                } else {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key, mimeType: "text")
                }
            }
            for img in multupleImages {
                multipartFormData.append((img.jpegData(compressionQuality: 1.0)!), withName: "attachments", fileName: "\(Utility.getUniqueName()).jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: httpMethod , headers: HTTPHeaders(getHeader(contentType: .multipart)))
        .uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { response in
            SwiftLoader.hide()
            let dict = response.value as? [String : Any] ?? [:]
            let errorDict = dict["error"] as? [String : Any] ?? [:]
            let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
            if let statusCode = response.response?.statusCode {
                if (statusCode == 401) {
                    if errorMessage == tokenExpiredErrorMessage {
                        Utility.tokenExpiredAction()
                        closure(errorMessage, false, nil, statusCode)
                    } else {
                        closure(errorMessage, false, nil, statusCode)
                    }
                }
                if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                    closure(nil, true, response.value, statusCode)
                } else {
                    let dict = response.value as? [String : Any] ?? [:]
                    closure(errorMessage, false, dict, statusCode)
                }
            } else {
                closure(errorMessage, false, nil, response.response?.statusCode)
            }
        })
    }
    
//    func processRequestUsingPatchMethod(url: String, parameters: [String: Any]?, showLoader: Bool, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
//        setLoader()
//        if !reachabilityManager!.isReachable {
//            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
//            return
//        }
//        if showLoader {
//            DispatchQueue.main.async() {
//                SwiftLoader.show(title: "Loading...", animated: true)
//            }
//        }
//        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getHeader(contentType: .json))) .responseJSON { response in
//            SwiftLoader.hide()
//            print(response)
//            let dict = response.value as? [[String : Any]] ?? []
//            let errorDict = dict[0]
//            let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED
//            if let statusCode = response.response?.statusCode {
//                if (statusCode == 401) {
//                    if errorMessage == tokenExpiredErrorMessage {
////                        Utility.tokenExpiredAction()
//                        
////                        closure(errorMessage, false, nil, statusCode)
//                    } else {
//                        closure(errorMessage, false, nil, statusCode)
//                    }
//                    self.logInAPI()
////                    return
//                }
//                if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
//                    closure(nil, true, response.value, statusCode)
//                } else {
//                    let dict = response.value as? [String : Any] ?? [:]
//                    closure(dict["message"] as? String ?? ERROR_OCCURRED, false, dict, statusCode)
//                }
//            } else {
//                closure(errorMessage, false, nil, response.response?.statusCode)
//            }
//        }
//    }
    
    func processRequestUsingPatchMethod(url: String, parameters: [String: Any]?, showLoader: Bool, closure:@escaping (String?, Bool?, Any?, Int?) -> ()) {
        setLoader()
        
        if !reachabilityManager!.isReachable {
            closure(INTERNET_NOT_AVAILABLE_STR, false, nil, nil)
            return
        }

        if showLoader {
            DispatchQueue.main.async {
                SwiftLoader.show(title: "Loading...", animated: true)
            }
        }

        let headers = HTTPHeaders(getHeader(contentType: .json))

        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                SwiftLoader.hide()
                print("Response: \(response)")

                let dict = response.value as? [[String: Any]] ?? []
                let errorDict = dict.first ?? [:]
                let errorMessage = errorDict["message"] as? String ?? ERROR_OCCURRED

                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        // Auto-login on 401 Unauthorized
                        self.logInAPI { success in
                            if success {
                                // Retry the failed API request after successful login
                                self.processRequestUsingPatchMethod(url: url, parameters: parameters, showLoader: showLoader, closure: closure)
                            } else {
                                // If login fails, return error
                                closure(errorMessage, false, nil, statusCode)
                            }
                        }
                        return
                    }

                    if statusCode == 200 || statusCode == 201 || statusCode == 203 || statusCode == 204 {
                        closure(nil, true, response.value, statusCode)
                    } else {
                        let dict = response.value as? [String: Any] ?? [:]
                        closure(dict["message"] as? String ?? ERROR_OCCURRED, false, dict, statusCode)
                    }
                } else {
                    closure(errorMessage, false, nil, response.response?.statusCode)
                }
            }
    }
}

