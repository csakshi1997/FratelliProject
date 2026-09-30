//
//  Constant.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

var DeviceId : String = UIDevice.current.identifierForVendor!.uuidString
var applicationID = 6740630208
let AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String
let BundleID = Bundle.main.bundleIdentifier
var Device_Token : String = EMPTY
var selectedTabIndex : Int = 0
var currentVisitId: String = ""
var externalID: String = ""
var visitPlanDate: String = ""
var globalExternalIdTime: String = ""
var currentSelectedVisitId: String = ""
var chcekInDate: String = ""
var chcekintime: String = ""
var savedCurrentDate: String = ""
var savedCurrentTime: String = ""
var Contact_Person_Name__c: String = ""
var Contact_Phone_No__c: String = ""


var offTrade : String = "SELECT Value,Label,IsActive FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'Account' AND EntityParticle.QualifiedApiName ='Off_Trade__c'"
var onTrade : String = "SELECT Value,Label,IsActive FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'Account' AND EntityParticle.QualifiedApiName ='On_Trade_Institution__c'"


#if DEBUG
let AppMode = "DevelopmentMode"
let baseUrl = "https://fratelliwines--partialcop.sandbox.my.salesforce.com/"
let apiUrl = "https://fratelliwines--partialcop.sandbox.my.salesforce.com/services/data/v59.0/"
let LoginBaseURL : String = "https://test.salesforce.com/services/oauth2/token"
let timeIntervalApisBaseUrl: String = "https://fratelliwines--partialcop.sandbox.my.salesforce.com/"
var isoffTrade: Bool = false
var grant_type : String = "password"
var client_id : String = "3MVG9D6vJTURvMytOsSiBxtNlpmpAlpI4tsqP3YdKgfyAERIi8RZXM5mJ5gCaiPYNmjarGakybDHJMsaEby7q"
var client_secret : String = "EDD65EAC71264DE69F3B86DDBD5EAB6F5FC893CD0B536707F35285AD032FA852"
var isProduction: Bool = false

#else
let timeIntervalApisBaseUrl: String = ""
let baseUrl = "https://fratelliwines.my.salesforce.com/"
let AppMode = "ProductionMode"
let apiUrl = "https://fratelliwines.my.salesforce.com/services/data/v59.0/"
let LoginBaseURL : String = "https://login.salesforce.com/services/oauth2/token"
let IsLogEnabled : Bool = false
var isoffTrade: Bool = false
var grant_type : String = "password"
var client_id : String = "3MVG9n_HvETGhr3BTujQr.IZRVdPZshAsIs43JTZPX.MzqQvfUjlbFt_dVof9TJnz3PcE8DzpApEQIUxbOEt7"
var client_secret : String = "42CF6FCB578F5E6DAC2D88A0482EC1EA959DC8C8D5253AEFFE490FE9AFA6D9D3"
var isProduction: Bool = true

#endif

#if arch(i386) || arch(x86_64)
let IsSimulator = true
#else
let IsSimulator = false
#endif


// MARK: Date Format Type
let twelveHoursTimeFormat = "hh:mm a"
let twentyFourHoursTimeFormat = "HH:mm:ss"
let dateFormatOneType = "yyyy-MM-dd"
let dateFormatTwoType = "MMMM yyyy"
let dateFormatThreeType = "dd/MM/yyyy"
var dateTimeFormat = "yyyy-MM-dd HH:mm:ss"

// TextFeild error color code
let colorForError: String = "#FF3B30"
let borderColorForError: String = "#FF3B30"
let textColor: String = "#722F37"
let buttonColor: String = "#722F37"


func getSideMenuWidth() -> CGFloat {
    if DeviceType.IS_IPHONE_5 {
        return 250.0
    } else {
        return 290.0
    }
}

func checkIsCRM() -> String {
    if isoffTrade {
        return offTrade
    } else {
        return onTrade
    }
}




