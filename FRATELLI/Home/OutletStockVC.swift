//
//  OutletStockVC.swift
//  FRATELLI
//
//  Created by Sakshi on 26/11/24.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import DropDown

struct ProductQuantity {
    var productId: String
    var productName: String
    var quantity: Int?
    var riskQuantity: Int?
}


import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class OutletStockVC: UIViewController, UITextFieldDelegate {
    @IBOutlet var productTxtFld: MDCOutlinedTextField?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var headingView: UIView?
    @IBOutlet var proceedBtn: UIButton?
    var productsTable = ProductsTable()
    var product = [Product]()
    var productNamesToIDs: [String: String] = [:]
    var selectedProducts: [ProductQuantity] = []
    var productId = ""
    var accountId: String = ""
    var contactsTable = ContactsTable()
    var localId = [Int]()
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    let dropdownManager = DropdownManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        product = productsTable.getProducts()
        loadProductNames()
        setInitialUI()
        if !localId.isEmpty {
            contactsTable.updateWorkingWithOutleForMultipleIds(localIds: localId)
        }
    }

    func loadProductNames() {
        productNamesToIDs = Dictionary(uniqueKeysWithValues: product.map { ($0.name ?? EMPTY, $0.id ?? EMPTY) })
    }

    func setInitialUI() {
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        headingView?.isHidden = true
        productTxtFld?.label.text = "Product Name"
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        productTxtFld?.setOutlineColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setNormalLabelColor(UIColor.gray, for: .normal)
        productTxtFld?.setFloatingLabelColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .editing)
        productTxtFld?.setLeadingAssistiveLabelColor(UIColor.systemGray, for: .normal)
        productTxtFld?.delegate = self

        configureDropdown()
    }

    func configureDropdown() {
        dropdownManager.setupDropdown(for: productTxtFld!, with: productNamesToIDs) { [weak self] productName, productId in
            guard let self = self else { return }
            if !self.selectedProducts.contains(where: { $0.productId == productId }) {
                let selectedProduct = ProductQuantity(productId: productId, productName: productName, quantity: 1)
                self.selectedProducts.append(selectedProduct)
                self.tableView?.reloadData()
                self.headingView?.isHidden = self.selectedProducts.isEmpty
            }
//            self.productTxtFld?.text = ""
        }
    }

//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == productTxtFld {
//            dropdownManager.showDropdown()
//        }
//        return true
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == productTxtFld {
            if textField.text?.isEmpty ?? true {
                dropdownManager.filterDropdown(with: "") 
            }
            dropdownManager.showDropdown()
        }
        return true
    }


    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productTxtFld, let query = textField.text {
            dropdownManager.filterDropdown(with: query)
            dropdownManager.showDropdown()
        }
    }

    @IBAction func proceedAction() {
        skipTable.updateRiskStockByVisitOrder(visitOrderId: currentSelectedVisitId, riskStock: "0") { success, error in
            if success {
                print("riskStock skip updated successfully!")
            } else {
                print("Failed to update riskStock skip: \(error ?? "Unknown error")")
            }
        }
        if selectedProducts.isEmpty {
            showAlert(message: "Please select at least one product.")
            return
        }
        saveAllQuantities()
print(selectedProducts)
        for product in selectedProducts {
            if product.quantity == nil || product.quantity! < 0 {
                showAlert(message: "Please enter a valid quantity (0 or more) for all products.")
                return
            }
        }

        if let riskStockVC = storyboard?.instantiateViewController(withIdentifier: "RiskStockVC") as? RiskStockVC {
            riskStockVC.selectedProducts = selectedProducts
            riskStockVC.accountId = accountId
            navigationController?.pushViewController(riskStockVC, animated: true)
        }
    }
    
    func saveAllQuantities() {
        guard let visibleCells = tableView?.visibleCells as? [OutletStockCell] else { return }
        for cell in visibleCells {
            if let indexPath = tableView?.indexPath(for: cell),
               let text = cell.quantityTxtFld?.text,
               let quantity = Int(text) {
                selectedProducts[indexPath.row].quantity = quantity
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func skipForNowAction() {
        skipTable.updateRiskStockByVisitOrder(visitOrderId: currentSelectedVisitId, riskStock: "1") { success, error in
            if success {
                print("riskStock skip updated successfully!")
            } else {
                print("Failed to update riskStock skip: \(error ?? "Unknown error")")
            }
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let PromotionRecomVC = storyboard.instantiateViewController(withIdentifier: "PromotionRecomVC") as? PromotionRecomVC {
            navigationController?.pushViewController(PromotionRecomVC, animated: true)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OutletStockVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OutletStockCell = tableView.dequeueReusableCell(withIdentifier: "OutletStockCell", for: indexPath) as! OutletStockCell
        let backgroundImage = UIImage(named: "bg")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundView = backgroundImageView
        let selectedProduct = selectedProducts[indexPath.row]
        cell.nameLbl?.text = selectedProduct.productName
        cell.quantityTxtFld?.text = "\(selectedProduct.quantity ?? 0)"
        cell.quantityTxtFld?.tag = indexPath.row
        cell.quantityTxtFld?.delegate = self
        cell.quantityTxtFld?.addTarget(self, action: #selector(quantityChanged(_:)), for: .editingChanged)
        return cell
    }
    
    @objc func quantityChanged(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }

        if text.isEmpty {
            selectedProducts[sender.tag].quantity = nil
            return
        }

//        if let quantity = Int(text), sender.tag < selectedProducts.count {
//            if quantity <= 0 {
//                sender.text = "1"
//                selectedProducts[sender.tag].quantity = 1
//                showAlert(message: "Quantity must be greater than 0.")
//            } else {
//                selectedProducts[sender.tag].quantity = quantity
//            }
//        } else {
//            sender.text = "1"
//            selectedProducts[sender.tag].quantity = 1
//            showAlert(message: "Invalid quantity. Setting to 1.")
//        }
    }
}

class OutletStockCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var quantityLbl: UILabel?
    @IBOutlet var quantityTxtFld: UITextField?
    @IBOutlet var vw: UIView?
}
