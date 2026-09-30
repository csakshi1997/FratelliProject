//
//  AddNewContactVC.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import UIKit

class AddNewContactVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    @IBOutlet var titleTxtFld: UITextField?
    @IBOutlet var firstTxtFld: UITextField?
    @IBOutlet var lastTxtFld: UITextField?
    @IBOutlet var roleTxtFld: UITextField?
    @IBOutlet var phoneFld: UITextField?
    @IBOutlet var emailTxtFld: UITextField?
    @IBOutlet var workingWithOutletBtn: UIButton?
    @IBOutlet var doneBtn: UIButton?
    var validation = Validation()
    var isSideBar: Bool = false
    var contactsTable = ContactsTable()
    var accountId : String = ""
    var onContactSaved: (() -> Void)?
    var titleOptions = ["Mr.", "Ms.", "Mrs."]
    var titlePickerView = UIPickerView()
    var customDateFormatter = CustomDateFormatter()
    var isWorkingWithOutlet : Bool = false {
        didSet {
            if isWorkingWithOutlet {
                workingWithOutletBtn?.setImage(UIImage(named: "workingWithOutlet"), for: UIControl.State.normal)
            } else {
                workingWithOutletBtn?.setImage(UIImage(named: "uncheck"), for: UIControl.State.normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTitlePicker()
        hideKeyboardWhenTappedAround()
    }
    
    func setupTitlePicker() {
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
        titleTxtFld?.inputView = titlePickerView
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        titleTxtFld?.inputAccessoryView = toolbar
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        doneBtn?.cornerRadius = 4
        doneBtn?.layer.masksToBounds = true
        titleTxtFld?.setLeftPaddingPoints(20)
        firstTxtFld?.setLeftPaddingPoints(20)
        lastTxtFld?.setLeftPaddingPoints(20)
        roleTxtFld?.setLeftPaddingPoints(20)
        phoneFld?.setLeftPaddingPoints(20)
        emailTxtFld?.setLeftPaddingPoints(20)
        titleTxtFld?.setRightPaddingPoints(20)
        firstTxtFld?.setRightPaddingPoints(20)
        lastTxtFld?.setRightPaddingPoints(20)
        roleTxtFld?.setRightPaddingPoints(20)
        phoneFld?.setRightPaddingPoints(20)
        emailTxtFld?.setRightPaddingPoints(20)
        titleTxtFld?.cornerRadius = 4
        titleTxtFld?.layer.masksToBounds = true
        firstTxtFld?.cornerRadius = 4
        firstTxtFld?.layer.masksToBounds = true
        lastTxtFld?.cornerRadius = 4
        lastTxtFld?.layer.masksToBounds = true
        roleTxtFld?.cornerRadius = 4
        roleTxtFld?.layer.masksToBounds = true
        phoneFld?.cornerRadius = 4
        phoneFld?.layer.masksToBounds = true
        emailTxtFld?.cornerRadius = 4
        emailTxtFld?.layer.masksToBounds = true
        titleTxtFld?.borderWidth = 1.0
        titleTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        firstTxtFld?.borderWidth = 1.0
        firstTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        lastTxtFld?.borderWidth = 1.0
        lastTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        roleTxtFld?.borderWidth = 1.0
        roleTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        phoneFld?.borderWidth = 1.0
        phoneFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        emailTxtFld?.borderWidth = 1.0
        emailTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        doneBtn?.borderWidth = 1.0
        doneBtn?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    func saveNewContact() {
        guard let title = titleTxtFld?.text, !title.isEmpty else {
            showAlert(message: "Please select a title.")
            return
        }
        
        guard let firstName = firstTxtFld?.text, !firstName.isEmpty else {
            showAlert(message: "Please enter the first name.")
            return
        }
        
        guard let lastName = lastTxtFld?.text, !lastName.isEmpty else {
            showAlert(message: "Please enter the last name.")
            return
        }
        
        guard let role = roleTxtFld?.text, !role.isEmpty else {
            showAlert(message: "Please enter the role.")
            return
        }
        
        guard let phone = phoneFld?.text, isValidPhone(phone) else {
            showAlert(message: "Please enter a valid phone number.")
            return
        }
        
        if !(emailTxtFld?.text?.isEmpty ?? true) {
            guard let email = emailTxtFld?.text, validation.isValidEmail(email) else {
                showAlert(message: "Please enter a valid email address.")
                return
            }
        }
        
        let newContact = Contact(
            aadharNo: "",
            accountId: accountId,
            email: emailTxtFld?.text,
            firstName: firstName,
            contactId: "",
            lastName: lastName,
            middleName: "",
            name: firstName,
            ownerId: Defaults.userId,
            phone: phone,
            remark: "",
            salutation: title,
            title: role,
            isSync: "0",
            workingWithOutlet: isWorkingWithOutlet ? 1 : 0,
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            Visit_Date_c: visitPlanDate,
            Visit_Order_c: currentSelectedVisitId,
            External_id: externalID
        )
        contactsTable.saveContact(contact: newContact) { success, error in
            if success {
                print("Contact saved successfully!")
                self.backAction()
            } else {
                print("Failed to save contact: \(error ?? "Unknown error")")
            }
        }
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titleOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        titleTxtFld?.text = titleOptions[row]
    }
    
    @IBAction func workingWithOutletAction() {
        isWorkingWithOutlet = !isWorkingWithOutlet
    }
    
    @IBAction func backAction() {
        onContactSaved?()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAction() {
        saveNewContact()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneFld {
            // Combine the current text with the new input
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                return false
            }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Allow only up to 10 digits
            return updatedText.count <= 10
        }
        return true
    }
}
