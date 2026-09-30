//
//  PromotionRecomVC.swift
//  FRATELLI
//
//  Created by Sakshi on 27/11/24.
//

import UIKit
import SDWebImage

class PromotionRecomVC: UIViewController {
    @IBOutlet var recommendationButton: UIButton?
    @IBOutlet var promotionButton: UIButton?
    @IBOutlet var nextBtn: UIButton?
    @IBOutlet var previousBtn: UIButton?
    @IBOutlet var topView: UIView?
    @IBOutlet var noDataView: UIView?
    @IBOutlet weak var tableVw: UITableView?
    @IBOutlet var errLbl: UILabel?
    var promotionsTable = PromotionsTable()
    var recommendationsTable = RecommendationsTable()
    var promotion = [Promotion]()
    var recommendation = [Recommendation]()
    var accountId = ""
    var isRecommendation: Bool = true {
        didSet {
            if isRecommendation {
                recommendationButton?.backgroundColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
                promotionButton?.backgroundColor = nil
                promotionButton?.borderWidth = 1
                promotionButton?.borderColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
                recommendationButton?.setTitleColor(.white, for: .normal)
                promotionButton?.setTitleColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            } else {
                promotionButton?.backgroundColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
                recommendationButton?.backgroundColor = nil
                recommendationButton?.borderWidth = 1
                recommendationButton?.borderColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
                promotionButton?.setTitleColor(.white, for: .normal)
                recommendationButton?.setTitleColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIIntialUI()
    }
    
    func setUIIntialUI() {
        topView?.dropShadow()
        nextBtn?.roundCornersOnRight(radius: 9)
        previousBtn?.roundCornersOnLeft(radius: 9)
        tableVw?.showsVerticalScrollIndicator = false
        tableVw?.showsHorizontalScrollIndicator = false
        recommendationButton?.backgroundColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        promotionButton?.backgroundColor = nil
        promotionButton?.borderWidth = 1
        promotionButton?.borderColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        recommendationButton?.setTitleColor(.white, for: .normal)
        promotionButton?.setTitleColor(UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0), for: .normal)
        recommendationButton?.layer.cornerRadius = 8.0
        recommendationButton?.layer.masksToBounds = true
        promotionButton?.layer.cornerRadius = 8.0
        promotionButton?.layer.masksToBounds = true
        promotion = promotionsTable.getPromotions()
        recommendation = recommendationsTable.getRecommendations()
        if recommendation.isEmpty {
            noDataView?.isHidden = false
        } else {
            noDataView?.isHidden = true
        }
    }
    
    @IBAction func recommendationAction(_ sender: UIButton) {
        if sender.tag == 1 {
            if recommendation.isEmpty {
                noDataView?.isHidden = false
                errLbl?.text = "No, recommendations right now"
            } else {
                noDataView?.isHidden = true
                isRecommendation = true
                tableVw?.reloadData()
                errLbl?.text = ""
            }
        } else {
            if promotion.isEmpty {
                noDataView?.isHidden = false
                errLbl?.text = "No, promotions right now"
            } else {
                noDataView?.isHidden = true
                errLbl?.text = ""
                isRecommendation = false
                tableVw?.reloadData()
            }
        }
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let outletSalesOrderVC = storyboard.instantiateViewController(withIdentifier: "OutletSalesOrderVC") as? OutletSalesOrderVC {
            outletSalesOrderVC.accountId = accountId
            navigationController?.pushViewController(outletSalesOrderVC, animated: true)
        }
    }
    
    @IBAction func PrevioustBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PromotionRecomVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRecommendation {
            return recommendation.count
        } else {
            return promotion.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            if isRecommendation {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "EvenCell", for: indexPath) as? EvenCell else {
                    fatalError("EvenCell not found")
                }
                if let urlString = recommendation[indexPath.row].productName?.productImageLink,
                   let url = URL(string: urlString) {
                    cell.imageVw?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    cell.headingLbl?.text = recommendation[indexPath.row].productName?.name
                    cell.descriptionLbl?.text = recommendation[indexPath.row].productDescription
                    
                } else {
                    cell.imageVw?.image = UIImage(named: "placeholder")
                }
                cell.descriptionVw?.dropShadow()
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "OddCell", for: indexPath) as? OddCell else {
                    fatalError("OddCell not found")
                }
                if let urlString = promotion[indexPath.row].productName?.productImageLink,
                   let url = URL(string: urlString) {
                    cell.imageVw?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    cell.headingLbl?.text = promotion[indexPath.row].productName?.name
                    cell.descriptionLbl?.text = promotion[indexPath.row].productDescription
                } else {
                    cell.imageVw?.image = UIImage(named: "placeholder")
                }
                cell.descriptionVw?.dropShadow()
                return cell
            }
        } else {
            if isRecommendation {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "OddCell", for: indexPath) as? OddCell else {
                    fatalError("OddCell not found")
                }
                if let urlString = recommendation[indexPath.row].productName?.productImageLink,
                   let url = URL(string: urlString) {
                    cell.imageVw?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    cell.headingLbl?.text = recommendation[indexPath.row].productName?.name
                    cell.descriptionLbl?.text = recommendation[indexPath.row].productDescription
                } else {
                    cell.imageVw?.image = UIImage(named: "placeholder")
                }
                cell.descriptionVw?.dropShadow()
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "EvenCell", for: indexPath) as? EvenCell else {
                    fatalError("EvenCell not found")
                }
                if let urlString = promotion[indexPath.row].productName?.productImageLink,
                   let url = URL(string: urlString) {
                    cell.imageVw?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    cell.headingLbl?.text = promotion[indexPath.row].productName?.name
                    cell.descriptionLbl?.text = promotion[indexPath.row].productDescription
                } else {
                    cell.imageVw?.image = UIImage(named: "placeholder")
                }
                cell.descriptionVw?.dropShadow()
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var imageUrl: String = ""
        var name: String = ""
        var description: String = ""
        if isRecommendation {
            if let urlString = recommendation[indexPath.row].productName?.productImageLink,
               let url = URL(string: urlString) {
                imageUrl = "\(url)"
            }
            name = recommendation[indexPath.row].productName?.name ?? ""
            description = recommendation[indexPath.row].productDescription
        } else {
            if let imageLink = promotion[indexPath.row].productName?.productImageLink {
                imageUrl = imageLink
            }
            name = promotion[indexPath.row].productName?.name ?? ""
            description = promotion[indexPath.row].productDescription
        }
        print("Passing image: \(imageUrl)")
        print("Passing name: \(name)")
        print("Passing subName: \(description)")
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagePopUpVc") as? ImagePopUpVc
                vc?.image = imageUrl
        vc?.name = name
        vc?.subName = description
        vc?.modalPresentationStyle = .overFullScreen
        vc?.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
//        print("Passing image: \(imageUrl)")
//        print("Passing name: \(name)")
//        print("Passing subName: \(description)")
        self.present(vc ?? UIViewController(), animated: false, completion: nil)
    }
}

class EvenCell: UITableViewCell {
    @IBOutlet var imageVw: UIImageView?
    @IBOutlet var descriptionVw: UIView?
    @IBOutlet var headingLbl: UILabel?
    @IBOutlet var descriptionLbl: UILabel?
}

class OddCell: UITableViewCell {
    @IBOutlet var imageVw: UIImageView?
    @IBOutlet var descriptionVw: UIView?
    @IBOutlet var headingLbl: UILabel?
    @IBOutlet var descriptionLbl: UILabel?
}
