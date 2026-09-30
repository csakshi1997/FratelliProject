//
//  POSMVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

class POSMVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var customDateFormatter = CustomDateFormatter()
    var pOSMTable = POSMTable()
    var pOSMLineItemsTable = POSMLineItemsTable()
    var pOSMModel = [POSMModel]()
    var pOSMLineItemsModel = [POSMLineItemsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func setInitialUI() {
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false
        pOSMModel = pOSMTable.getPOSMs()
        pOSMLineItemsModel = pOSMLineItemsTable.getPOSMLineItems()
        if pOSMLineItemsModel.count <= 0 {
            noDataVw?.isHidden = false
        } else {
            noDataVw?.isHidden = true
            TableVw?.reloadData()
        }
    }
}

extension POSMVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pOSMLineItemsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: POSMCell = tableView.dequeueReusableCell(withIdentifier: "POSMCell", for: indexPath) as! POSMCell
        let posmLineItemsDict = pOSMLineItemsModel[indexPath.row]
        cell.poshitemListLbl?.text = posmLineItemsDict.POSM_Asset_name__c
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let posmLineItemsDict = pOSMLineItemsModel[indexPath.row]
        let storyboard = UIStoryboard(name: "POSM", bundle: nil)
        if let pOSMDetailsVC = storyboard.instantiateViewController(withIdentifier: "POSMDetailsVC") as? POSMDetailsVC {
            pOSMDetailsVC.pOSMLineItemsModel = posmLineItemsDict
            self.navigationController?.pushViewController(pOSMDetailsVC, animated: true)
        }
    }
}

class POSMCell: UITableViewCell {
    @IBOutlet var poshitemListLbl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        addButtonBorder()
    }
    
    func addButtonBorder() {
        vw?.dropShadow()
    }
}

