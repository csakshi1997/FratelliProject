//
//  CansVc.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import UIKit

class CansVc: UIViewController {
    @IBOutlet var flagPopUpTblVw : UITableView?
    @IBOutlet var backgroundBtn: UIButton?
    @IBOutlet var cansContainerView: UIView?
    @IBOutlet var headingLbl: UILabel?
    var contentArray = ["Can leakages","Can shrink","Can punctured","Dent on cans","Can corrosion","Damaged cans", "Can Breakages", "Off Taste", "Particles in Wine", "Foreign Particles in Can", "Less fizz/Co2 gas", "Coding missing", "Wrong coding mandatory", "Coding foint size issue", "Blurr Coding", "Low fill", "Damaged Cartons", "Wrong brand Cartoons", "Missing Partition", "Transit Breakages"]
    var contentArray2 = ["Foreign Particles in Bottle","Tarter sedimentation","Black particle sedimentation","White Particles sedimentation","Turbid wine","Haziness in wine/Sparkling wine", "Less fizz/Co2 gas", "Color variation in wine", "Damaged Caps", "Damaged Corps", "Damaged Bottles", "Bottle/Wine Leakage", "Label Damaged/torned", "Label misaligment", "Wrinkles on label", "Damaged Cartons", "Missing partition", "Label missing on cartons", "Transit Breakages", "Pet Bottle Shrinkage", "Fungal growth on bottles", "Coding missing", "Wrong coding mandatory", "Coding foint size issue", "Blurr Coding", "Low fill"]
    var origin: CGPoint?
    var isCan: Bool = true
    var completionHandler: (String) -> Void = { _ in}

    override func viewDidLoad() {
        super.viewDidLoad()
        flagPopUpTblVw?.dataSource = self
        flagPopUpTblVw?.delegate = self
        flagPopUpTblVw?.allowsSelection = true
        flagPopUpTblVw?.showsVerticalScrollIndicator = false
        flagPopUpTblVw?.showsHorizontalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isCan {
            headingLbl?.text = "Select CAN"
        } else if !isCan {
            headingLbl?.text = "Select Bottle"
        }
    }
    
    @IBAction func backgroundBtnAction() {
        self.dismiss(animated: false)
    }
}

class CansCell : UITableViewCell {
    @IBOutlet var flagNameLbl : UILabel?
}

extension CansVc : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCan {
            return contentArray.count
        } else {
            return contentArray2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CansCell", for: indexPath) as! CansCell
        if isCan {
            cell.flagNameLbl?.text = contentArray[indexPath.row]
        } else {
            cell.flagNameLbl?.text = contentArray2[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCan {
            self.completionHandler(contentArray[indexPath.row])
        } else {
            self.completionHandler(contentArray2[indexPath.row])
        }
        self.dismiss(animated: false)
    }
}

