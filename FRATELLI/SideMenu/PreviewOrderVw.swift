//
//  PreviewOrderVw.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import UIKit

class PreviewOrderVw: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var confirmBtn: UIButton?
    var salesModel: SalesOrderModel!
    var salesModelLineItems = [SalesOrderLineItems]()
    var isSideBar: Bool = false
    var outletsTable = OutletsTable()
    var outlet: Outlet?
    var salesOrderTable = SalesOrderTable()
    var salesOrderLineItemsTable = SalesOrderLineItemsTable()
    var isSideMenu: Bool = false
    var accountId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        TableVw?.rowHeight = UITableView.automaticDimension
        TableVw?.estimatedRowHeight = 150
        confirmBtn?.dropShadow()
        outlet = outletsTable.getOutletData(forAccountId: currentVisitId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func showAlert(){
        if self.isSideMenu {
            Utility.gotoTabbar()
            SceneDelegate.getSceneDelegate().window?.makeToast(SALESORDER_CREATED)
        } else {
            let storyboardBundle = Bundle.main
            let storyboard = UIStoryboard(name: "Home", bundle: storyboardBundle)
            let dashboardVC = storyboard.instantiateViewController(withIdentifier: "VisibilityVC") as! VisibilityVC
            self.navigationController?.pushViewController(dashboardVC, animated: true)
            dashboardVC.accountId = accountId
            SceneDelegate.getSceneDelegate().window?.makeToast(SALESORDER_CREATED)
        }
    }
    
    func generateAPI() {
        let checkOutalert = UIAlertController(
            title: "Coming soon",
            message: "Work is in progress",
            preferredStyle: .alert
        )
        self.present(checkOutalert, animated: true, completion: nil)
        checkOutalert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
        }))
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction() {
        if !salesModelLineItems.isEmpty {
            salesOrderTable.saveSalesOrder(order: salesModel) { success, error in
                if success {
                    self.submitSalesOrderLineItems()
                } else {
                    SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
                }
            }
        }
    }
    
    func submitSalesOrderLineItems() {
        if !salesModelLineItems.isEmpty {
            salesOrderLineItemsTable.saveSalesOrderLineItems(items: salesModelLineItems) { success, error in
                if success {
                    self.showAlert()
                } else {
                    SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
                }
            }
        }
    }
    
    @objc func generateApiAction() {
        generateAPI()
    }
}

extension PreviewOrderVw: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salesModelLineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PreviewOrderCell = tableView.dequeueReusableCell(withIdentifier: "PreviewOrderCell", for: indexPath) as! PreviewOrderCell
        if !salesModelLineItems.isEmpty {
            let newDataLineItem = salesModelLineItems[indexPath.row]
            cell.outletLbl?.text = outlet?.name ?? ""
            cell.distributornLbl?.text = salesModel.DistributorName ?? ""
            cell.productlLbl?.text = newDataLineItem.Product_Name ?? ""
            cell.schemeTypeLBl?.text = newDataLineItem.Scheme_Type__c ?? ""
            cell.schemePercentagelLBl?.text = newDataLineItem.Scheme_Percentage__c ?? ""
            cell.productlQuantityLbl?.text = newDataLineItem.Product_quantity_c ?? ""
            cell.generateApiBtn?.tag = indexPath.row
            cell.generateApiBtn?.addTarget(self, action: #selector(generateApiAction), for: UIControl.Event.touchUpInside)
            switch newDataLineItem.Scheme_Type__c {
            case "Scheme with VAT/ED":
                cell.schemePercentagelLBlHeading?.text = "Percentage %"
                cell.schemePercentagelLBl?.text = newDataLineItem.Scheme_Percentage__c ?? ""
            case "Scheme without VAT/ED":
                cell.schemePercentagelLBlHeading?.text = "Percentage %"
                cell.schemePercentagelLBl?.text = newDataLineItem.Scheme_Percentage__c ?? ""
            case "Scheme on MRP":
                cell.schemePercentagelLBlHeading?.text = "Percentage %"
                cell.schemePercentagelLBl?.text = newDataLineItem.Scheme_Percentage__c ?? ""
            case "Free Issue with VAT/ED":
                cell.schemePercentagelLBlHeading?.text = "Free Issue Qty"
                cell.schemePercentagelLBl?.text = newDataLineItem.Product_quantity_c ?? ""
            case "Free Issue without VAT/ED":
                cell.schemePercentagelLBlHeading?.text = "Free Issue Qty"
                cell.schemePercentagelLBl?.text = newDataLineItem.Product_quantity_c ?? ""
            case "Flat Amount Scheme":
                cell.schemePercentagelLBlHeading?.text = "Total Amount"
                cell.schemePercentagelLBl?.text = newDataLineItem.Total_Amount_INR__c ?? ""
            case "Zero Scheme":
                cell.schemePercentagelLBl?.text = newDataLineItem.Total_Amount_INR__c ?? ""
            default:
                cell.schemePercentagelLBl?.text =  ""
            }
            
            
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 267
    }
}

class PreviewOrderCell: UITableViewCell {
    @IBOutlet var outletLbl: UILabel?
    @IBOutlet var distributornLbl: UILabel?
    @IBOutlet var productlLbl: UILabel?
    @IBOutlet var productlQuantityLbl: UILabel?
    @IBOutlet var schemeTypeLBl: UILabel?
    @IBOutlet var schemePercentagelLBl: UILabel?
    @IBOutlet var schemePercentagelLBlHeading: UILabel?
    @IBOutlet var generateApiBtn: UIButton?

    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
    }

}


