//
//  CreateVisitVC.swift
//  FRATELLI
//
//  Created by Sakshi on 03/01/25.
//


import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import DropDown

class CreateVisitVC: UIViewController {
    @IBOutlet var outletNameTxtFld: MDCOutlinedTextField?
    @IBOutlet var outletStack: UIStackView?
    @IBOutlet var submitBtn: UIButton?
    var isSideBar: Bool = false
    var fieldNames: [String] = []
    var outletsTable = OutletsTable()
    var outlet = [Outlet]()
    var outletData: Outlet?
    var outletPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var visitsTable = VisitsTable()
    var outletId = ""
    var outletName = ""
    var customDateFormatter = CustomDateFormatter()
    let dropdown = DropDown()
    var outletPickerItems = [OutletPickerItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        outlet = outletsTable.getOutlets()
        loadOutletNames()
        setupDropdown()
    }
    
    func loadOutletNames() {
        var seen = Set<String>()
        outletPickerItems = []

        for item in outlet {
            let name = item.name ?? ""
            let id = item.id ?? ""
            let key = "\(name)_\(id)" // Unique per outlet
            if !seen.contains(key) {
                seen.insert(key)
                outletPickerItems.append(OutletPickerItem(name: name, id: id))
            }
        }

        dropdown.dataSource = outletPickerItems.map { $0.name }
    }

    func setupUI() {
        submitBtn?.cornerRadius = 8
        submitBtn?.layer.masksToBounds = true
        outletNameTxtFld?.label.text = "Account Name"
        outletNameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        outletNameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletNameTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        outletNameTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletNameTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        outletNameTxtFld?.setRightPaddingPoints(15.0)
        outletNameTxtFld?.delegate = self
        addTapGestureToDismissKeyboard()
    }
    
    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func setupDropdown() {
        dropdown.anchorView = outletNameTxtFld
        dropdown.dataSource = outletPickerItems.map { $0.name }
        dropdown.direction = .bottom
        dropdown.dismissMode = .automatic
        dropdown.bottomOffset = CGPoint(x: 0, y: (outletNameTxtFld?.frame.height ?? 0.0) + 25.0)
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletNameTxtFld?.text = item
            let selectedItem = self.outletPickerItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }
    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to create Visit",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(VISIT_CREATED)
        }))
    }
    
    func validateFields() -> Bool {
        if outletNameTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please select Account name.")
            return false
        }
        if outletId == "" {
            showValidationAlert(message: "Please select visit from dropdown.")
            return false
        }
        let existingAccountIds = visitsTable.fetchAllAccountIds()
        if existingAccountIds.contains(outletId) {
            showValidationAlert(message: "This account already exists in today's visits.")
            return false
        }
        return true
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
        print("Account idd for create visist \(outletId)")
        outletData = outletsTable.getOutletData(forAccountId: outletId)
        let attributes = Visit.Attributes(type: "Visits__c", url: "")
        let account = Visit.Account(classification: outletData?.classification ?? "", id: "", name: outletData?.name ?? "", ownerId: "", subChannel: outletData?.subChannel ?? "")
        let visit = Visit(
            localId: nil,
            accountId: outletId,
            accountReference: account,
            actualEnd: "",
            actualStart: "",
            area: "",
            beatRoute: "",
            channel: outletData?.channel,
            checkInLocation: "",
            checkOutLocation: "",
            checkedInLocationLatitude: "",
            checkedInLocationLongitude: "",
            checkedIn: 0,
            checkedOutGeolocationLatitude: "",
            checkedOutGeolocationLongitude: "",
            checkedOut: 0,
            empZone: "",
            employeeCode: 0,
            id: "",
            name: outletData?.name ?? "",
            oldPartyCode: "",
            outletCreation: "",
            outletType: "",
            ownerId: Defaults.userId ?? "",
            ownerArea: "",
            partyCode: "",
            remarks: "",
            status: "",
            visitPlanDate: "",
            attributes: attributes,
            isSync: "0",
            isCompleted: "0",
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            isNew: 1,
            externalId: "",
            fromAppCompleted: "0",
            Contact_Person_Name__c: "",
            Contact_Phone_Number__c: ""
        )
        visitsTable.saveVisit(visit: visit) { success, error in
            if success {
                self.showAlert()
            } else {
                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateVisitVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == outletNameTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dropdown.show()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == outletNameTxtFld else { return true }
        outletId = ""
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        let filteredItems: [OutletPickerItem]
        if updatedText.isEmpty {
            filteredItems = outletPickerItems
        } else {
            filteredItems = outletPickerItems.filter { $0.name.lowercased().contains(updatedText.lowercased()) }
        }

        dropdown.dataSource = filteredItems.map { $0.name }
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletNameTxtFld?.text = item
            let selectedItem = filteredItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }

        dropdown.show()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == outletNameTxtFld {
            dropdown.hide()
        }
    }
}

struct OutletPickerItem {
    let name: String
    let id: String
}
