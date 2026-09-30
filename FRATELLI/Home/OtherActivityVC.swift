//
//  OtherActivityVC.swift
//  FRATELLI
//
//  Created by Sakshi on 18/06/25.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import CoreLocation


class OtherActivityVC: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var nameTxtFld: MDCOutlinedTextField?
    @IBOutlet var startDateTxtFld: MDCOutlinedTextField?
    @IBOutlet var descriptionTxtView: UITextView?
    @IBOutlet var checkInCheckOutBtn: UIButton?
    @IBOutlet var submitBtn: UIButton?
    @IBOutlet var countLbl: UILabel?
    let datePicker = UIDatePicker()
    let locationManager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    var otherActivityTable = OtherActivityTable()
    var appVersionOperation = AppVersionOperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        addTapGestureToDismissKeyboard()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textView = descriptionTxtView?.viewWithTag(101) as? UITextView {
            textView.delegate = self
        }
    }
    
    func initialUI() {
        descriptionTxtView?.delegate = self
        descriptionTxtView?.dropShadow()
        descriptionTxtView?.placeholder = "Enter Description"
        descriptionTxtView?.textColor = .darkGray
        descriptionTxtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        checkInCheckOutBtn?.setTitle("Check In", for: .normal)
        descriptionTxtView?.layer.cornerRadius = 8
        checkInCheckOutBtn?.layer.cornerRadius = 8
        submitBtn?.layer.cornerRadius = 8
        
        nameTxtFld?.label.text = "Name"
        nameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        nameTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        nameTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        nameTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        nameTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        
        startDateTxtFld?.label.text = "Start Date"
        startDateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        startDateTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        startDateTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        startDateTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        startDateTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        startDateTxtFld?.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        startDateTxtFld?.inputAccessoryView = toolbar
    }
    
    @objc func donePressed() {
        dateChanged()
        startDateTxtFld?.resignFirstResponder()
    }
    
    @objc func dateChanged() {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        startDateTxtFld?.text = formatter.string(from: selectedDate)
    }
    
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
        return updatedTextLength <= 500
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
    
    @IBAction func checkInOUTAction() {
        if isFormValid() {
            let status = CLLocationManager.authorizationStatus()
            if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
                let alert = UIAlertController(
                    title: "Location Services Disabled",
                    message: "Please enable location services in Settings to proceed.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            guard let lat = currentLatitude, let lon = currentLongitude else {
                self.view.makeToast("Fetching current location. Please try again in a moment.")
                return
            }
            let confirmAlert = UIAlertController(
                title: "Confirm Check-In",
                message: "Are you sure you want to Check-In at location:\nLat: \(lat), Lon: \(lon)?",
                preferredStyle: .alert
            )
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.checkInCheckOutBtn?.setTitle("Checked In", for: .normal)
                self.view.makeToast("Check-In Successful at location: \(lat), \(lon)")
            }))
            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(confirmAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitAction() {
        guard let lat = currentLatitude, let lon = currentLongitude else {
            self.view.makeToast("Location not available.")
            return
        }
        
        let alert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure you want to Check Out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            let currentDateTime = ISO8601DateFormatter().string(from: Date())
            let activity = OtherActivityModel(
                attributes: OtherActivityModel.Attributes(referenceId: "ref0", type: "Visits__c"),
                checkedOut: true,
                checkedIn: true,
                ownerId: Defaults.userId,
                actualStart: currentDateTime,
                actualEnd: currentDateTime,
                checkedInLat: "\(lat)",
                checkedInLong: "\(lon)",
                checkedOutLat: "\(lat)",
                checkedOutLong: "\(lon)",
                outletCreation: "Other Activity",
                name: self.nameTxtFld?.text ?? "Fratelli Visit",
                remark: self.descriptionTxtView?.text ?? "",
                deviceVersion: self.appVersionOperation.getCurrentAppVersion() ?? "",
                deviceType: "iOS",
                deviceName: UIDevice.current.name,
                isSync: "0"
            )
            
            self.otherActivityTable.saveOtherActivity(activity) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.view.makeToast("Activity saved successfully.")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.view.makeToast("Failed to save activity: \(error ?? "Unknown error")")
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isFormValid() -> Bool {
        let name = nameTxtFld?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let startDate = startDateTxtFld?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTxtView?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty {
            showAlert(message: "Please enter your name.")
            return false
        }
        if startDate.isEmpty {
            showAlert(message: "Please select a start date.")
            return false
        }
        if description.isEmpty || description == "Enter description" {
            showAlert(message: "Please enter a description.")
            return false
        }
        return true
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
        }
    }
}
