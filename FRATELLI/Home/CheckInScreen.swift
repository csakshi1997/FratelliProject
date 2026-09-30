//
//  CheckInScreen.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import UIKit
import SQLite3

class CheckInScreen: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var proceedBtn: UIButton?
    var date: String?
    var time: String?
    var address: String?
    var accountId : String = ""
    var visitTable = VisitsTable()
    var onAssetsTable = OnAssetsTable()
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var dealer_Distributor_CORP__c = ""
    var outletsTable = OutletsTable()
    var outlet: Outlet?
    var outletData: Outlet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proceedBtn?.layer.masksToBounds = true
        proceedBtn?.layer.cornerRadius = 8
        outlet = outletsTable.getOutletData(forAccountId: currentVisitId)
        dealer_Distributor_CORP__c = outlet?.accountId ?? ""
        if let visit = visitTable.getVisitDataByAccountId(accountId: currentVisitId) {
            if (visit.outletType == "Retail"){
                isoffTrade = true
            } else {
                isoffTrade = false
            }
        }
        Defaults.storeLastChcekInDate()
        Defaults.storeCheckInStatus(isCheckedIn: true)
        let syncOperation = SyncOperation()
        onAssetsTable.clearAssetsTable { success, error in
            if success {
                print("Table cleared. Proceeding with sync operation.")
                
                let syncOperation = SyncOperation()
                syncOperation.executeSyncForOnTradeOffTrade(syncType: "addAsset", syncName: "addAsset") { error, response, statusCode in
                    if let error = error {
                        print("Error during sync for addAsset: \(error)")
                    } else {
                        print("Sync completed for addAsset with status code: \(statusCode)")
                        
                        
                    }
                }
            } else {
                print("Failed to clear table: \(error ?? "Unknown error")")
            }
        }
        saveOrUpdateSkipData()
    }
    
    func saveOrUpdateSkipData() {
        outletData = outletsTable.getOutletData(forAccountId: currentVisitId)
        let attributes = Visit.Attributes(type: "Visits__c", url: "")
        let account = SkipModel.Account(classification: outletData?.classification ?? "", id: outletData?.id ?? "", name: outletData?.name ?? "", ownerId: "", subChannel: outletData?.subChannel ?? "")
        let visitOrderId = currentSelectedVisitId
        skipTable.isVisitOrderExist(visitOrderId: visitOrderId) { exists in
            let skipdata = SkipModel(
                localId: nil,
                accountId: currentVisitId,
                accountReference: account,
                Visit_Order__c: visitOrderId,
                Dealer_Distributor_CORP__c: self.dealer_Distributor_CORP__c,
                OwnerId: Defaults.userId,
                Meet_Greet__c: "0",
                Risk_Stock__c: "0",
                Asset_Visibility__c: "0",
                POSM_Request__c: "0",
                Sales_Order__c: "0",
                QCR__c: "0",
                Follow_up_task__c: "0",
                isNew: visitOrderId == "" ? "1" : "0",
                isSync: "0",
                Visit_Date_c: visitPlanDate,
                Visit_Order_c: currentSelectedVisitId
            )
            if exists {
                self.skipTable.updateSkipEntryByVisitOrder(skip: skipdata) { success, error in
                    if success {
                        print("Skip data updated successfully!")
                    } else {
                        print("Failed to update Skip data: \(error ?? "Unknown error")")
                    }
                }
            } else {
                self.skipTable.saveSkipEntry(skip: skipdata) { success, error in
                    if success {
                        print("Skip data saved successfully!")
                    } else {
                        print("Failed to save Skip data: \(error ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    @IBAction func proceedAction() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let checkInScreen = storyboard.instantiateViewController(withIdentifier: "OutletDetailsVC") as? OutletDetailsVC {
            checkInScreen.accountId = accountId
            self.navigationController?.pushViewController(checkInScreen, animated: true)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CheckInScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CheckInCell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell", for: indexPath) as! CheckInCell
        cell.dateLabel?.text = date
        cell.timeLabel?.text = time
        cell.addressLabel?.text = address
        print(address)
        return cell
    }
}

class CheckInCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var addressLabel: UILabel?
    @IBOutlet var vw: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        vw?.dropShadow()
    }
}
