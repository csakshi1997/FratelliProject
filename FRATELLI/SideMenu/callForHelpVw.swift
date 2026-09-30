//
//  callForHelpVw.swift
//  FRATELLI
//
//  Created by Sakshi on 18/11/24.
//

import UIKit
import DropDown

class callForHelpVw: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var textView: UITextView?
    @IBOutlet var outletNameTxtFld: UITextField?
    @IBOutlet var submitBtn: UIButton?
    var callForHelpTable = CallForHelpTable()
    var callForHelpModel = CallForHelpModel()
    var outletsTable = OutletsTable()
    var selectedOutletData: Outlet?
    var outlet = [Outlet]()
    var outletPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var currentPickerData: [String] = []
    var outletId = ""
    var customDateFormatter = CustomDateFormatter()
    var pickerView = UIPickerView()
    var outletPickerItems = [OutletPickerItem]()
    let outletDropdown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        outlet = outletsTable.getOutlets()
        loadOutletNames()
        setupDropdown()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func setUI() {
        submitBtn?.cornerRadius = 4
        submitBtn?.layer.masksToBounds = true
        textView?.setLeftPaddingPointsTextView(20)
        outletNameTxtFld?.setLeftPaddingPoints(20)
        outletNameTxtFld?.setRightPaddingPoints(20)
        textView?.setRightPaddingPointsTextView(20)
        outletNameTxtFld?.cornerRadius = 4
        outletNameTxtFld?.layer.masksToBounds = true
        outletNameTxtFld?.borderWidth = 1.0
        outletNameTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        textView?.cornerRadius = 4
        textView?.layer.masksToBounds = true
        textView?.borderWidth = 1.0
        textView?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        addTapGestureToDismissKeyboard()
        let toolbar = createToolbar()
    }
    
    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateInputFields() -> Bool {
        if textView?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter description.")
            return false
        }
        if outletNameTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter outlet name.")
            return false
        }
        return true
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
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

        outletDropdown.dataSource = outletPickerItems.map { $0.name }
    }
    
    func setupDropdown() {
        outletDropdown.anchorView = outletNameTxtFld
        outletDropdown.dataSource = outletPickerItems.map { $0.name }
        outletDropdown.direction = .bottom
        outletDropdown.dismissMode = .automatic
        outletDropdown.bottomOffset = CGPoint(x: 0, y: (outletNameTxtFld?.frame.height ?? 0.0) + 25.0)
        outletDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletNameTxtFld?.text = item
            let selectedItem = self.outletPickerItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }
    }
    
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func clearFields() {
        outletNameTxtFld?.text = ""
        textView?.text = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == outletNameTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.outletDropdown.show()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        outletNameTxtFld?.text = currentPickerData[row]
        if let outletID = outletNamesToIDs[currentPickerData[row]] {
            self.outletId = outletID
            print("Selected Outlet ID: \(outletID)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = currentPickerData[row]
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
    
    func showAlert(){
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to save Help form?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(CALLFORHELP_CREATED)
            self.clearFields()
        }))
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveInDBAction() {
        guard validateInputFields() else { return }
        callForHelpModel = CallForHelpModel(
            localId: nil,
            External_Id__C: "\(self.outletId)\(CustomDateFormatter.getCurrentDateTime())",
            OutletId: outletId,
            TaskSubject: "Call For Help",
            TaskSubtype: textView?.text,
            CreatedDate: CustomDateFormatter.getCurrentDateTime(),
            CreatedTime: CustomDateFormatter.getCurrentDateTime(),
            IsTaskRequired: "1",
            TaskStatus: "0",
            OwnerId: Defaults.userId,
            isSync: "1",
            createdAt: customDateFormatter.getFormattedDateForAccount()
        )
        callForHelpTable.saveCallForHelp(model: callForHelpModel) { success, error in
            if success {
                self.showAlert()
            } else {
                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
            }
        }
    }
}

extension callForHelpVw: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == outletNameTxtFld else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        // Filter outletPickerItems instead of outletPickerData
        let filteredItems: [OutletPickerItem]
        if updatedText.isEmpty {
            filteredItems = outletPickerItems
        } else {
            filteredItems = outletPickerItems.filter { $0.name.lowercased().contains(updatedText.lowercased()) }
        }

        outletDropdown.dataSource = filteredItems.map { $0.name }
        outletDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletNameTxtFld?.text = item
            let selectedItem = filteredItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }

        outletDropdown.show()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == outletNameTxtFld {
            outletDropdown.hide()
        }
    }
}

