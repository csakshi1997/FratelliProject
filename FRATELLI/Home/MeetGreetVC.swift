//
//  MeetGreetVC.swift
//  FRATELLI
//
//  Created by Sakshi on 26/11/24.
//

import UIKit

class MeetGreetVC: UIViewController {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var noDataVw: UIView?
    @IBOutlet var proceedBtn: UIButton?
    var contactsTable = ContactsTable()
    var contact = [Contact]()
    var accountId : String = ""
    var selectedCells: Set<Int> = []
    var contacts = [Contact]()
    var localIds = [Int]()
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var visitsTable = VisitsTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipTable.updateMeetGreetByVisitOrder(visitOrderId: currentSelectedVisitId, meetGreet: "0") { success, error in
            if success {
                print("Meet_Greet__c updated successfully!")
            } else {
                print("Failed to update Meet_Greet__c: \(error ?? "Unknown error")")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Contact_Person_Name__c = ""
        Contact_Phone_No__c = ""
        setInitialUI()
    }
    
//    func setInitialUI() {
//        proceedBtn?.layer.cornerRadius = 8.0
//        proceedBtn?.layer.masksToBounds = true
//        TableVw?.showsVerticalScrollIndicator = false
//        TableVw?.showsHorizontalScrollIndicator = false
//        contact = contactsTable.getContactsOnTheBasisOfAccountIds(forAccountId: accountId)
//        if contact.isEmpty {
//            noDataVw?.isHidden = false
//        } else {
//            noDataVw?.isHidden = true
//            TableVw?.reloadData()
//        }
//    }
    
    func setInitialUI() {
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        TableVw?.showsVerticalScrollIndicator = false
        TableVw?.showsHorizontalScrollIndicator = false

        contact = contactsTable.getContactsOnTheBasisOfAccountIds(forAccountId: accountId)
        
        selectedCells.removeAll()

        for (index, c) in contact.enumerated() {
            if c.workingWithOutlet == 1 {
                selectedCells.insert(index)
                if let firstSelectedIndex = selectedCells.first {
                    let selectedContact = contact[firstSelectedIndex]
                    visitsTable.updateContactDetails(accountId: accountId, contactPersonName: selectedContact.name ?? "", contactPhoneNumber: selectedContact.phone ?? "") { success, error in
                        if success {
                            
                        }
                    }
                }
            }
        }

        noDataVw?.isHidden = !contact.isEmpty
        TableVw?.reloadData()
    }
    
    @IBAction func addNewContactAction() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let OutletStockVC = storyboard.instantiateViewController(withIdentifier: "AddNewContactVC") as? AddNewContactVC {
            OutletStockVC.accountId = accountId
            OutletStockVC.onContactSaved = { [weak self] in
                self?.setInitialUI()
            }
            navigationController?.pushViewController(OutletStockVC, animated: true)
        }
    }
    
    @IBAction func proceedAction() {
        if contact.count == 0 {
            let alert = UIAlertController(title: "Not found", message: "Please add or meet a contact person for further process.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.addNewContactAction()
            }))
            self.present(alert, animated: true, completion: nil)
        } else if selectedCells.isEmpty {
            let alert = UIAlertController(title: "No Contact Selected", message: "Please check at least one Meet Person.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            var contact = [Contact]()
            var localIds = [Int]()
            contacts = contactsTable.getContactsWhereIsWorkingOutletsOne()
            for cont in contact {
                localIds.append(cont.localId ?? Int())
            }
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            if let outletStockVC = storyboard.instantiateViewController(withIdentifier: "OutletStockVC") as? OutletStockVC {
                outletStockVC.accountId = accountId
                outletStockVC.localId = localIds
                navigationController?.pushViewController(outletStockVC, animated: true)
            }
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func checkBtnAction(_ sender: UIButton) {
        let row = sender.tag
        if selectedCells.contains(row) {
            selectedCells.remove(row)
        } else {
            selectedCells.insert(row) 
        }
        TableVw?.reloadData()
    }
}

extension MeetGreetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MeetGreetCell = tableView.dequeueReusableCell(withIdentifier: "MeetGreetCell", for: indexPath) as! MeetGreetCell
        contact = contactsTable.getContactsOnTheBasisOfAccountIds(forAccountId: accountId)
        let contactData = contact[indexPath.row]
        if !contact.isEmpty {
            cell.courtesyLbl?.text = contactData.salutation
            cell.firstLbl?.text = "\(contactData.firstName ?? "") \(contactData.lastName ?? "")"
            cell.designationLbl?.text = contactData.title
        }
        if selectedCells.contains(indexPath.row) || contactData.workingWithOutlet == 1 {
            selectedCells.insert(indexPath.row)
            cell.checkBtn?.setImage(UIImage(named: "checkBox"), for: .normal)
        } else {
            cell.checkBtn?.setImage(UIImage(named: "uncheck"), for: .normal)
        }
        cell.checkBtn?.tag = indexPath.row
        cell.checkBtn?.addTarget(self, action: #selector(checkBtnAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let selectedContact = contact[indexPath.row]
        visitsTable.updateContactDetails(accountId: accountId, contactPersonName: selectedContact.name ?? "", contactPhoneNumber: selectedContact.phone ?? "") { success, error in
            if success {
                
            }
        }
        if selectedCells.contains(indexPath.row) {
            selectedCells.remove(indexPath.row)
            contacts = contactsTable.getContactsWhereIsWorkingOutletsOne()
            for cont in contacts {
                localIds.append(cont.localId ?? Int())
            }
            if !localIds.isEmpty {
                contactsTable.updateWorkingWithOutleForMultipleIds(localIds: localIds)
            }
            TableVw?.reloadData()
        } else {
            selectedCells.insert(indexPath.row)
            TableVw?.reloadData()
        }
        
    }
}

class MeetGreetCell: UITableViewCell {
    @IBOutlet var courtesyLbl: UILabel?
    @IBOutlet var firstLbl: UILabel?
    @IBOutlet var lastLbl: UILabel?
    @IBOutlet var designationLbl: UILabel?
    @IBOutlet var checkBtn: UIButton?
    @IBOutlet var editBtn: UIButton?
    @IBOutlet var vw: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        vw?.dropShadow()
    }
}

