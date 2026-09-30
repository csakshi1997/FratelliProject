//
//  ActionItemPopUp.swift
//  FRATELLI
//
//  Created by Sakshi on 27/12/24.
//

import UIKit

class ActionItemPopUp: UIViewController {
    @IBOutlet var TblVw : UITableView?
    @IBOutlet var backgroundBtn: UIButton?
    @IBOutlet var schemeContainerView: UIView?
    @IBOutlet var noDataVw: UIView?
    @IBOutlet var headerView: UIView?
    var schemeArray = ["Scheme with VAT/ED", "Scheme without VAT/ED", "Scheme on MRP", "Free Issue with VAT/ED", "Free Issue without VAT/ED", "Flat Amount Scheme", "Zero Scheme"]
    var origin: CGPoint?
    var completionHandler: (String) -> Void = { _ in}
    var addNewTaskTable = AddNewTaskTable()
    var addNewTaskModel = [AddNewTaskModel]()
    var completionHandlerr: (() -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        TblVw?.dataSource = self
        TblVw?.delegate = self
        TblVw?.allowsSelection = true
        TblVw?.showsVerticalScrollIndicator = false
        TblVw?.showsHorizontalScrollIndicator = false
        schemeContainerView?.layer.cornerRadius  = 8
        schemeContainerView?.layer.masksToBounds = true
        headerView?.layer.cornerRadius = 8
        headerView?.layer.masksToBounds = true
        headerView?.borderWidth = 1
        headerView?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNewTaskModel = addNewTaskTable.getTasksAccordingToWhatId(forWhatId: currentVisitId)
        if addNewTaskModel.isEmpty {
            noDataVw?.isHidden = false
            headerView?.isHidden = true
        } else {
            headerView?.isHidden = false
            noDataVw?.isHidden = true
            TblVw?.reloadData()
        }
    }
    
    @IBAction func backgroundBtnAction() {
        self.dismiss(animated: false)
    }
    
    @IBAction func addNewAction() {
        self.dismiss(animated: false) {
            self.completionHandlerr?()

        }
    }
}

class ActionItemPopUpCell : UITableViewCell {
    @IBOutlet var actionTypeNameLbl : UILabel?
    @IBOutlet var settlementDateLbl : UILabel?
    @IBOutlet var statusBtn : UIButton?
    @IBOutlet var vw : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
    }

}

extension ActionItemPopUp : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addNewTaskModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionItemPopUpCell", for: indexPath) as! ActionItemPopUpCell
        cell.settlementDateLbl?.text = addNewTaskModel[indexPath.row].Settlement_Data__c
        cell.actionTypeNameLbl?.text = addNewTaskModel[indexPath.row].TaskSubject
        if addNewTaskModel[indexPath.row].TaskStatus == "Open" {
            cell.statusBtn?.setImage(UIImage(named: "uncheck"), for: .normal)
        } else {
            cell.statusBtn?.setImage(UIImage(named: "done"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.completionHandler(schemeArray[indexPath.row])
        self.dismiss(animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


