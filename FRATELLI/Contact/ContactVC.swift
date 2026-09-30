//
//  ContactVC.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit

class ContactVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    var contactsTable = ContactsTable()
    var contact = [Contact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
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
    
    @objc func viewContactDetails(_ sender: UIButton) {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ContactDetailsVC") {
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
   

}

extension ContactVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        if !contact.isEmpty {
            let contact = contact[indexPath.row]
            cell.firstLastLbl?.text = contact.name
        }
        cell.viewContactBtn?.tag = indexPath.row
        cell.viewContactBtn?.addTarget(self, action: #selector(viewContactDetails(_:)), for: .touchUpInside)
        cell.viewContactBtn?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        cell.viewContactBtn?.layer.borderWidth = 1
        cell.viewContactBtn?.layer.cornerRadius = 12.0
        cell.viewContactBtn?.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class ContactCell: UITableViewCell {
    @IBOutlet var firstLastLbl: UILabel?
    @IBOutlet var addressLbl: UILabel?
    @IBOutlet var viewContactBtn: UIButton?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        addButtonBorder()
    }
    
    func addButtonBorder() {
        vw?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        vw?.layer.borderWidth = 1
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
    }
}

