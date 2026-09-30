//
//  OutletSalesOrderVC.swift
//  FRATELLI
//
//  Created by Sakshi on 05/12/24.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class OutletSalesOrderVC: UIViewController {
    @IBOutlet var distributorTxtFld: MDCOutlinedTextField?
    @IBOutlet var productTxtFld: MDCOutlinedTextField?
    @IBOutlet var schemeTxtFld: MDCOutlinedTextField?
    @IBOutlet var quantityTxtFld: MDCOutlinedTextField?
    @IBOutlet var dateTxtFld: MDCOutlinedTextField?
    @IBOutlet var freeIssueQuantityTxtFld: MDCOutlinedTextField?
    @IBOutlet var remarkTxtView: UITextView?
    @IBOutlet var outletLbl: UILabel?
    @IBOutlet var addBtn: UIButton?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var schemeTypeStack: UIStackView?
    @IBOutlet var schemePercentageStack: UIStackView?
    @IBOutlet var addItemeStack: UIStackView?
    @IBOutlet var vWHeight: NSLayoutConstraint?
    @IBOutlet var proceedBtn: UIButton?
    @IBOutlet var vw: UIView?
    @IBOutlet var headerVw: UIView?
    @IBOutlet var textView: UITextView?
    @IBOutlet var descriptionTxtView: UITextView?
    @IBOutlet var countLbl: UILabel?
    var pickerView = UIPickerView()
    var outletsTable = OutletsTable()
    var distributorAccountsTable = DistributorAccountsTable()
    var productsTable = ProductsTable()
    var product = [Product]()
    var outlet: Outlet?
    var distributorAccountsModel: DistributorAccountsModel?
    var distributorAccountsModelArr = [DistributorAccountsModel]()
    var outletPickerData = [String]()
    var productPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var productNamesToIDs: [String: String] = [:]
    var currentPickerData: [String] = []
    var outletId = ""
    var distributorId = ""
    var productId = ""
    var accountId = ""
    var tableData: SalesOrderModel?
    var tableDataLineItems: [SalesOrderLineItems] = []
    var salesOrderTable = SalesOrderTable()
    var salesOrderLineItemsTable = SalesOrderLineItemsTable()
    var customDateFormatter = CustomDateFormatter()
    var percentage =  ""
    var quanityInBottles =  ""
    var amount =  ""
    var isQuality: Bool = false
    var zeroScheme: Bool = false
    var ispercentage: Bool = false
    var isAmount: Bool = false
    var dropdownManager = DropdownManager()
    var destributorDropdownManager = DropdownManager()
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    let datePicker = UIDatePicker()
    var createdTime: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        distributorAccountsModelArr = distributorAccountsTable.getDistributorOutlets()
        outlet = outletsTable.getOutletData(forAccountId: currentVisitId)
        
        outletLbl?.text = outlet?.name
        product = productsTable.getProducts()
        loadProductNames()
        if outlet?.distributorName?.isEmpty ?? true {
            distributorTxtFld?.isUserInteractionEnabled = true
            configureDropdownForDistributor()
        } else {
            distributorTxtFld?.text = outlet?.distributorName
            distributorId = outlet?.parentId ?? ""
            distributorTxtFld?.isUserInteractionEnabled = false
        }
        configureDropdownForProduct()
        addTapGestureToDismissKeyboard()
    }

    
    func configureDropdownForProduct() {
        dropdownManager.setupDropdown(for: productTxtFld!, with: productNamesToIDs) { [weak self] (name, id) in
            self?.productTxtFld?.text = name
            self?.productId = id
            print("Selected product ID: \(id)")
        }
    }

    
    func configureDropdownForDistributor() {
        if !distributorAccountsModelArr.isEmpty {
            let uniqueDistributors = getUniqueDistributors(from: distributorAccountsModelArr)
            if uniqueDistributors.isEmpty { return }
            let distributorData = Dictionary(uniqueKeysWithValues: uniqueDistributors)
            guard let distributorTxtFld = distributorTxtFld else {
                print("Error: distributorTxtFld is nil")
                return
            }
            destributorDropdownManager.setupDropdown(for: distributorTxtFld, with: distributorData) { [weak self] (name, accountId) in
                print("Dropdown selected: \(name), \(accountId)")
                self?.distributorTxtFld?.text = name
                self?.distributorId = accountId
                print("Selected distributor  (ID): \(self?.distributorId ?? "")")
            }
        }
    }
    
    func getUniqueDistributors(from outlets: [DistributorAccountsModel]) -> [(name: String, distributorPartyCode: String)] {
        let distributors = outlets.compactMap { (outlet) -> (String, String)? in
            guard let distributorName = outlet.name, !distributorName.isEmpty,
                  let distributorId = outlet.accountId, !distributorId.isEmpty else {
                print("Skipping distributor: \(outlet)")  // Debugging
                return nil
            }
            return (distributorName, distributorId)
        }
        let uniqueDistributorsNames = Set(distributors.map { $0.0 })
        let uniqueDistributorsWithPartyCodes = uniqueDistributorsNames.compactMap { name -> (String, String)? in
            if let outlet = outlets.first(where: { $0.name == name }) {
                print("Found outdistributorlet for distributor \(name): \(outlet)")  // Debugging
                return (name, outlet.accountId) as? (String, String)
            }
            return nil
        }
        return uniqueDistributorsWithPartyCodes
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == productTxtFld {
            if textField.text?.isEmpty ?? true {
                dropdownManager.filterDropdown(with: "")
            }
            dropdownManager.showDropdown()
        } else if textField == distributorTxtFld {
            if textField.text?.isEmpty ?? true {
                destributorDropdownManager.filterDropdown(with: "")
            }
            destributorDropdownManager.showDropdown()
            return false
        } else if textField == schemeTxtFld {
            textField.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
                let vc = storyBoard.instantiateViewController(identifier: "SchemeTypeView") as! SchemeTypeView
                vc.modalPresentationStyle = .overFullScreen
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                
                vc.completionHandler = { concernText in
                    self.schemeTxtFld?.text = concernText
                    self.updateSchemeFields()
                }
                
                self.present(vc, animated: true, completion: nil)
            }
            return false // Prevents keyboard from showing
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productTxtFld, let query = textField.text {
            dropdownManager.filterDropdown(with: query)
            dropdownManager.showDropdown()
        } else if textField == distributorTxtFld, let query = textField.text {
            destributorDropdownManager.filterDropdown(with: query)
            destributorDropdownManager.showDropdown()
        }
    }
    
    func loadProductNames() {
        productPickerData = product.map { $0.name ?? EMPTY }
        productNamesToIDs = Dictionary(uniqueKeysWithValues: product.map { ($0.name ?? EMPTY, $0.id ?? EMPTY) })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
    }
    
    func quantityIncsDecs(isIncrement: Bool, quantity: Int) {
        var quantityInc = quantity
        if isIncrement {
            quantityInc += 1
        } else {
            quantityInc = max(0, quantityInc - 1)
        }
        quantityTxtFld?.text = "\(quantityInc)"
    }
    
    func setInitialUI() {
        remarkTxtView?.dropShadow()
        remarkTxtView?.placeholder = "Enter Remark"
        remarkTxtView?.textColor = .darkGray
        remarkTxtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        descriptionTxtView?.dropShadow()
        descriptionTxtView?.placeholder = "Enter Remark"
        descriptionTxtView?.textColor = .darkGray
        descriptionTxtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        vw?.layer.cornerRadius = 8
        vw?.layer.masksToBounds = true
        distributorTxtFld?.label.text = "Distributor Name"
        distributorTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        distributorTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        distributorTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        distributorTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        distributorTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        productTxtFld?.label.text = "Product Name"
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        productTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        schemeTxtFld?.label.text = "Scheme Type"
        schemeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        schemeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemeTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        schemeTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        schemeTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        quantityTxtFld?.label.text = "Quantity (In Bottles)"
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        quantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        quantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        quantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        quantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        dateTxtFld?.label.text = "Select Date"
        dateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        dateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        dateTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        dateTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        dateTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        self.schemePercentageStack?.isHidden = true
        vWHeight?.constant = 410
        headerVw?.isHidden = true
        distributorTxtFld?.setRightPaddingPoints(30)
        productTxtFld?.setRightPaddingPoints(30)
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let today = Calendar.current.startOfDay(for: Date())
        let sixDaysAgo = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -6, to: today)!
        )

        datePicker.maximumDate = today
        datePicker.minimumDate = sixDaysAgo
        dateTxtFld?.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        dateTxtFld?.inputAccessoryView = toolbar
        productTxtFld?.delegate = self
        dateTxtFld?.delegate = self
    }
    
    @objc func dateChanged() {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTxtFld?.text = formatter.string(from: selectedDate)
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Invalid Date",
            message: "Please select a date from today or the previous 6 days.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    @objc func donePressed() {

        let calendar = Calendar.current

        let selectedDate = calendar.startOfDay(for: datePicker.date)
        let today = calendar.startOfDay(for: Date())
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!

        guard selectedDate >= sixDaysAgo && selectedDate <= today else {
            showAlert()
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTxtFld?.text = formatter.string(from: selectedDate)

        dateTxtFld?.resignFirstResponder()
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @IBAction func skipForNowAction() {
        skipTable.updateSalesOrderVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, salesOrderVisibility: "1") { success, error in
            if success {
                print("salesOrde skip updated successfully!")
            } else {
                print("Failed to update salesOrder skip: \(error ?? "Unknown error")")
            }
        }
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "Home", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "VisibilityVC") as! VisibilityVC
        dashboardVC.accountId = accountId
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    @IBAction func submitAction() {
        skipTable.updateSalesOrderVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, salesOrderVisibility: "0") { success, error in
            if success {
                print("salesOrde skip updated successfully!")
            } else {
                print("Failed to update salesOrder skip: \(error ?? "Unknown error")")
            }
        }
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to submit Sales Order?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if !self.tableDataLineItems.isEmpty {
                let storyboardBundle = Bundle.main
                let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
                let dashboardVC = storyboard.instantiateViewController(withIdentifier: "PreviewOrderVw") as! PreviewOrderVw
                dashboardVC.salesModel = self.tableData
                dashboardVC.salesModelLineItems = self.tableDataLineItems
                dashboardVC.accountId = self.accountId
                self.navigationController?.pushViewController(dashboardVC, animated: true)
            } else {
                let checkOutalert = UIAlertController(
                    title: "Alert",
                    message: "Please order atleast one Product",
                    preferredStyle: .alert
                )
                self.present(checkOutalert, animated: true, completion: nil)
                checkOutalert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                }))
            }
        }))
    }
    
    private func clearTextFields() {
        productTxtFld?.text = ""
        schemeTxtFld?.text = ""
        quantityTxtFld?.text = ""
        freeIssueQuantityTxtFld?.text = ""
//        distributorTxtFld?.text = ""
        dateTxtFld?.text = ""
        self.schemePercentageStack?.isHidden = true
    }
    
    func gotoSchemeType() {
        self.view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle:nil)
        let vc = (storyBoard.instantiateViewController(identifier: "SchemeTypeView")) as! SchemeTypeView
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3966007864)
        vc.completionHandler = { concernText in
            self.schemeTxtFld?.text = concernText
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func incDecrement(_ sender: UIButton) {
        self.view.endEditing(true)
        let quantityText = quantityTxtFld?.text ?? ""
        let quantityInt = Int(quantityText)
        _ = Int(quantityTxtFld?.text ?? "0") ?? 0
        if sender.tag == 1 {
            quantityIncsDecs(isIncrement: true, quantity: quantityInt ?? 0)
        } else {
            quantityIncsDecs(isIncrement: false, quantity: quantityInt ?? 0)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction() {
        if (!(freeIssueQuantityTxtFld?.text?.isEmpty ?? true) && (isQuality == true)) {
            guard let quantityText = quantityTxtFld?.text,
                  let freeIssueText = freeIssueQuantityTxtFld?.text,
                  let quantity = Int(quantityText),
                  let freeIssueQuantity = Int(freeIssueText) else {
                return
            }
            if freeIssueQuantity > quantity {
                let alert = UIAlertController(title: "Validation Error",
                                              message: "Free Issue Quantity cannot be greater than product quantity.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.freeIssueQuantityTxtFld?.text = nil
                })
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let distributor = distributorTxtFld?.text, distributor.isEmpty {
            showAlert(title: "Error", message: "Please add Distributor.")
            return
        }
        
        if let product = productTxtFld?.text, product.isEmpty {
            showAlert(title: "Error", message: "Product not found.")
            return
        }
        
        if let quantity = quantityTxtFld?.text, quantity.isEmpty {
            showAlert(title: "Error", message: "Please fill Product Quantity.")
            return
        }
        
        if let quantity = quantityTxtFld?.text, quantity == "0" {
            showAlert(title: "Error", message: "Quantity Should be greater than zero")
            return
        }
        
        if let scheme = schemeTxtFld?.text, scheme.isEmpty {
            showAlert(title: "Error", message: "Please fill Scheme Type.")
            return
        }
        
        if !zeroScheme {
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, ispercentage {
                showAlert(title: "Error", message: "Please fill Scheme Percentage.")
                return
            }
            
            if let schemePercentage = freeIssueQuantityTxtFld?.text, let percentageValue = Double(schemePercentage), ispercentage {
                if percentageValue > 50 {
                    showAlert(title: "Error", message: "Percentage should be less than or equal to 50%")
                    return
                }
            }
            
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, isQuality {
                showAlert(title: "Error", message: "Please fill Free Issue Qty (In Btls).")
                return
            }
            
            if let quantity = freeIssueQuantityTxtFld?.text, quantity == "0", isQuality {
                showAlert(title: "Error", message: "Scheme Quantity Should be greater than zero")
                return
            }
            
            if let schemePercentage = freeIssueQuantityTxtFld?.text, schemePercentage.isEmpty, isAmount {
                showAlert(title: "Error", message: "Please fill Total Amount.")
                return
            }
        }
        switch self.schemeTxtFld?.text {
        case "Scheme with VAT/ED":
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Scheme without VAT/ED":
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Scheme on MRP":
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Free Issue with VAT/ED":
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Free Issue without VAT/ED":
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Flat Amount Scheme":
            self.amount = self.freeIssueQuantityTxtFld?.text ?? ""
        case "Zero Scheme":
            self.schemePercentageStack?.isHidden = true
        default:
            return
        }
        if tableDataLineItems.contains(where: { $0.Product__ID == productId }) {

            showAlert(
                title: "Duplicate Product",
                message: "This product has already been added. Please select another product."
            )
            return
        }
        prepareSalesModelData()
    }
    
    func prepareSalesModelData() {
        self.view.endEditing(true)
//        createdTime = "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())"
        tableData = SalesOrderModel(
            localId: nil,
            External_Id__c: externalID,
            Bulk_Upload__c: true,
            Distributor__Id: !distributorId.isEmpty ? distributorId : "",
            DistributorName: distributorTxtFld?.text,
            Customer__Id: outlet?.accountId,
            customerName: outlet?.name,
            Employee_Code__c: outlet?.salesmanCode,
            Order_Booking_Data__c: CustomDateFormatter.getCurrentDateTime(),
            Distributor_Party_Code__c: outlet?.distributorPartyCode,
            Customer_Party_Code__c: outlet?.partyCode,
            Status__c: "Submitted",
            dateTime: dateTxtFld?.text,
            ownerId: Defaults.userId,
            addRemark: remarkTxtView?.text,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            isSync: "0",
            Visit_Date_c: visitPlanDate,
            Visit_Order_c: currentSelectedVisitId
        )
        print(tableData)
        prepareSalesModelLineItemsData()
    }
    
    func prepareSalesModelLineItemsData () {
        view.endEditing(true)
        let newDataLineItems = SalesOrderLineItems(
            localId: nil,
            External_Id__c: externalID,
            Product__ID: productId,
            Product_Name: productTxtFld?.text,
            Scheme_Type__c: schemeTxtFld?.text,
            Total_Amount_INR__c: amount,
            Free_Issue_Quantity_In_Btls__c: quanityInBottles,
            Scheme_Percentage__c: percentage,
            Product_quantity_c: quantityTxtFld?.text,
            dateTime: customDateFormatter.getFormattedDateForAccount(),
            ownerId: Defaults.userId,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            isSync: "0",
            addRemark: descriptionTxtView?.text
        )
        print(newDataLineItems)
        tableDataLineItems.append(newDataLineItems)
        if tableDataLineItems.count > 0 {
            tableView?.reloadData()
            headerVw?.isHidden = false
        }
        clearTextFields()
    }
}

extension OutletSalesOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataLineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OutletSalesOrderCell = tableView.dequeueReusableCell(withIdentifier: "OutletSalesOrderCell", for: indexPath) as! OutletSalesOrderCell
        let backgroundImage = UIImage(named: "bg")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundView = backgroundImageView
        let data = tableDataLineItems[indexPath.row]
        cell.nameLbl?.text = data.Product_Name
        cell.quantityLbl?.text = data.Product_quantity_c
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class OutletSalesOrderCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var quantityLbl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
    }
}

extension OutletSalesOrderVC: UITextFieldDelegate {
    
    @objc func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTxtView {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = size.height
                }
            }
            let currentCount = descriptionTxtView?.text.count
            countLbl?.text = "\(currentCount ?? 0)"
            if textView.text.isEmpty {
                textView.setPlaceholder("Description")
            } else {
                textView.removePlaceholder()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = descriptionTxtView?.text ?? ""
        let updatedTextLength = currentText.count - range.length + text.count
        return updatedTextLength <= 255
    }
        
    func updateSchemeFields() {
        switch self.schemeTxtFld?.text {
        case "Scheme with VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Scheme without VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Scheme on MRP":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Scheme (%)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.percentage = self.freeIssueQuantityTxtFld?.text ?? ""
            self.quanityInBottles = ""
            self.amount = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = true
            self.isAmount = false
        case "Free Issue with VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.amount = ""
            self.isQuality = true
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = false
        case "Free Issue without VAT/ED":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Free Issue Quantity(In btls.)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.quanityInBottles = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.amount = ""
            self.isQuality = true
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = false
        case "Flat Amount Scheme":
            self.schemePercentageStack?.isHidden = false
            self.vWHeight?.constant = 460
            self.freeIssueQuantityTxtFld?.label.text = "Total Amount (INR)"
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            self.freeIssueQuantityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
            self.freeIssueQuantityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
            self.freeIssueQuantityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
            self.amount = self.freeIssueQuantityTxtFld?.text ?? ""
            self.percentage = ""
            self.quanityInBottles = ""
            self.isQuality = false
            self.zeroScheme = false
            self.ispercentage = false
            self.isAmount = true
        case "Zero Scheme":
            self.schemePercentageStack?.isHidden = true
            self.isQuality = false
            self.zeroScheme = true
            self.ispercentage = false
            self.isAmount = false
        default:
            return
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField == schemeTxtFld  {
            schemePercentageStack?.isHidden = false
            vWHeight?.constant = 460
        }
    }
}
