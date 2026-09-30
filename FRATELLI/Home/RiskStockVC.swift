//
//  RiskStockVC.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import UIKit
import Toast_Swift

class RiskStockVC: UIViewController {
    var selectedProducts: [ProductQuantity] = []
    @IBOutlet var tableView: UITableView?
    @IBOutlet var headerView: UIView?
    @IBOutlet var txtView: UITextView?
    @IBOutlet var promotionBtn: UIButton?
    @IBOutlet var proceedBtn: UIButton?
    var accountId : String = ""
    var customDateFormatter = CustomDateFormatter()
    var riskStockTable = RiskStockTable()
    var riskStockLineItemsTable = RiskStockLineItemsTable()
    var isPromotionEnable: Bool = false {
        didSet {
            if isPromotionEnable {
                promotionBtn?.setImage(UIImage(named: "checkBox"), for: .normal)
            } else {
                promotionBtn?.setImage(UIImage(named: "uncheck"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView?.dropShadow()
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        print(selectedProducts)
        tableView?.reloadData()
        txtView?.placeholder = "Enter text here"
        txtView?.textColor = .darkGray
        txtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sendRiskStock() {
        guard !selectedProducts.isEmpty else { return }
        let riskStock = RiskStock(
            localId: nil,
            externalid: externalID,
            DateTime: customDateFormatter.getFormattedDateForAccount(),
            outletId: currentVisitId,
            ownerId: Defaults.userId,
            isInitiateCustomerPromotion: isPromotionEnable,
            remarks: txtView?.text,
            isSync: "0",
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            Visit_Date_c: visitPlanDate,
            Visit_Order_c: currentSelectedVisitId
        )
        riskStockTable.saveRiskStock(riskStock: riskStock) { success, error in
            if success {
                self.sendRiskStockLineItems()
            } else if let error = error {
                print("Error saving RiskStock \(error)")
                SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save RiskStock. Please try again.")
            }
        }
    }
    
    func sendRiskStockLineItems() {
        guard !selectedProducts.isEmpty else { return }
        let dispatchGroup = DispatchGroup()
        var saveErrorOccurred = false
        for (index, lineItem) in selectedProducts.enumerated() {
            dispatchGroup.enter()
            let riskStockLineItem = RiskStockLineItem(
                localId: nil,
                externalid: externalID,
                Product_Name__c: lineItem.productId,
                Outlet_Stock_In_Btls__c: lineItem.quantity,
                Risk_Stock_In_Btls__c: lineItem.riskQuantity,
                DateTime: customDateFormatter.getFormattedDateForAccount(),
                ownerId: Defaults.userId,
                isSync: "0",
                createdAt: customDateFormatter.getFormattedDateForAccount()
            )
            riskStockLineItemsTable.saveRiskStockLineItem(riskStockLineItem: riskStockLineItem) { success, error in
                if success {
                    SceneDelegate.getSceneDelegate().window?.makeToast("Risk Stock Line Items saved successfully.")
                } else if let error = error {
                    SceneDelegate.getSceneDelegate().window?.makeToast("Error saving RiskStockLineItem \(error)")
                    saveErrorOccurred = true
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            if saveErrorOccurred {
                SceneDelegate.getSceneDelegate().window?.makeToast("Some items failed to save. Please try again.")
            } else {
                self.navigateToNextScreen()
            }
        }
    }
    
    func navigateToNextScreen() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let promotionRecomVC = storyboard.instantiateViewController(withIdentifier: "PromotionRecomVC") as? PromotionRecomVC {
            promotionRecomVC.accountId = accountId
            self.navigationController?.pushViewController(promotionRecomVC, animated: true)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func promotionAction() {
        isPromotionEnable = !isPromotionEnable
    }
    
    @IBAction func proceedAction() {
        for (index, product) in selectedProducts.enumerated() {
            if let cell = tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as? RiskStockCell {
                if let riskQuantityText = cell.riskQuantityTxtFld?.text, riskQuantityText.isEmpty {
                    self.showAlert(message: "Please fill stock at risk quantity for \(product.productName).")
                    return
                }
                
                if let riskQuantityText = cell.riskQuantityTxtFld?.text, let riskQuantity = Int(riskQuantityText) {
//                    if riskQuantity <= 0 {
//                        self.showAlert(message: "Stock at risk quantity for \(product.productName) must be greater than 1.")
//                        return
//                    }
                    
                    if riskQuantity > product.quantity ?? 0 {
                        self.showAlert(message: "Stock at risk quantity for \(product.productName) must be equal to or less than the outlet stock.")
                        return
                    }
                    
                    selectedProducts[index].riskQuantity = riskQuantity
                } else {
                    self.showAlert(message: "Invalid stock at risk quantity for \(product.productName). Please enter a valid number.")
                    return
                }
            }
        }
        sendRiskStock()
    }
}


extension RiskStockVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RiskStockCell = tableView.dequeueReusableCell(withIdentifier: "RiskStockCell", for: indexPath) as! RiskStockCell
        let selectedProduct = selectedProducts[indexPath.row]
        cell.nameLbl?.text = selectedProduct.productName
        cell.quantityLbl?.text = "\(selectedProduct.quantity ?? 0)"
        cell.riskQuantityTxtFld?.text = ""
        cell.riskQuantityTxtFld?.delegate = self
        cell.riskQuantityTxtFld?.tag = indexPath.row
        let backgroundImage = UIImage(named: "bg")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundView = backgroundImageView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
}

extension RiskStockVC: UITextFieldDelegate {
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        let rowIndex = textField.tag
//        let selectedProduct = selectedProducts[rowIndex]
//        if let text = textField.text, let enteredQuantity = Int(text) {
//            if enteredQuantity > selectedProduct.quantity ?? 0 {
//                SceneDelegate.getSceneDelegate().window?.makeToast(Stock_Error)
//                textField.text = "\(selectedProduct.quantity ?? 0)"
//                return false
//            }
//        }
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let rowIndex = textField.tag
        if let text = textField.text, let enteredRiskQuantity = Int(text) {
            selectedProducts[rowIndex].riskQuantity = enteredRiskQuantity
        }
    }
}

class RiskStockCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var quantityLbl: UILabel?
    @IBOutlet var riskQuantityTxtFld: UITextField?
    @IBOutlet var vw: UIView?
}

