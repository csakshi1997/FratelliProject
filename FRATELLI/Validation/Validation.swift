//
//  Validation.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation

class Validation: NSObject {
    func extractTokens(from url: String) -> (orgToken: String?, uID: String?) {
        let pattern = "/(00DC\\w+)/([\\w%]+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (nil, nil)
        }
        
        let nsString = url as NSString
        let results = regex.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            let orgToken = nsString.substring(with: match.range(at: 1))
            let uID = nsString.substring(with: match.range(at: 2)).replacingOccurrences(of: "%22", with: "")
            return (orgToken, uID)
        }
        return (nil, nil)
    }
    
    func extractTokensForProduction(from url: String) -> (orgToken: String?, uID: String?) {
        // Adjusted pattern to match the given URL structure
        let pattern = "/(00D\\w+)/([\\w%]+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (nil, nil)
        }
        
        let nsString = url as NSString
        let results = regex.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            // Extracting the matched groups
            let orgToken = nsString.substring(with: match.range(at: 1))
            let uID = nsString.substring(with: match.range(at: 2)).replacingOccurrences(of: "%22", with: "")
            return (orgToken, uID)
        }
        return (nil, nil)
    }

    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
