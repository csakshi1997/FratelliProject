//
//  POSMDetailsVC.swift
//  FRATELLI
//
//  Created by Sakshi on 17/06/25.
//

import UIKit

class POSMDetailsVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var customDateFormatter = CustomDateFormatter()
    var pOSMLineItemsModel: POSMLineItemsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pOSMLineItemsModel)
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension POSMDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: POSMDetailsCell = tableView.dequeueReusableCell(withIdentifier: "POSMDetailsCell", for: indexPath) as! POSMDetailsCell
        cell.poshitemNameLbl?.text = "POSM Name: \(pOSMLineItemsModel?.POSM_Asset_name__c ?? EMPTY)"
        cell.poshitemQuantityLbl?.text = "Quantity: \(pOSMLineItemsModel?.Quantity__c ?? EMPTY)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class POSMDetailsCell: UITableViewCell {
    @IBOutlet var poshitemNameLbl: UILabel?
    @IBOutlet var poshitemQuantityLbl: UILabel?
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

