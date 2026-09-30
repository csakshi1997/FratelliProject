//
//  ReviewScreenVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import AVFoundation
import Photos
import CryptoKit
import DropDown

class ReviewScreenVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var locationDetailTxtFld: MDCOutlinedTextField?
    @IBOutlet var regionalSalesTxtFld: MDCOutlinedTextField?
    @IBOutlet var containerTypeTxtFld: MDCOutlinedTextField?
    @IBOutlet var StockDetailTxtFld: MDCOutlinedTextField?
    @IBOutlet var BottlesCanesTxtFld: MDCOutlinedTextField?
    @IBOutlet var concernTxtFld: MDCOutlinedTextField?
    @IBOutlet var outletNameTxtFld: MDCOutlinedTextField?
    @IBOutlet var brandDetailTxtFld: MDCOutlinedTextField?
    @IBOutlet var BatchDetailTxtFld: MDCOutlinedTextField?
    @IBOutlet var manufactureDateTxtFld: MDCOutlinedTextField?
    @IBOutlet var closingStockReviewTxtFld: MDCOutlinedTextField?
    @IBOutlet var DefectedQuanityTxtFld: MDCOutlinedTextField?
    @IBOutlet var DebitNotesTxtFld: MDCOutlinedTextField?
    @IBOutlet var RemarkTxtFld: MDCOutlinedTextField?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var cameraButton: UIButton?
    @IBOutlet var dateTxtFld: UITextField?
    @IBOutlet var doneBtn: UIButton?
    @IBOutlet var canBtn: UIButton?
    @IBOutlet var bottleBtn: UIButton?
    @IBOutlet var containerTypeView: UIView?
    @IBOutlet var stockTypeView: UIView?
    var isCan: Bool = false
    var isFresh: Bool = false
    var datePicker = UIDatePicker()
    var currentPickerData: [String] = []
    var pickerView = UIPickerView()
    var outletsTable = OutletsTable()
    var outlet = [Outlet]()
    var selectedOutletData: Outlet?
    var outletPickerData = [String]()
    var outletNamesToIDs: [String: String] = [:]
    var outletId = ""
    var rQCRTable = RQCRTable()
    var customDateFormatter = CustomDateFormatter()
    var AccountOwnerId: String = ""
    var AccountmanagerId: String = ""
    var qCROperation = QCROperation()
    var selectedImageHexCode: String?
    var selectedImageTitle: String?
    var base64ImageString: String?
    var imageHexCode: String?
    var outletPickerItems = [OutletPickerItem]()
    let outletDropdown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        outlet = outletsTable.getOutlets()
        loadOutletNames()
        setupDropdown()
        addTapGestureToDismissKeyboard()
        pickerView.delegate = self
        pickerView.dataSource = self
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
    
    
    func clearFields() {
        outletNameTxtFld?.text = ""
        locationDetailTxtFld?.text = ""
        regionalSalesTxtFld?.text = ""
        containerTypeTxtFld?.text = ""
        StockDetailTxtFld?.text = ""
        BottlesCanesTxtFld?.text = ""
        concernTxtFld?.text = ""
        brandDetailTxtFld?.text = ""
        BatchDetailTxtFld?.text = ""
        manufactureDateTxtFld?.text = ""
        closingStockReviewTxtFld?.text = ""
        DefectedQuanityTxtFld?.text = ""
        DebitNotesTxtFld?.text = ""
        RemarkTxtFld?.text = ""
        imageView?.image = nil
    }
    
    func validateInputFields() -> Bool {
        if locationDetailTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Location Detail.")
            return false
        }
        if regionalSalesTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Regional Sales.")
            return false
        }
        if containerTypeTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Container Type.")
            return false
        }
        if StockDetailTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Stock Detail.")
            return false
        }
        if BottlesCanesTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Bottles or Canes.")
            return false
        }
        if concernTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Concern.")
            return false
        }
        if outletNameTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Outlet Name.")
            return false
        }
        if brandDetailTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Brand Detail.")
            return false
        }
        if BatchDetailTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Batch Detail.")
            return false
        }
        if manufactureDateTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Manufacture Date.")
            return false
        }
        if closingStockReviewTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Closing Stock Review.")
            return false
        }
        if DefectedQuanityTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Defected Quantity.")
            return false
        }
        if DebitNotesTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Debit Notes.")
            return false
        }
        if RemarkTxtFld?.text?.isEmpty ?? true {
            showValidationAlert(message: "Please enter Remark.")
            return false
        }
        return true
    }
    
    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to save Quality Control Form?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        
        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(QUALITYCOMPLAINT_CREATED)
            self.clearFields()
        }))
    }
        
    func saveData() {
        uploadImageToServer()
//        guard validateInputFields() else { return }
//        let rQCRModel = RQCRModel(
//            localId: nil,
//            externalId: "\(self.outletId)\(CustomDateFormatter.getCurrentDateTime())",
//            outletId: self.outletId,
//            outletName: outletNameTxtFld?.text ?? "",
//            batchNo: BatchDetailTxtFld?.text ?? "",
//            brandName: brandDetailTxtFld?.text ?? "",
//            canBottle: containerTypeTxtFld?.text ?? "",
//            complaint: concernTxtFld?.text ?? "",
//            concernDetails: concernTxtFld?.text ?? "",
//            createdById: Defaults.userId ?? "",
//            createdDate: customDateFormatter.getFormattedDateForAccount(),
//            dateOfGrievances: dateTxtFld?.text ?? "",
//            debitNoteCost: DebitNotesTxtFld?.text ?? "",
//            defectedQuantity: Int(DefectedQuanityTxtFld?.text ?? "0") ?? 0,
//            locationDetails: locationDetailTxtFld?.text ?? "",
//            manufacturingDate: manufactureDateTxtFld?.text ?? "",
//            particularBrandClosingStockReceived: closingStockReviewTxtFld?.text ?? "",
//            remark: RemarkTxtFld?.text ?? "",
//            stockDetails: StockDetailTxtFld?.text ?? "",
//            regionalSalesPerson: AccountOwnerId,
//            territorySalesPersonInCharge: AccountmanagerId,
//            ownerId: Defaults.userId ?? "",
//            createdAt: customDateFormatter.getFormattedDateForAccount(),
//            isSync: "0"
//        )
//        rQCRTable.saveRQCR(rqcr: rQCRModel) { success, error in
//            if success {
//                self.showAlert()
//            } else {
//                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
//            }
//        }
    }
    
    func setInitialUI() {
        outletNameTxtFld?.label.text = "Outlet Name"
        outletNameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        outletNameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletNameTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        outletNameTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        outletNameTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        locationDetailTxtFld?.label.text = "Location Details"
        locationDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        locationDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        locationDetailTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        locationDetailTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        locationDetailTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        regionalSalesTxtFld?.label.text = "Regional Sales Person"
        regionalSalesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        regionalSalesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        regionalSalesTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        regionalSalesTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        regionalSalesTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        containerTypeTxtFld?.label.text = "Container Type"
        containerTypeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        containerTypeTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        containerTypeTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        containerTypeTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        containerTypeTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        StockDetailTxtFld?.label.text = "Stock Details"
        StockDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        StockDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        StockDetailTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        StockDetailTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        StockDetailTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        BottlesCanesTxtFld?.label.text = "Particular brand Closing Stock in Bott/Canes"
        BottlesCanesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        BottlesCanesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        BottlesCanesTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        BottlesCanesTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        BottlesCanesTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        concernTxtFld?.label.text = "Concern/Complaint Description"
        concernTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        concernTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        concernTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        concernTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        concernTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        brandDetailTxtFld?.label.text = "Brand Name"
        brandDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        brandDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        brandDetailTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        brandDetailTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        brandDetailTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        BatchDetailTxtFld?.label.text = "Batch Number"
        BatchDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        BatchDetailTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        BatchDetailTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        BatchDetailTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        BatchDetailTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        manufactureDateTxtFld?.label.text = "Manufacturing Date"
        manufactureDateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        manufactureDateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        manufactureDateTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        manufactureDateTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        manufactureDateTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        closingStockReviewTxtFld?.label.text = "Particular brand closing stock receive on Date"
        closingStockReviewTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        closingStockReviewTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        closingStockReviewTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        closingStockReviewTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        closingStockReviewTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        DefectedQuanityTxtFld?.label.text = "Defected Quantity"
        DefectedQuanityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        DefectedQuanityTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        DefectedQuanityTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        DefectedQuanityTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        DefectedQuanityTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        DebitNotesTxtFld?.label.text = "Debit note cost"
        DebitNotesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        DebitNotesTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        DebitNotesTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        DebitNotesTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        DebitNotesTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        RemarkTxtFld?.label.text = "Remark"
        RemarkTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        RemarkTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        RemarkTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal) // Placeholder color
        RemarkTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        RemarkTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        dateTxtFld?.setLeftPaddingPoints(20)
        dateTxtFld?.setRightPaddingPoints(20)
        manufactureDateTxtFld?.setLeftPaddingPoints(20)
        manufactureDateTxtFld?.setRightPaddingPoints(20)
        dateTxtFld?.cornerRadius = 4
        dateTxtFld?.layer.masksToBounds = true
        dateTxtFld?.borderWidth = 1.0
        dateTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        let toolbar = createToolbar()
        dateTxtFld?.inputAccessoryView = toolbar
        manufactureDateTxtFld?.inputAccessoryView = toolbar
        outletNameTxtFld?.delegate = self
        doneBtn?.layer.masksToBounds = true
        doneBtn?.layer.cornerRadius = 8
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([donebtn], animated: true)
        datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        dateTxtFld?.inputAccessoryView = toolbar
        manufactureDateTxtFld?.inputAccessoryView = toolbar
        dateTxtFld?.inputView = datePicker
        manufactureDateTxtFld?.inputView = datePicker
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: datePicker.date)
        if !(dateTxtFld?.isFirstResponder ?? true) {
            manufactureDateTxtFld?.text = selectedDate
        } else if !(manufactureDateTxtFld?.isFirstResponder ?? true) {
            dateTxtFld?.text = selectedDate
        }
        self.view.endEditing(true)
    }
    
    func gotoCans() {
        self.view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle:nil)
        let vc = (storyBoard.instantiateViewController(identifier: "CansVc")) as! CansVc
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3966007864)
        vc.isCan = isCan
        vc.completionHandler = { concernText in
            self.concernTxtFld?.text = concernText
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    func showCustomView() {
        let backgroundButton = UIButton(frame: self.view.bounds)
        backgroundButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundButton.tag = 101
        backgroundButton.addTarget(self, action: #selector(dismissCustomView), for: .touchUpInside)
        self.view.addSubview(backgroundButton)
        if containerTypeView?.superview == nil {
            containerTypeView?.center = self.view.center
            self.view.addSubview(containerTypeView ?? UIView())
        }
        containerTypeView?.isHidden = false
        containerTypeView?.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.containerTypeView?.alpha = 1.0
        }
    }

    @objc func dismissCustomView() {
        self.view.viewWithTag(101)?.removeFromSuperview()
        containerTypeView?.removeFromSuperview()
    }
    
    func showStockView() {
        let backgroundButton = UIButton(frame: self.view.bounds)
        backgroundButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundButton.tag = 102
        backgroundButton.addTarget(self, action: #selector(dismissStockView), for: .touchUpInside)
        self.view.addSubview(backgroundButton)
        if stockTypeView?.superview == nil {
            stockTypeView?.center = self.view.center
            self.view.addSubview(stockTypeView ?? UIView())
        }
        stockTypeView?.isHidden = false
        stockTypeView?.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.stockTypeView?.alpha = 1.0
        }
    }

    @objc func dismissStockView() {
        self.view.viewWithTag(102)?.removeFromSuperview()
        stockTypeView?.removeFromSuperview()
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
//    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.sourceType = sourceType
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = false
//        present(imagePickerController, animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.originalImage] as? UIImage {
//            imageView?.image = image
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func cameraButtonTapped(_ sender: UIButton) {
//        
//        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = sourceType
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        
//        func requestCameraPermission() {
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        showImagePicker(sourceType: .camera)
//                    } else {
//                        self.showPermissionAlert(for: "Camera")
//                    }
//                }
//            }
//        }
//        
//        func requestPhotoLibraryPermission() {
//            PHPhotoLibrary.requestAuthorization { status in
//                DispatchQueue.main.async {
//                    switch status {
//                    case .authorized, .limited:
//                        showImagePicker(sourceType: .photoLibrary)
//                    default:
//                        self.showPermissionAlert(for: "Photo Library")
//                    }
//                }
//            }
//        }
//        
//        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
//            switch cameraStatus {
//            case .authorized:
//                showImagePicker(sourceType: .camera)
//            case .notDetermined:
//                requestCameraPermission()
//            default:
//                self.showPermissionAlert(for: "Camera")
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            let photoStatus = PHPhotoLibrary.authorizationStatus()
//            switch photoStatus {
//            case .authorized, .limited:
//                showImagePicker(sourceType: .photoLibrary)
//            case .notDetermined:
//                requestPhotoLibraryPermission()
//            default:
//                self.showPermissionAlert(for: "Photo Library")
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func showPermissionAlert(for feature: String) {
//        let alert = UIAlertController(
//            title: "\(feature) Access Denied",
//            message: "Please enable access to \(feature) in Settings to use this feature.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    
//    @IBAction func cameraButtonTapped(_ sender: UIButton) {
//        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = sourceType
//            
//            // For iPad: Configure popoverPresentationController
//            if let popoverController = imagePicker.popoverPresentationController {
//                popoverController.sourceView = sender // Button triggering the action
//                popoverController.sourceRect = sender.bounds
//                popoverController.permittedArrowDirections = .any
//            }
//            
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        
//        func requestCameraPermission() {
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        showImagePicker(sourceType: .camera)
//                    } else {
//                        self.showPermissionAlert(for: "Camera")
//                    }
//                }
//            }
//        }
//        
//        func requestPhotoLibraryPermission() {
//            PHPhotoLibrary.requestAuthorization { status in
//                DispatchQueue.main.async {
//                    switch status {
//                    case .authorized, .limited:
//                        showImagePicker(sourceType: .photoLibrary)
//                    default:
//                        self.showPermissionAlert(for: "Photo Library")
//                    }
//                }
//            }
//        }
//        
//        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//            // Check if device has a camera
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
//                switch cameraStatus {
//                case .authorized:
//                    showImagePicker(sourceType: .camera)
//                case .notDetermined:
//                    requestCameraPermission()
//                default:
//                    self.showPermissionAlert(for: "Camera")
//                }
//            } else {
//                self.showNoCameraAlert()
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            let photoStatus = PHPhotoLibrary.authorizationStatus()
//            switch photoStatus {
//            case .authorized, .limited:
//                showImagePicker(sourceType: .photoLibrary)
//            case .notDetermined:
//                requestPhotoLibraryPermission()
//            default:
//                self.showPermissionAlert(for: "Photo Library")
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // For iPad: Configure popoverPresentationController for the action sheet
//        if let popoverController = alert.popoverPresentationController {
//            popoverController.sourceView = sender // Button triggering the action
//            popoverController.sourceRect = sender.bounds
//            popoverController.permittedArrowDirections = .any
//        }
//        
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func showPermissionAlert(for feature: String) {
//        let alert = UIAlertController(
//            title: "\(feature) Access Denied",
//            message: "Please enable access to \(feature) in Settings to use this feature.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func showNoCameraAlert() {
//        let alert = UIAlertController(
//            title: "No Camera Available",
//            message: "This device does not have a camera.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.originalImage] as? UIImage {
//            imageView?.image = image
//            selectedImageHexCode = generateImageHexCode(from: image)
//            selectedImageTitle = generateImageTitle(from: info)
//            print("Hex Code: \(selectedImageHexCode ?? "No hex generated")")
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    func generateImageTitle(from info: [UIImagePickerController.InfoKey : Any]) -> String {
//        let defaultTitle = "image_\(UUID().uuidString).jpg"  // Default if metadata is missing
//        if let metadata = info[.mediaMetadata] as? [String: Any],
//           let exifData = metadata["{Exif}"] as? [String: Any],
//           let dateTimeOriginal = exifData["DateTimeOriginal"] as? String {
//            let formattedDate = dateTimeOriginal.replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: " ", with: "_")
//            return "IMG_\(formattedDate).jpg"
//        }
//        return defaultTitle
//    }
//
//    func generateImageHexCode(from image: UIImage) -> String? {
//        guard let imageData = image.pngData() else { return nil }
//        let hash = SHA256.hash(data: imageData)
//        return hash.map { String(format: "%02x", $0) }.joined()
//    }
    
    
    
//    @IBAction func cameraButtonTapped(_ sender: UIButton) {
//            func showImagePicker(sourceType: UIImagePickerController.SourceType) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = sourceType
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//            
//            func requestCameraPermission() {
//                AVCaptureDevice.requestAccess(for: .video) { granted in
//                    DispatchQueue.main.async {
//                        if granted {
//                            showImagePicker(sourceType: .camera)
//                        } else {
//                            self.showPermissionAlert(for: "Camera")
//                        }
//                    }
//                }
//            }
//            
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
//                switch cameraStatus {
//                case .authorized:
//                    showImagePicker(sourceType: .camera)
//                case .notDetermined:
//                    requestCameraPermission()
//                default:
//                    self.showPermissionAlert(for: "Camera")
//                }
//            } else {
//                self.showNoCameraAlert()
//            }
//        }
//        
//        func showPermissionAlert(for feature: String) {
//            let alert = UIAlertController(
//                title: "\(feature) Access Denied",
//                message: "Please enable access to \(feature) in Settings to use this feature.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//                }
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//        
//        func showNoCameraAlert() {
//            let alert = UIAlertController(
//                title: "No Camera Available",
//                message: "This device does not have a camera.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//        
//        // Image Picker Delegate Method
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                imageView?.image = image  // Display image
//                
//                // Convert and compress image
//                if let compressedBase64String = convertImageToBase64(image: image) {
//                    base64ImageString = compressedBase64String
//                    selectedImageTitle = "captured_image_\(UUID().uuidString).jpg"  // Unique image name
//                    
//                    // Convert Base64 to Hex
//                    if let hexCode = convertBase64ToHex(base64String: compressedBase64String) {
//                        imageHexCode = hexCode
//                        print("Hex Code: \(imageHexCode ?? "Conversion Failed")")
//                    } else {
//                        print("Failed to convert Base64 to Hex")
//                    }
//                    
//                    print("Base64 Encoded Image: \(base64ImageString ?? "Conversion Failed")")
//                    print("Image Name: \(selectedImageTitle ?? "N/A")")
//                } else {
//                    print("Failed to generate Base64 string")
//                }
//            }
//            picker.dismiss(animated: true, completion: nil)
//        }
//        
//        // Convert UIImage to Base64 String with 20% compression
//        func convertImageToBase64(image: UIImage) -> String? {
//            guard let compressedImageData = image.jpegData(compressionQuality: 0.8) else { return nil }
//            return compressedImageData.base64EncodedString()
//        }
//        
//        // Convert Base64 String to Hex Code (Actual image data, not SHA-256)
//        func convertBase64ToHex(base64String: String) -> String? {
//            guard let imageData = Data(base64Encoded: base64String) else { return nil }
//            
//            // Convert raw data to hexadecimal string
//            return imageData.map { String(format: "%02x", $0) }.joined()
//        }
    
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
            func showImagePicker(sourceType: UIImagePickerController.SourceType) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = sourceType
                    
                if sourceType == .camera {
                    imagePicker.cameraCaptureMode = .photo
                }
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            func requestCameraPermission() {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            showImagePicker(sourceType: .camera)
                        } else {
                            self.showPermissionAlert(for: "Camera")
                        }
                    }
                }
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch cameraStatus {
                case .authorized:
                    showImagePicker(sourceType: .camera)
                case .notDetermined:
                    requestCameraPermission()
                default:
                    self.showPermissionAlert(for: "Camera")
                }
            } else {
                self.showNoCameraAlert()
            }
        }
        
        func showPermissionAlert(for feature: String) {
            let alert = UIAlertController(
                title: "\(feature) Access Denied",
                message: "Please enable access to \(feature) in Settings to use this feature.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        func showNoCameraAlert() {
            let alert = UIAlertController(
                title: "No Camera Available",
                message: "This device does not have a camera.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // UIImagePickerController Delegate Method
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Resize and compress image before converting to Base64
                if let compressedBase64String = convertImageToBase64(image: image) {
                    base64ImageString = compressedBase64String
                    selectedImageTitle = "captured_image_\(UUID().uuidString).jpg" // Unique image name
                    
                    // Convert Base64 to Hex
                    if let hexCode = convertBase64ToHex(base64String: compressedBase64String) {
                        imageHexCode = hexCode
                        print("Hex Code: \(imageHexCode ?? "Conversion Failed")")
                    } else {
                        print("Failed to convert Base64 to Hex")
                    }
                    
                    print("Base64 Encoded Image: \(base64ImageString ?? "Conversion Failed")")
                    print("Image Name: \(selectedImageTitle ?? "N/A")")
                } else {
                    print("Failed to generate Base64 string")
                }
                
                imageView?.image = image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func convertImageToBase64(image: UIImage) -> String? {
            let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300)) // Resize image
            guard let compressedImageData = resizedImage.jpegData(compressionQuality: 0.2) else { return nil } // Compress image
            print("Compressed Image Size: \(Double(compressedImageData.count) / 1024.0) KB") // Debug: Check file size
            return compressedImageData.base64EncodedString()
        }

        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            let newSize = (widthRatio > heightRatio) ?
                          CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
                          CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            
            let renderer = UIGraphicsImageRenderer(size: newSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        
        func convertBase64ToHex(base64String: String) -> String? {
            guard let imageData = Data(base64Encoded: base64String) else { return nil }
            return imageData.map { String(format: "%02x", $0) }.joined()
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//
//    
    
    
    
    
    @IBAction func submitAction(_ sender: UIButton) {
        saveData()
        if !(selectedImageHexCode?.isEmpty ?? true) {
            uploadImageToServer()
        }
    }
    
    func uploadImageToServer() {
        let imageData = [
            "Title": "QCR-\(outletId)-",
            "AccountId": outletId,
            "PathOnClient": selectedImageTitle ?? EMPTY,
            "FileDataHex": imageHexCode ?? EMPTY
        ] as [String : Any]
        qCROperation.executeUploadImage(localId: 0, param: imageData) { error , response, statusCode in
            print(response ?? [:])
        }
    }
    
    @IBAction func backAction() {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func canBottleAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 1 {
            isCan = true
            containerTypeTxtFld?.text = "CAN"
            self.view.viewWithTag(101)?.removeFromSuperview()
            containerTypeView?.removeFromSuperview()
        } else {
            isCan = false
            containerTypeTxtFld?.text = "BOTTLE"
            self.view.viewWithTag(101)?.removeFromSuperview()
            containerTypeView?.removeFromSuperview()
        }
    }
    
    @IBAction func stockAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 1 {
            isFresh = true
            StockDetailTxtFld?.text = "Fresh"
            self.view.viewWithTag(102)?.removeFromSuperview()
            stockTypeView?.removeFromSuperview()
        } else {
            isFresh = false
            StockDetailTxtFld?.text = "Old"
            self.view.viewWithTag(102)?.removeFromSuperview()
            stockTypeView?.removeFromSuperview()
        }
    }
}

extension ReviewScreenVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
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
            selectedOutletData = outletsTable.getOutletData(forAccountId: self.outletId)
            AccountOwnerId = selectedOutletData?.ownerId ?? ""
            AccountmanagerId = selectedOutletData?.ownerManager ?? ""
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

extension ReviewScreenVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateTxtFld {
            self.createDatePicker()
        } else if textField == concernTxtFld {
            view.endEditing(true)
            self.gotoCans()
        } else if textField == containerTypeTxtFld {
            dismissKeyboard()
            self.showCustomView()
        } else if textField == StockDetailTxtFld {
            dismissKeyboard()
            self.showStockView()
        } else if textField == manufactureDateTxtFld {
            self.createDatePicker()
        } else if textField == outletNameTxtFld {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.outletDropdown.show()
            }
        }
    }
    
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



