//
//  AddPOSMReqVC.swift
//  FRATELLI
//
//  Created by Sakshi on 18/11/24.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import DropDown

class AddPOSMReqVC: UIViewController {
    @IBOutlet var outletTxtFld: MDCOutlinedTextField?
    @IBOutlet var posmItemTxtFld: MDCOutlinedTextField?
    @IBOutlet var quantityTxtFld: MDCOutlinedTextField?
    @IBOutlet var submitBtn: UIButton?
    @IBOutlet var tableVw1: UITableView?
    var outletsTable = OutletsTable()
    var pOSMRequisitionTable = POSMRequisitionTable()
    var outlet = [Outlet]()
    var selectedOutlet: Outlet?
    var posmReqItems = [POSMReqItem]()
    var pOSMTable = POSMTable()
    var pOSMLineItemsTable = POSMLineItemsTable()
    var outletPickerData = [String]()
    var posmPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var posmNamesToIDs: [String: String] = [:]
    var outletId = ""
    var posmId = ""
    var customDateFormatter = CustomDateFormatter()
    var outletPickerItems = [OutletPickerItem]()
    let outletDropdown = DropDown()
    let posmDropdown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        outletTxtFld?.delegate = self
        posmItemTxtFld?.delegate = self
        quantityTxtFld?.label.text = "Quantity"
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        quantityTxtFld?.setNormalLabelColor(.gray, for: .normal)
        quantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        outlet = outletsTable.getOutlets()
        loadPosmNames()
        loadOutletNames()
        setupDropDowns()
    }
    
    
    
    @objc func showOutletDropdown() {
        outletDropdown.show()
    }

    @objc func showPOSMDropdown() {
        posmDropdown.show()
    }
    
    func loadOutletNames() {
        var seen = Set<String>()
        outletPickerItems = []
        for item in outlet {
            let name = item.name ?? ""
            let id = item.id ?? ""
            let key = "\(name)_\(id)"
            if !seen.contains(key) {
                seen.insert(key)
                outletPickerItems.append(OutletPickerItem(name: name, id: id))
            }
        }
        outletDropdown.dataSource = outletPickerItems.map { $0.name }
    }
    
    func loadPosmNames() {
        let posmItems = pOSMRequisitionTable.getPOSMRequisitions()
        posmDropdown
        posmPickerData = posmItems.map { $0.Value ?? "" }
        posmNamesToIDs = Dictionary(uniqueKeysWithValues: posmItems.compactMap {
            if let name = $0.Value, let id = $0.localId {
                return (name, id)
            }
            return nil
        })
    }
    
    func setInitialUI() {
        submitBtn?.cornerRadius = 8
        submitBtn?.layer.masksToBounds = true
        addTapGestureToDismissKeyboard()
        setupTextFields()
        setupTableView()
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTextFields() {
        setupTextField(outletTxtFld, label: "Outlet Name")
        setupTextField(posmItemTxtFld, label: "POSM Item Name")
    }
    
    func setupTextField(_ textField: MDCOutlinedTextField?, label: String) {
        textField?.label.text = label
        textField?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        textField?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        textField?.setNormalLabelColor(.gray, for: .normal)
        textField?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
       
    }
    
    
    func setupDropDowns() {
        // Outlet Dropdown
        outletDropdown.anchorView = outletTxtFld
        outletDropdown.dataSource = outletPickerItems.map { $0.name }
        outletDropdown.direction = .bottom
        outletDropdown.dismissMode = .automatic
        outletDropdown.bottomOffset = CGPoint(x: 0, y: (outletTxtFld?.frame.height ?? 0.0) + 25.0)
        outletDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletTxtFld?.text = item
            let selectedItem = self.outletPickerItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }

        // POSM Dropdown
        let posmItems = pOSMRequisitionTable.getPOSMRequisitions()
        posmPickerData = posmItems.map { $0.Value ?? "" }
        posmNamesToIDs = Dictionary(uniqueKeysWithValues: posmItems.compactMap { ($0.Value ?? "", $0.localId ?? "") })
        posmDropdown.anchorView = posmItemTxtFld
        posmDropdown.dataSource = posmPickerData
        posmDropdown.bottomOffset = CGPoint(x: 0, y: posmItemTxtFld?.frame.height ?? 0 + 10)
        posmDropdown.selectionAction = { [weak self] index, item in
            self?.posmItemTxtFld?.text = item
            self?.posmId = self?.posmNamesToIDs[item] ?? ""
        }
    }
    
    func setupTableView() {
        tableVw1?.delegate = self
        tableVw1?.dataSource = self
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        return toolbar
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPosmAction() {
        guard let selectedItemName = posmItemTxtFld?.text, !selectedItemName.isEmpty,
              let quantityText = quantityTxtFld?.text, let quantity = Int(quantityText), quantity > 0 else {
            print("Invalid POSM item or quantity")
            return
        }
        if let existingIndex = posmReqItems.firstIndex(where: { $0.label == selectedItemName }) {
            posmReqItems[existingIndex].quantity += quantity
        } else {
            posmReqItems.append(POSMReqItem(labelId: posmId, label: selectedItemName, quantity: quantity))
        }
        posmItemTxtFld?.text = ""
        quantityTxtFld?.text = ""
        tableVw1?.reloadData()
    }
    
    @IBAction func posmProceedAction() {
        sendPOSMReq()
    }
    
    func sendPOSMReq() {
        let pOSMModel = POSMModel(
            localId: nil,
            ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
            outerName: "",
            outerId: outletId,
            Visit__c: "",
            OwnerId: Defaults.userId,
            isSync: "0",
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            Visit_Date_c: "",
            Visit_Order_c: ""
        )
        pOSMTable.savePOSM(posm: pOSMModel) { success, error in
            if success {
                self.sendPOSMLineItems()
            } else if let error = error {
                print("Error saving POSM \(error)")
                SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save POSM. Please try again.")
            }
        }
    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to save POSM Request Form?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(POSMREQ_CREATED)
        }))
    }
    
    func sendPOSMLineItems() {
        guard !posmReqItems.isEmpty else { return }
        for posmItemsdata in posmReqItems {
            let pOSMLineItemsModel = POSMLineItemsModel(
                localId: nil,
                ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
                PosmItemId: posmItemsdata.labelId,
                POSM_Asset_name__c: posmItemsdata.label,
                Quantity__c: "\(posmItemsdata.quantity)",
                OwnerId: Defaults.userId,
                isSync: "0",
                createdAt: customDateFormatter.getFormattedDateForAccount()
            )
            pOSMLineItemsTable.savePOSMLineItem(posmLineItem: pOSMLineItemsModel) { success, error in
                if success {
                    self.showAlert()
                } else if let error = error {
                    print("Error saving POSM \(error)")
                    SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save POSM. Please try again.")
                }
            }
        }
    }
}

