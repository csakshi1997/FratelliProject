//
//  VisitsVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

class VisitsVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var visitsTable = VisitsTable()
    var visits = [Visit]()
    var customDateFormatter = CustomDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func setInitialUI() {
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false
        visits = visitsTable.fetchTodaysVisits()
        if visits.isEmpty {
            noDataVw?.isHidden = false
        } else {
            noDataVw?.isHidden = true
            TableVw?.reloadData()
        }
    }
    
}

extension VisitsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VisitsCell = tableView.dequeueReusableCell(withIdentifier: "VisitsCell", for: indexPath) as! VisitsCell
        if !visits.isEmpty {
            let visit = visits[indexPath.row]
            cell.nameLbl?.text = visit.name
            cell.subnameLbl?.text = "On- Premise/General"
            cell.addressLbl?.text = "\(visit.ownerArea), \(visit.area ?? "")"
            cell.visistDateLbl?.text = "Order: \(customDateFormatter.getDateForVisits(dateString: visit.visitPlanDate))"
            cell.orderDateLbl?.text = "Visits: \(customDateFormatter.getDateForVisitsOrderDate(dateString: visit.actualStart ?? ""))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
}

class VisitsCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var subnameLbl: UILabel?
    @IBOutlet var addressLbl: UILabel?
    @IBOutlet var orderDateLbl: UILabel?
    @IBOutlet var visistDateLbl: UILabel?
    @IBOutlet var latLongLbl: UILabel?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        addButtonBorder()
    }
    
    func addButtonBorder() {
        vw?.dropShadow() // Set a background color to make the shadow visible

    }
}

