//
//  SchemeTypeView.swift
//  FRATELLI
//
//  Created by Sakshi on 29/11/24.
//

import UIKit

class SchemeTypeView: UIViewController {
    @IBOutlet var TblVw : UITableView?
    @IBOutlet var backgroundBtn: UIButton?
    @IBOutlet var schemeContainerView: UIView?
    var schemeArray = ["Scheme with VAT/ED", "Scheme without VAT/ED", "Scheme on MRP", "Free Issue with VAT/ED", "Free Issue without VAT/ED", "Flat Amount Scheme", "Zero Scheme"]
    var origin: CGPoint?
    var completionHandler: (String) -> Void = { _ in}

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        TblVw?.dataSource = self
        TblVw?.delegate = self
        TblVw?.allowsSelection = true
        TblVw?.showsVerticalScrollIndicator = false
        TblVw?.showsHorizontalScrollIndicator = false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backgroundBtnAction() {
        self.dismiss(animated: false)
    }
}

class SchemeCell : UITableViewCell {
    @IBOutlet var schemeNameLbl : UILabel?
    @IBOutlet var schemeImageBtn : UIButton?
    @IBOutlet var vw : UIView?
    var isSchemeSelected: Bool = false {
        didSet {
            if isSchemeSelected {
                schemeImageBtn?.setImage(UIImage(named: ""), for: .normal)
            } else {
                schemeImageBtn?.setImage(UIImage(named: ""), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.dropShadow()
    }

}

extension SchemeTypeView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schemeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchemeCell", for: indexPath) as! SchemeCell
        cell.schemeNameLbl?.text = schemeArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.completionHandler(schemeArray[indexPath.row])
        self.dismiss(animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

