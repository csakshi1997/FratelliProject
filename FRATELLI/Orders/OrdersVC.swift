//
//  OrdersVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

class OrdersVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    var contactsTable = ContactsTable()
    var contact = [Contact]()
    var items: [String] = ["Lorem Ipsum (5 Bottles)", "Lorem Ipsum (10 Bottles)","Lorem Ipsum (15 Bottles)", "Lorem Ipsum (5 Bottles)", "Lorem Ipsum (5 Bottles)"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        TableVw?.dataSource = self
        TableVw?.delegate = self
        TableVw?.rowHeight = UITableView.automaticDimension
        TableVw?.estimatedRowHeight = 150
    }
    
    func setInitialUI() {
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false
        contact = contactsTable.getContacts()
        if contact.isEmpty {
            noDataVw?.isHidden = false
        } else {
            noDataVw?.isHidden = true
            TableVw?.reloadData()
        }
    }
    
}

extension OrdersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OrdersCell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath) as! OrdersCell
        cell.orderListLbl?.text = ""
        for item in items {
            cell.orderListLbl?.text = (cell.orderListLbl?.text ?? "") + "\(item)\n"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class OrdersCell: UITableViewCell {
    @IBOutlet var nameLbl: UILabel?
    @IBOutlet var subnameLbl: UILabel?
    @IBOutlet var addressLbl: UILabel?
    @IBOutlet var orderListLbl: UILabel?
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

