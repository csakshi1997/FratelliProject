//
//  AddNewTasksVC.swift
//  FRATELLI
//
//  Created by Sakshi on 06/12/24.
//

import UIKit

class AddNewTasksVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tableVw1: UITableView?
    @IBOutlet var checkBtn: UIButton?
    @IBOutlet var itemTxtFld: UITextField?
    @IBOutlet var submitBtn: UIButton?
    @IBOutlet var addItemBtn: UIButton?
    var pickerView = UIPickerView()
    @IBOutlet var headreViewForTableView: UIView?
    var accountId: String = ""
    var customDateFormatter = CustomDateFormatter()
    var itemsArray: [String] = []
    var addNewTaskModel = [AddNewTaskModel]()
    var addNewTaskTable = AddNewTaskTable()
    var isFromActionItemPopup: Bool = false
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var visitTable = VisitsTable()
    var isCheckEnable: Bool = false {
        didSet {
            if isCheckEnable {
                checkBtn?.setImage(UIImage(named: "checkBox"), for: .normal)
            } else {
                checkBtn?.setImage(UIImage(named: "uncheck"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialView()
        tableVw1?.dropShadow()
        headreViewForTableView?.dropShadow()
        addTapGestureToDismissKeyboard()
    }
    
    func setUpInitialView() {
        itemTxtFld?.delegate = self
        itemTxtFld?.layer.borderWidth = 1
        itemTxtFld?.setLeftPaddingPoints(10.0)
        itemTxtFld?.setRightPaddingPoints(10.0)
        itemTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        tableVw1?.delegate = self
        tableVw1?.dataSource = self
        tableVw1?.separatorStyle = .none
        headreViewForTableView?.isHidden = true
        submitBtn?.layer.cornerRadius = 8
        addItemBtn?.layer.cornerRadius = 8
        itemTxtFld?.layer.cornerRadius = 6
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        itemsArray.append(text)
        textField.text = ""
        tableVw1?.reloadData()
        return true
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addItemAction() {
        let text = itemTxtFld?.text
        if !(text?.isEmpty ?? true) {
            itemsArray.append(text ?? "")
            itemTxtFld?.text = ""
            headreViewForTableView?.isHidden = false
            tableVw1?.reloadData()
        } else {
            headreViewForTableView?.isHidden = true
            showAlert(message: "Please add reason before submit the form")
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func chcekBtnAction() {
        isCheckEnable = !isCheckEnable
    }
    
    @IBAction func submitAction() {
        skipTable.updateForAddNewTask(visitOrderId: currentSelectedVisitId, addNewTask: "0") { success, error in
            if success {
                print("addNewTask skip updated successfully!")
            } else {
                print("Failed to update addNewTask skip: \(error ?? "Unknown error")")
            }
        }
        guard !itemsArray.isEmpty else {
            SceneDelegate.getSceneDelegate().window?.makeToast("No items to submit")
            return
        }
        var addNewTaskModel: [AddNewTaskModel] = []
        for itemsArr in itemsArray {
            let addNewTask = AddNewTaskModel(
                localId: nil,
                Id: "",
                priority: "Normal",
                Settlement_Data__c: customDateFormatter.getDateForSettlement(dateString: customDateFormatter.getFormattedDateForAccount()),
                External_Id__c: externalID,
                OutletId: currentVisitId,
                whatId: "\(currentVisitId)",
                TaskSubject: itemsArr,
                TaskSubtype: "",
                IsTaskRequired: "\(isCheckEnable)",
                TaskStatus: "Open",
                OwnerId: Defaults.userId,
                Visit_Date_c: visitPlanDate,
                Visit_Order_c: currentSelectedVisitId,
                CreatedTime: customDateFormatter.getFormattedDateForAccount(),
                CreatedDate: customDateFormatter.getFormattedTime(),
                createdAt: customDateFormatter.getFormattedDateForAccount(),
                isSync: "0"
            )
            addNewTaskModel.append(addNewTask)
        }
        print(addNewTaskModel)
        addNewTaskTable.saveTasks(tasks: addNewTaskModel) { success, error in
            if success {
                if self.isFromActionItemPopup {
                    self.backAction()
                } else {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    if let checkOutScreen = storyboard.instantiateViewController(withIdentifier: "CheckOutScreen") as? CheckOutScreen {
                        self.navigationController?.pushViewController(checkOutScreen, animated: true)
                    }
                }
                SceneDelegate.getSceneDelegate().window?.makeToast(TASKSAVED_SUCCESSFULLY)
            } else {
                SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
            }
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func skipAction() {
        skipTable.updateForAddNewTask(visitOrderId: currentSelectedVisitId, addNewTask: "1") { success, error in
            if success {
                print("addNewTask skip updated successfully!")
            } else {
                print("Failed to update addNewTask skip: \(error ?? "Unknown error")")
            }
        }
        let checkInalert = UIAlertController(
            title: "Check-Out?",
            message: "Are you sure you want to skip?",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
        checkInalert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            if let checkOutScreen = storyboard.instantiateViewController(withIdentifier: "CheckOutScreen") as? CheckOutScreen {
                self.navigationController?.pushViewController(checkOutScreen, animated: true)
            }
        }))
    }
}

extension AddNewTasksVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewTasksCell", for: indexPath) as! AddNewTasksCell
        cell.itemTableVwTextFld?.text = itemsArray[indexPath.row]
        cell.itemTableVwTextFld?.delegate = self
        cell.itemTableVwTextFld?.tag = indexPath.row
        cell.itemTableVwTextFld?.borderWidth = 0
        cell.itemTableVwTextFld?.setLeftPaddingPoints(25.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            itemsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
class AddNewTasksCell: UITableViewCell {
    @IBOutlet var itemTableVwTextFld: UITextField?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
        itemTableVwTextFld?.borderStyle = .none
        itemTableVwTextFld?.setLeftPaddingPoints(10.0)
        itemTableVwTextFld?.setRightPaddingPoints(10.0)
    }
}
