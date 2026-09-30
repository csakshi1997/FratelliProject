//
//  AppVersionOperation.swift
//  FRATELLI
//
//  Created by Sakshi on 05/02/25.
//

import Foundation
class AppVersionOperation {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    func checkAppVersionFromAppStore(appID: Int, completion: @escaping (String?, String?) -> Void) {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = jsonResponse["results"] as? [[String: Any]], let appDetails = results.first {
                    
                    let appStoreVersion = appDetails["version"] as? String
                    completion(appStoreVersion, nil)
                } else {
                    completion(nil, "Failed to retrieve version information")
                }
            } catch {
                completion(nil, error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    func getCurrentAppVersion() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return nil
    }
    
    func compareVersions(version1: String, version2: String) -> ComparisonResult? {
        let version1Components = version1.split(separator: ".").map { Int($0) ?? 0 }
        let version2Components = version2.split(separator: ".").map { Int($0) ?? 0 }
        let count = max(version1Components.count, version2Components.count)
        for i in 0..<count {
            let v1 = i < version1Components.count ? version1Components[i] : 0
            let v2 = i < version2Components.count ? version2Components[i] : 0
            
            if v1 < v2 {
                return .orderedAscending
            } else if v1 > v2 {
                return .orderedDescending
            }
        }
        return .orderedSame
    }
    
    
    func getInternals(outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) -> () {
        var baseUrll: String = ""
        if isProduction {
            baseUrll = baseUrl
        } else if !isProduction  {
            baseUrll = timeIntervalApisBaseUrl
        }
        webRequest.processRequestUsingGetMethod(url: "\(baseUrll)\(endPoint.GET_TIMEINTERVAL)", parameters: nil, showLoader: true) { error, val, result, statusCode in
            print("GET_TIMEINTERVAL Response: \(result ?? EMPTY)")
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
