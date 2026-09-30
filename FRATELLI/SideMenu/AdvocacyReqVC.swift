import UIKit
import DropDown

class AdvocacyReqVC: UIViewController {
    @IBOutlet var outletNameTxtFld: UITextField?
    @IBOutlet var advocacyDateTxtFld: UITextField?
    @IBOutlet var brandProducttxtFld: UITextField?
    @IBOutlet var paxTxtFld: UITextField?
    @IBOutlet var outletStack: UIStackView?
    @IBOutlet var advocacyStack: UIStackView?
    @IBOutlet var brandStack: UIStackView?
    @IBOutlet var submitBtn: UIButton?
    var isSideBar: Bool = false
    var pickerView = UIPickerView()
    var datePicker = UIDatePicker()
    var fieldNames: [String] = []
    var currentPickerData: [String] = []
    var outletsTable = OutletsTable()
    var outlet = [Outlet]()
    var productsTable = ProductsTable()
    var product = [Product]()
    var outletPickerData = [String]()
    var productPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var productNamesToIDs: [String: String] = [:]
    var advocacyTable = AdvocacyTable()
    var advocacyRequest = AdvocacyRequest()
    var outletId = ""
    var outletName = ""
    var productId = ""
    var customDateFormatter = CustomDateFormatter()
    var outletPickerItems = [OutletPickerItem]()
    let outletDropdown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        outlet = outletsTable.getOutlets()
        loadOutletNames()
        setupDropdown()
        product = productsTable.getProducts()
        loadProductNames()
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
    

    func loadProductNames() {
        productPickerData = product.map { $0.name ?? EMPTY }
        productNamesToIDs = Dictionary(uniqueKeysWithValues: product.map { ($0.name ?? EMPTY, $0.id ?? EMPTY) })
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        addTapGestureToDismissKeyboard()
        submitBtn?.cornerRadius = 4
        submitBtn?.layer.masksToBounds = true
        outletNameTxtFld?.setLeftPaddingPoints(10)
        advocacyDateTxtFld?.setLeftPaddingPoints(10)
        brandProducttxtFld?.setLeftPaddingPoints(10)
        paxTxtFld?.setLeftPaddingPoints(10)
        outletNameTxtFld?.setRightPaddingPoints(10)
        advocacyDateTxtFld?.setRightPaddingPoints(10)
        advocacyDateTxtFld?.setRightPaddingPoints(10)
        paxTxtFld?.setRightPaddingPoints(10)
        advocacyDateTxtFld?.cornerRadius = 4
        advocacyDateTxtFld?.layer.masksToBounds = true
        paxTxtFld?.cornerRadius = 4
        paxTxtFld?.layer.masksToBounds = true
        brandStack?.cornerRadius = 4
        brandStack?.layer.masksToBounds = true
        advocacyStack?.cornerRadius = 4
        advocacyStack?.layer.masksToBounds = true
        outletStack?.cornerRadius = 4
        outletStack?.layer.masksToBounds = true
        advocacyStack?.borderWidth = 1.0
        advocacyStack?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        paxTxtFld?.borderWidth = 1.0
        paxTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        brandStack?.borderWidth = 1.0
        brandStack?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        outletStack?.borderWidth = 1.0
        outletStack?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)

        pickerView.delegate = self
        pickerView.dataSource = self
        brandProducttxtFld?.inputView = pickerView

        let toolbar = createToolbar()
        brandProducttxtFld?.inputAccessoryView = toolbar
        advocacyDateTxtFld?.inputAccessoryView = toolbar
        
        outletNameTxtFld?.delegate = self
        brandProducttxtFld?.delegate = self
    }
    
    func validateInputFields() -> Bool {
        if outletNameTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter outlet name.")
            return false
        }
        if advocacyDateTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please select advocacy date")
            return false
        }
        if brandProducttxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please select product name.")
            return false
        }
        if paxTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter pax.")
            return false
        }
        return true
    }
    
    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        toolbar.setItems([donebtn], animated: true)
        advocacyDateTxtFld?.inputAccessoryView = toolbar
        datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        advocacyDateTxtFld?.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func donepressed() {
        let dateformator = DateFormatter()
        dateformator.dateStyle = .medium
        dateformator.timeStyle = .none
        advocacyDateTxtFld?.text = dateformator.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func showAlert(){
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to save Advocacy request Form?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(ADVOCACYREQ_CREATED)
        }))
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func submitAction() {
        guard validateInputFields() else { return }
        advocacyRequest.localId = nil
        advocacyRequest.ExternalId = "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())"
        advocacyRequest.outerName = outletNameTxtFld?.text
        advocacyRequest.outerId = outletId
        advocacyRequest.advocacyDate = CustomDateFormatter.getCurrentDateTime()
        advocacyRequest.productId = productId
        advocacyRequest.productName = brandProducttxtFld?.text
        advocacyRequest.pax = paxTxtFld?.text
        advocacyRequest.OwnerId = Defaults.userId
        advocacyRequest.isSync = "0"
        advocacyRequest.createdAt = customDateFormatter.getFormattedDateForAccount()
        advocacyTable.saveAdvocacyDate(advocacyRequest: advocacyRequest ) { success, error in
            if success {
                self.showAlert()
            } else {
                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
            }
        }
    }
}

extension AdvocacyReqVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == brandProducttxtFld {
            currentPickerData = productPickerData
            pickerView.reloadAllComponents()
        } else if textField == advocacyDateTxtFld {
            self.createDatePicker()
        } else if textField == outletNameTxtFld {
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
        let selectedOutletName = currentPickerData[row]
        if (brandProducttxtFld?.isFirstResponder ?? false) {
            brandProducttxtFld?.text = selectedOutletName
            if let productID = productNamesToIDs[selectedOutletName] {
                self.productId = productID
                print("Selected Product ID: \(productID)")
            }
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
}

extension AdvocacyReqVC: UITextFieldDelegate {
    
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
