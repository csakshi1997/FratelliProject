//
//  SideBarViewController.swift
//  FRATELLI
//
//  Created by Sakshi on 28/10/24.
//

import UIKit

class SideBarViewController: UIViewController {
    var completionHandler : (String) -> Void = {_ in }
    @IBOutlet var versionLabl: UILabel?
    let outletsTable = OutletsTable()
    let rQCRTable = RQCRTable()
    let contactsTable = ContactsTable()
    let riskStockTable = RiskStockTable()
    let advocacyTable = AdvocacyTable()
    let riskStockLineItemsTable = RiskStockLineItemsTable()
    let pOSMTable = POSMTable()
    let pOSMLineItemsTable = POSMLineItemsTable()
    let addNewTaskTable = AddNewTaskTable()
    let visitsTable = VisitsTable()
    var outlets = [Outlet]()
    var rQCRModel = [RQCRModel]()
    var advocacyRequest = [AdvocacyRequest]()
    var contact = [Contact]()
    var riskStock = [RiskStock]()
    var riskStockLineItem = [RiskStockLineItem]()
    var pOSMModel = [POSMModel]()
    var pOSMLineItemsModel = [POSMLineItemsModel]()
    var addNewTaskModel = [AddNewTaskModel]()
    var visits = [Visit]()
    var appVersionOperation = AppVersionOperation()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        versionLabl?.text = "v.\(appVersionOperation.getCurrentAppVersion() ?? "")"
    }
    
    func checkInternetConnection(storyBoardName : UIViewController) {
        if InternetConnectionManager.isConnectedToNetwork(){
            navigationController?.pushViewController(storyBoardName, animated: true)
        }else{
            self.completionHandler("fd")
            self.dismiss(animated: true)
        }
    }
    
    func checkDataSyncedorNot() -> Bool {
        outlets = outletsTable.getDataAccordingToIsSync()
        rQCRModel = rQCRTable.getRQCRsWhereIsSyncZero()
        advocacyRequest = advocacyTable.getAdvocacyRequestsWhereIsSyncZero()
        contact = contactsTable.getContactsWhereIsSyncZero()
        riskStock = riskStockTable.getRiskStocksWhereIsSyncZero()
        riskStockLineItem = riskStockLineItemsTable.getRiskStockLineItemsWhereIsSyncZero()
        pOSMModel = pOSMTable.getPOSMsWhereIsSyncZero()
        pOSMLineItemsModel = pOSMLineItemsTable.getPOSMLineItemsWhereIsSyncZero()
        addNewTaskModel = addNewTaskTable.getTasksWhereIsSyncZero()
        visits = visitsTable.getVisitsWhereIsSyncZero()
        if !outlets.isEmpty || !rQCRModel.isEmpty || !advocacyRequest.isEmpty || !riskStock.isEmpty || !riskStockLineItem.isEmpty || !pOSMModel.isEmpty || !pOSMLineItemsModel.isEmpty || !addNewTaskModel.isEmpty || !visits.isEmpty {
            showAlert(title: "Alert", message: "First complete your SyncUp process, After that you can Logout")
            return false
        } else {
            return true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func setupCloseButton() {
        let closeButton = UIButton(frame: CGRect(x: 20, y: 40, width: 100, height: 50))
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callAdhocSalesOrderAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "AdhocSalesOrderVw") as! AdhocSalesOrderVw
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func existingOutletAction() {
        Utility.gotoTabbar()
    }
    
    @IBAction func newOutletAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "NewOutletVC") as! NewOutletVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func newOutleListtAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "NewOutletListVC") as! NewOutletListVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func createVisitAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "CreateVisitVC") as! CreateVisitVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func otherActivityAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "Home", bundle: storyboardBundle)
        let otherActivityVC = storyboard.instantiateViewController(withIdentifier: "OtherActivityVC") as! OtherActivityVC
        checkInternetConnection(storyBoardName: otherActivityVC)
    }
    
    @IBAction func logoutAction() {
        let isItTrueOrNot = checkDataSyncedorNot()
        if (Defaults.isIncompleteVisitName ?? false) {
            let checkINOutalert = UIAlertController(
                title: "Info",
                message: "Hey, You have Visit \(Defaults.incompleteVisitName ?? "") is in-progress, please complete this visit first after that you can proceed further.",
                preferredStyle: .alert
            )
            checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(checkINOutalert, animated: true, completion: nil)
            return
        } else {
            if isItTrueOrNot {
                let checkInalert = UIAlertController(
                    title: "Confirmation",
                    message: "Are you sure you want to Logout?",
                    preferredStyle: .alert
                )
                self.present(checkInalert, animated: true, completion: nil)
                checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
                    print("Cancel tapped")
                }))
                
                checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    Utility.logoutAction(isRedirectedToLogin: true)
                }))
            }
        }
    }
    
    @IBAction func createQCRFormtAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "ReviewScreenVC") as! ReviewScreenVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func syncDownAction() {
        print(Defaults.isIncompleteVisitName)
        if (Defaults.isIncompleteVisitName ?? false) {
            let checkINOutalert = UIAlertController(
                title: "Info",
                message: "Hey, You have Visit \(Defaults.incompleteVisitName ?? "") is in-progress, please complete this visit first after that you can proceed further.",
                preferredStyle: .alert
            )
            checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(checkINOutalert, animated: true, completion: nil)
            return
        } else if Defaults.isSyncUpComplete ?? false {
            Utility.gotoSyncVc(isFromSideMenu: true)
        } else {
            let checkINOutalert = UIAlertController(
                title: "Info",
                message: "Hey, Your Sync Up is Incomplete please complete it. After that you can proceed further.",
                preferredStyle: .alert
            )
            checkINOutalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(checkINOutalert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func callForHelpAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "callForHelpVw") as! callForHelpVw
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func advocacyReqVCAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "AdvocacyReqVC") as! AdvocacyReqVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func callForPOSMReqAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "AddPOSMReqVC") as! AddPOSMReqVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    @IBAction func callForExistingReportAction() {
        self.dismiss(animated: false, completion: nil)
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "ExistingReportVC") as! ExistingReportVC
        checkInternetConnection(storyBoardName: dashboardVC)
    }
    
    
    
    
    
    
}
