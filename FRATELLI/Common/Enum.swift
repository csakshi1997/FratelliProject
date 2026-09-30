//
//  Enum.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import Foundation
import UIKit

enum ResponseStatus: Int {
    case success
    case alreadyRegister
    case tokenExpired
    case error
    case badRequest
}

enum TaskStatus: String {
    case inProgress = "inProgress"
    case completed = "completed"
    case hold = "hold"
    case blocked = "blocked"
}

enum Permission: String {
    case view = "view"
    case comment = "comment"
    case edit = "edit"
    case full = "full"
    
    func getPermissionText() -> String{
        switch self {
        case .view:
            return "Can View"
        case .comment:
            return "Can Comment"
        case .edit:
            return "Can Edit"
        case .full:
            return "Full Access"
        }
    }
}

let customDateFormatter1 = CustomDateFormatter()
let todayDateString1 = customDateFormatter1.getTodayDateString()

enum SyncEnum: String, CaseIterable {
    case outlets = "outlets"
    case distributorAccount = "distributorAccounts"
    case visits = "visits"
    case contacts = "contacts"
    case products = "products"
    case recommendations = "recommendations"
    case promotion = "promotion"
    case posmRequest = "posmRequest"
    case assetRequest = "assetRequest"
    case actionItems = "actionItems"
    
