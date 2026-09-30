//
//  ExistingReportVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import UIKit

class ExistingReportVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var rQCRModel = [RQCRModel]()
    var rQCRTable = RQCRTable()
    var isSideBar: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        noDataVw?.isHidden = true
        TableVw?.rowHeight = UITableView.automaticDimension
        TableVw?.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rQCRModel = rQCRTable.getRQCRsWhereIsSyncZero()
        if rQCRModel.isEmpty {
            noDataVw?.isHidden = false
        } else {
            TableVw?.reloadData()
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction() {
        backAction()
    }
    
    @objc func readMoreAction() {
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "SideMenu", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "ReviewScreenVC") as! ReviewScreenVC
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
}

extension ExistingReportVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rQCRModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExistingReportCell = tableView.dequeueReusableCell(withIdentifier: "ExistingReportCell", for: indexPath) as! ExistingReportCell
        if !rQCRModel.isEmpty {
            let newData = rQCRModel[indexPath.row]
            cell.locationLbl?.text = newData.locationDetails
            cell.regionalSalesLbl?.text = newData.regionalSalesPerson
            cell.concernLbl?.text = newData.concernDetails
            cell.stockDetailsLBl?.text = newData.stockDetails
            cell.bottleLBl?.text = newData.canBottle
            cell.readMoreBtn?.addTarget(self, action: #selector(readMoreAction), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}

class ExistingReportCell: UITableViewCell {
    @IBOutlet var locationLbl: UILabel?
    @IBOutlet var regionalSalesLbl: UILabel?
    @IBOutlet var concernLbl: UILabel?
    @IBOutlet var stockDetailsLBl: UILabel?
    @IBOutlet var bottleLBl: UILabel?
    @IBOutlet var vw: UIView?
    @IBOutlet var readMoreBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
    }

}



