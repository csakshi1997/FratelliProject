//
//  CustomDateFormatter.swift
//  FRATELLI
//
//  Created by Sakshi on 22/10/24.
//

import Foundation
import UIKit

class CustomDateFormatter {
    func getTodayDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatOneType
        let todayDate = Date()
        return dateFormatter.string(from: todayDate)
    }
    
    func getDateForVisits(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM"
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func getDateForSettlement(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Input format with timezone
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd" // Desired output format
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func getDatePlanVisitInCaseOfADHOC(from date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }
    
    func getDateForVisitsOrderDate(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM"
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    static func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" 
        return dateFormatter.string(from: Date())
    }
    
    static func getCurrentDateTimeForSalesOrder() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    static func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getFormattedDateForAccount() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"  // Specify the format including timezone
        formatter.timeZone = TimeZone.current  // Use the current time zone (e.g., +0530 for India Standard Time)
        
        let currentDate = Date()
        return formatter.string(from: currentDate)
    }
    
    func getFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss" // Specify the time format
        formatter.timeZone = TimeZone.current // Use the current time zone
        
        let currentDate = Date()
        return formatter.string(from: currentDate)
    }
}