    func getSyncText() -> String {
        switch self {
        case .outlets:
            return "SELECT Id,Name,Phone,Type,Zone__c,Area__c,Industry,Sales_Type__c,License__c,PAN_No__c, License_Code__c,Party_Code__c,Salesman_Code__c,Distributor_Party_Code__c,Distributor_Name__c,Party_Code_Old__c,Outlet_Type__c,Account_Status__c, BillingAddress,Channel__c,Checked_In_Location__Latitude__s,Checked_In_Location__Longitude__s,Classification__c,Sub_Channel__c,Sub_Channel_Type__c,Supplier_Group__c, Annual_Target_Data__c,Market_Share__c,Last_Visit_Date__c,Years__c,Year_LastYear__c,Growth__c,Supplier_Manufacturer_Unit__c,Distributor_Code__c,Email__c,Account_ID__c,ParentId,Parent_Account_ID__c,GST_No__c,Group__c,Status__c,Owner_ID__c,Owner_Manager__c, Asset_Visibility__c, Current_Market_Share__c FROM Account WHERE Owner_ID__c = '\(Defaults.userId ?? "")' OR Owner_Manager__c ='\(Defaults.userId ?? "")'"
        case .distributorAccount:
            //          return "SELECT Id, Name, Phone, Type, Zone__c, Area__c, Industry, Sales_Type__c, License__c, PAN_No__c, License_Code__c, Party_Code__c, Party_Code_Old__c, Outlet_Type__c, Account_Status__c, BillingAddress, Channel__c, Checked_In_Location__Latitude__s, Checked_In_Location__Longitude__s, Classification__c, Sub_Channel__c, Sub_Channel_Type__c, Supplier_Group__c, Supplier_Manufacturer_Unit__c, Distributor_Code__c, Distributor_Party_Code__c, Distributor_Name__c, Email__c, Account_ID__c, ParentId, Parent.name, Parent_Account_ID__c, GST_No__c, Group__c, Status__c, Annual_Target_Data__c, Market_Share__c, Last_Visit_Date__c, Years__c, Year_LastYear__c, Growth__c, Owner_ID__c FROM Account WHERE(Type = 'Bond' OR Type = 'Depot' OR Type = 'Distributor')"
            
//            return "SELECT Id, Name, Phone, Type, Zone__c, Area__c, Industry, Sales_Type__c, License__c, PAN_No__c, License_Code__c, Party_Code__c, Party_Code_Old__c, Outlet_Type__c, Account_Status__c, BillingAddress, Channel__c, Checked_In_Location__Latitude__s, Checked_In_Location__Longitude__s, Classification__c, Sub_Channel__c, Sub_Channel_Type__c, Supplier_Group__c, Supplier_Manufacturer_Unit__c, Distributor_Code__c, Distributor_Party_Code__c, Distributor_Name__c, Email__c, Account_ID__c, ParentId, Parent.Name, Parent_Account_ID__c, GST_No__c, Group__c, Status__c, Annual_Target_Data__c, Market_Share__c, Last_Visit_Date__c, Years__c, Year_LastYear__c, Growth__c, Owner_ID__c FROM Account WHERE Area__c = '\(Defaults.userArea ?? EMPTY)' AND Type IN ('Distributor', 'Depot', 'Bond', 'Corporation', 'Direct')"
            
            return "SELECT Id, Name, Phone, Type, Zone__c, Area__c, Industry, Sales_Type__c, License__c, PAN_No__c, License_Code__c, Party_Code__c, Party_Code_Old__c, Outlet_Type__c, Account_Status__c, BillingAddress, Channel__c, Checked_In_Location__Latitude__s, Checked_In_Location__Longitude__s, Classification__c, Sub_Channel__c, Sub_Channel_Type__c, Supplier_Group__c, Supplier_Manufacturer_Unit__c, Distributor_Code__c, Distributor_Party_Code__c, Distributor_Name__c, Email__c, Account_ID__c, ParentId, Parent.Name, Parent_Account_ID__c, GST_No__c, Group__c, Status__c, Annual_Target_Data__c, Market_Share__c, Last_Visit_Date__c, Years__c, Year_LastYear__c, Growth__c, Owner_ID__c FROM Account WHERE Area__c = '\(Defaults.userArea ?? EMPTY)' AND Type IN ('Distributor', 'Depot', 'Bond', 'Corporation', 'Direct')"
        case .visits:
            print("SELECT Id,Name,Actual_End__c,Actual_Start__c,Area__c,Beat_Route__c,EMP_Zone__c,Employee_Code__c,Old_Party_Code__c,Outlet_Creation__c,Outlet_Type__c,Owner_Area__c,Party_Code__c,Remarks__c,Checked_In__c,Checked_Out__c,Check_In_Location__c,Check_Out_Location__c,Checked_In_Location__Latitude__s,Checked_In_Location__Longitude__s,Checked_Out_Geolocation__Latitude__s,Checked_Out_Geolocation__Longitude__s,Account__c,Account__r.Name,Account__r.OwnerId,Account__r.Id,Account__r.Classification__c,Account__r.Sub_Channel__c,Channel__c,Status__c,Visit_plan_date__c,OwnerId FROM Visits__c WHERE Visit_plan_date__c = \(todayDateString1) and OwnerId = '\(Defaults.userId ?? "")'")
            return "SELECT Id,Name,Actual_End__c,Actual_Start__c,Area__c,Beat_Route__c,EMP_Zone__c,Employee_Code__c,Old_Party_Code__c,Outlet_Creation__c,Outlet_Type__c,Owner_Area__c,Party_Code__c,Remarks__c,Checked_In__c,Checked_Out__c,Check_In_Location__c,Check_Out_Location__c,Checked_In_Location__Latitude__s,Checked_In_Location__Longitude__s,Checked_Out_Geolocation__Latitude__s,Checked_Out_Geolocation__Longitude__s,Account__c,Account__r.Name,Account__r.OwnerId,Account__r.Id,Account__r.Classification__c,Account__r.Sub_Channel__c,Channel__c,Status__c,Visit_plan_date__c,OwnerId FROM Visits__c WHERE Visit_plan_date__c = \(todayDateString1) and OwnerId = '\(Defaults.userId ?? "")'"
        case .contacts:
            return "SELECT Id,Name,FirstName,MiddleName,LastName,Phone,Email,Aadhar_No__c,AccountId,Salutation,Title,Remark__c,OwnerId FROM Contact WHERE OwnerId = '\(Defaults.userId ?? "")'"
        case .products:
            return "SELECT Id,Name,Abbreviation__c,Bottle_CAN__c,Bottle_Size__c,Brand_Code__c,Category__c,Conversion_Ratio__c,CreatedDate,GST__c,IsDeleted,Item_Type__c,Priority__c,Product_Category__c,Product_Code__c,Product_Family__c,Product_ID__c,Product_Type__c,Size_Code__c,Size_In_ML__c,Type__c,OwnerId FROM Product__c"
        case .recommendations:
            return "Select Id, Name, Product_Name__c,Product_Name__r.name,OwnerId,Product_Description__c,Product_Name__r.Product_Image_Link__c,Product_Name__r.Id,Product_Name__r.Product_Description__c From Recommendations__c"
        case .promotion:
            return "Select Id, Name, Product_Name__c,Product_Name__r.name,OwnerId,Product_Description__c,Product_Name__r.Product_Image_Link__c,Product_Name__r.Id,Product_Name__r.Product_Description__c From Promotion__c"
        case .posmRequest:
            return "SELECT Value,Label,IsActive FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'Account' AND EntityParticle.QualifiedApiName = 'POSM_Requisition__c'"
        case .assetRequest:
            return "SELECT Value,Label,IsActive FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'Account' AND EntityParticle.QualifiedApiName = 'Asset_Requisition__c'"
        case .actionItems:
            return "SELECT Id,External_ID__c,WhatId,Subject,Status,Priority,Settlement_Data__c,Created_TimeStamp__c,OwnerId FROM Task"
        }
    }
}









