//
//  NewOutletVC.swift
//  FRATELLI
//
//  Created by Sakshi on 05/11/24.
//

import UIKit

class NewOutletVC: UIViewController {
    @IBOutlet var licenseCodeTxtFld: UITextField?
    @IBOutlet var outletNameTxtFld: UITextField?
    @IBOutlet var DistributorTxtFld: UITextField?
    @IBOutlet var areaTxtFld: UITextField?
    @IBOutlet var cityTxtFld: UITextField?
    @IBOutlet var territoryTxtFld: UITextField?
    @IBOutlet var channelTxtFld: UITextField?
    @IBOutlet var classificationTxtFld: UITextField?
    @IBOutlet var subChannelTxtFld: UITextField?
    @IBOutlet var submitBtn: UIButton?
    var isSideBar: Bool = false
    var outletsTable = OutletsTable()
    var customDateFormatter = CustomDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        addTapGestureToDismissKeyboard()
        submitBtn?.cornerRadius = 4
        submitBtn?.layer.masksToBounds = true
        licenseCodeTxtFld?.setLeftPaddingPoints(20)
        outletNameTxtFld?.setLeftPaddingPoints(20)
        DistributorTxtFld?.setLeftPaddingPoints(20)
        areaTxtFld?.setLeftPaddingPoints(20)
        cityTxtFld?.setLeftPaddingPoints(20)
        territoryTxtFld?.setLeftPaddingPoints(20)
        channelTxtFld?.setLeftPaddingPoints(20)
        classificationTxtFld?.setLeftPaddingPoints(20)
        subChannelTxtFld?.setLeftPaddingPoints(20)
        licenseCodeTxtFld?.setRightPaddingPoints(20)
        outletNameTxtFld?.setRightPaddingPoints(20)
        DistributorTxtFld?.setRightPaddingPoints(20)
        areaTxtFld?.setRightPaddingPoints(20)
        cityTxtFld?.setRightPaddingPoints(20)
        territoryTxtFld?.setRightPaddingPoints(20)
        channelTxtFld?.setRightPaddingPoints(20)
        classificationTxtFld?.setRightPaddingPoints(20)
        subChannelTxtFld?.setRightPaddingPoints(20)
        licenseCodeTxtFld?.cornerRadius = 4
        licenseCodeTxtFld?.layer.masksToBounds = true
        outletNameTxtFld?.cornerRadius = 4
        outletNameTxtFld?.layer.masksToBounds = true
        DistributorTxtFld?.cornerRadius = 4
        DistributorTxtFld?.layer.masksToBounds = true
        areaTxtFld?.cornerRadius = 4
        areaTxtFld?.layer.masksToBounds = true
        cityTxtFld?.cornerRadius = 4
        cityTxtFld?.layer.masksToBounds = true
        territoryTxtFld?.cornerRadius = 4
        territoryTxtFld?.layer.masksToBounds = true
        channelTxtFld?.cornerRadius = 4
        channelTxtFld?.layer.masksToBounds = true
        classificationTxtFld?.cornerRadius = 4
        classificationTxtFld?.layer.masksToBounds = true
        subChannelTxtFld?.cornerRadius = 4
        subChannelTxtFld?.layer.masksToBounds = true
        licenseCodeTxtFld?.borderWidth = 1.0
        licenseCodeTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        outletNameTxtFld?.borderWidth = 1.0
        outletNameTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        DistributorTxtFld?.borderWidth = 1.0
        DistributorTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        areaTxtFld?.borderWidth = 1.0
        areaTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        cityTxtFld?.borderWidth = 1.0
        cityTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        territoryTxtFld?.borderWidth = 1.0
        territoryTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        channelTxtFld?.borderWidth = 1.0
        channelTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        classificationTxtFld?.borderWidth = 1.0
        classificationTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        subChannelTxtFld?.borderWidth = 1.0
        subChannelTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    func showAlert(){
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to save Account?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(NEWOUTLET_CREATED)
        }))
    }
    
    func validateFields() -> Bool {
        if licenseCodeTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter License Code.")
            return false
        }
        if outletNameTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Outlet Name.")
            return false
        }
        if DistributorTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Distributor Name.")
            return false
        }
        if areaTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Area.")
            return false
        }
        if cityTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter City.")
            return false
        }
        if territoryTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Territory.")
            return false
        }
        if channelTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Channel.")
            return false
        }
        if classificationTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Classification.")
            return false
        }
        if subChannelTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Sub Channel.")
            return false
        }
        return true
    }

    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAction() {
        if !validateFields() {
            return
        }
        let attributes = Outlet.Attributes(type: "Account", url: "")
        let newOutlet = Outlet(
            localId: nil,
            accountId: "",
            accountStatus: "",
            annualTargetData: "",
            area: areaTxtFld?.text,
            billingCity: "",
            billingCountry: "",
            billingCountryCode: "",
            billingState: "",
            billingStateCode: "",
            billingStreet: "",
            channel: channelTxtFld?.text,
            checkedInLocationLatitude: "",
            checkedInLocationLongitude: "",
            classification: classificationTxtFld?.text,
            distributorCode: "",
            distributorName: DistributorTxtFld?.text,
            distributorPartyCode: "",
            email: "",
            gstNo: "",
            groupName: "",
            growth: "",
            id: "",
            industry: "",
            lastVisitDate: "",
            licenseCode: licenseCodeTxtFld?.text,
            license: "",
            marketShare: "",
            name: outletNameTxtFld?.text,
            outletType: "",
            ownerId: Defaults.userId, 
            ownerManager: "",
            panNo: "",
            partyCodeOld: "",
            partyCode: "",
            phone: "",
            salesType: "",
            salesmanCode: "",
            status: 0,
            subChannelType: "",
            subChannel: subChannelTxtFld?.text,
            supplierGroup: "",
            supplierManufacturerUnit: "",
            type: "Retail Outlet",
            yearLastYear: "",
            years: "",
            zone: "",
            parentId: "",
            attributes: attributes,
            isSync: "0",
            checkIn: 0,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            Asset_Visibility__c: "",
            Current_Market_Share__c: ""
        )
        outletsTable.saveOutlet(outlet: newOutlet) { success, error in
            if success {
                self.showAlert()
            } else {
                print("Failed to create new outlet: \(error ?? "Unknown error")")
                SceneDelegate.getSceneDelegate().window?.makeToast("Failed to create new outlet.")
            }
        }
    }
}
