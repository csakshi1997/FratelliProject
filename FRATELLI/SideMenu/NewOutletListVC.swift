//
//  NewOutletListVC.swift
//  FRATELLI
//
//  Created by Sakshi on 12/11/24.
//

import UIKit

class NewOutletListVC: UIViewController {
    var outletsTable = OutletsTable()
    @IBOutlet var noDataVw: UIView?
    @IBOutlet var TableVw: UITableView?
    var outlet = [Outlet]()
    var isSideBar: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        noDataVw?.isHidden = true
        TableVw?.rowHeight = UITableView.automaticDimension
        TableVw?.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        outlet = outletsTable.getDataAccordingToIsSync()
        if outlet.isEmpty {
            noDataVw?.isHidden = false
        } else {
            TableVw?.reloadData()
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewOutletListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outlet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewOutletListCell = tableView.dequeueReusableCell(withIdentifier: "NewOutletListCell", for: indexPath) as! NewOutletListCell
        if !outlet.isEmpty {
            let newData = outlet[indexPath.row]
            cell.outletLbl?.text = newData.name
            cell.distributornLbl?.text = newData.distributorName
            cell.channellLbl?.text = newData.channel
            cell.subChannelLBl?.text = newData.subChannel
            cell.classificationlLBl?.text = newData.classification
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

class NewOutletListCell: UITableViewCell {
    @IBOutlet var outletLbl: UILabel?
    @IBOutlet var distributornLbl: UILabel?
    @IBOutlet var channellLbl: UILabel?
    @IBOutlet var subChannelLBl: UILabel?
    @IBOutlet var classificationlLBl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
    }

}

