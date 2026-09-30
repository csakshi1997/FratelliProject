//
//  TodayVisitCell.swift
//  FRATELLI
//
//  Created by Sakshi on 21/11/24.
//

import Foundation
import UIKit

protocol TodayVisitCellDelegate: AnyObject {
    func didTapCheckInButton(in cell: TodayVisitCell)
    func didLocationBtntapped(in cell: TodayVisitCell)
}

class TodayVisitCell: UITableViewCell {
    @IBOutlet var channelLbl: UILabel?
    @IBOutlet var segmentationLbl: UILabel?
    @IBOutlet var OmniChannelLbl: UILabel?
    @IBOutlet var checkInBtn: UIButton?
    @IBOutlet var getDirectionBtn: UIButton?
    @IBOutlet var upprlBl: UILabel?
    @IBOutlet var radioBtn: UIButton?
    @IBOutlet var vw: UIView?
    weak var delegate: TodayVisitCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw?.layer.cornerRadius = 10.0
        vw?.layer.masksToBounds = true
        checkInBtn?.layer.cornerRadius = 8.0
        checkInBtn?.layer.masksToBounds = true
        if let vw = vw {
            vw.layer.shadowColor = UIColor.black.cgColor
            vw.layer.shadowOpacity = 0.3
            vw.layer.shadowOffset = CGSize(width: 0, height: 4)
            vw.layer.shadowRadius = 4
            let shadowRect = CGRect(x: 0, y: vw.bounds.height - 4, width: vw.bounds.width, height: 4)
            vw.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        }
    }
    
    @IBAction func checkInButtonTapped(_ sender: UIButton) {
        delegate?.didTapCheckInButton(in: self)
    }
    
    @IBAction func getLocationButtonTapped(_ sender: UIButton) {
        delegate?.didLocationBtntapped(in: self)
    }
}