extension AddPOSMReqVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == outletTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.outletDropdown.show()
            }
        } else if textField == posmItemTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.posmDropdown.show()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == outletTxtFld else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        let filteredItems: [OutletPickerItem]
        if updatedText.isEmpty {
            filteredItems = outletPickerItems
        } else {
            filteredItems = outletPickerItems.filter { $0.name.lowercased().contains(updatedText.lowercased()) }
        }

        outletDropdown.dataSource = filteredItems.map { $0.name }
        outletDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.outletTxtFld?.text = item
            let selectedItem = filteredItems[index]
            self.outletId = selectedItem.id
            print("Selected Outlet ID: \(selectedItem.id)")
        }

        outletDropdown.show()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == outletTxtFld {
            outletDropdown.hide()
        }
    }
}

extension AddPOSMReqVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posmReqItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPOSMReqCell", for: indexPath) as! AddPOSMReqCell
        let item = posmReqItems[indexPath.row]
        cell.PosmTxtFld?.text = item.label
        cell.PosmQuantityLbl?.text = "\(item.quantity)"
        cell.posmIncreaseBtn?.tag = indexPath.row
        cell.posmDecreaseBtn?.tag = indexPath.row
        cell.posmIncreaseBtn?.addTarget(self, action: #selector(increasePOSMQuantity(_:)), for: .touchUpInside)
        cell.posmDecreaseBtn?.addTarget(self, action: #selector(decreasePOSMQuantity(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func increasePOSMQuantity(_ sender: UIButton) {
        let index = sender.tag
        posmReqItems[index].quantity += 1
        tableVw1?.reloadData()
    }
    
    @objc func decreasePOSMQuantity(_ sender: UIButton) {
        let index = sender.tag
        if posmReqItems[index].quantity > 1 {
            posmReqItems[index].quantity -= 1
            tableVw1?.reloadData()
        }
    }
}

class AddPOSMReqCell: UITableViewCell {
    @IBOutlet var posmIncreaseBtn: UIButton?
    @IBOutlet var posmDecreaseBtn: UIButton?
    @IBOutlet var PosmTxtFld: UITextField?
    @IBOutlet var PosmQuantityLbl: UILabel?
}

struct POSMReqItem {
    var labelId: String
    var label: String
    var quantity: Int
}

