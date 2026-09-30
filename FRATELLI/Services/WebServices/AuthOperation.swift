//
//  AuthOperation.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import Foundation
import UIKit

class AuthOperation {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    
    func executLogin(userDetail: [String: Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) -> () {
        var components = URLComponents(string: LoginBaseURL)
        components?.queryItems = userDetail.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
            guard let finalURL = components?.url else {
                print("Error creating URL")
                return
            }
        print(finalURL)
        webRequest.processRequestUsingPostMethod(url: "\(finalURL)", parameters: userDetail, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Login Response: \(result ?? EMPTY)")
            guard error == nil else {
                outerClosure(error, result as? [String: Any], Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            guard let responseData = (result as? [String: Any]) else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
        }
    }
    
    func sendDeviceToken(details: [String: Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) -> () {
        webRequest.processRequestUsingPostMethod(url: "\(baseUrl)\(endPoint.SEND_DEVICE_TOKEN)", parameters: details, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("SEND_DEVICE_TOKEN Response: \(result ?? EMPTY)")
            guard error == nil else {
                outerClosure(error, result as? [String: Any], Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            guard let responseData = (result as? [String: Any]) else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
        }
    }
    
    func sendSobjects(details: [String: Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) -> () {
        webRequest.processRequestUsingPostMethod(url: "\(baseUrl)\(endPoint.S_OBJECTS)", parameters: details, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("S_OBJECTS Response: \(result ?? EMPTY)")
            guard error == nil else {
                outerClosure(error, result as? [String: Any], Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            guard let responseData = (result as? [String: Any]) else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
        }
    }
    
    func getUserDetails(outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) -> () {
        webRequest.processRequestUsingPostMethod(url: "\(Defaults.id ?? EMPTY)", parameters: nil, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("User Details Response: \(result ?? EMPTY)")
            guard error == nil else {
                outerClosure(error, result as? [String: Any], Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            guard let responseData = (result as? [String: Any]) else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
        }
    }
}
