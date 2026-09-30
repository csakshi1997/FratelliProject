//
//  TabbarView.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit
import SideMenu

class TabbarView: UIViewController {
    @IBOutlet var selectedTabOne: UIImageView?
    @IBOutlet var selectedTabTwo: UIImageView?
    @IBOutlet var selectedTabThree: UIImageView?
    @IBOutlet var selectedTabFour: UIImageView?
    @IBOutlet var fourBtnViewView: UIView?
    @IBOutlet var headerView: UIView?
    @IBOutlet var bottomView: UIView?
    @IBOutlet var headingLbl: UILabel?
    var homeView: UIViewController?
    var contact: UIViewController?
    var visits: UIViewController?
    var orders: UIViewController?
    var posm: UIViewController?
    @IBOutlet var addButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        gotoHomeAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("MyNotification"), object: nil)
    }
    
    @objc func handleNotification() {
        SceneDelegate.getSceneDelegate().window?.makeToast(TASKSUCCESSFULLY_SYNCED)
    }
        
    func gotoVisitsView() {
        removeAllChildViews()
        selectedTabOne?.isHidden = false
        headingLbl?.text = "Visits"
        let storyBoard : UIStoryboard = UIStoryboard(name: "Visits", bundle:nil)
        visits = storyBoard.instantiateViewController(withIdentifier: "VisitsVC") as? VisitsVC ?? VisitsVC()
        self.add(visits ?? VisitsVC(), frame: self.view.bounds)
        self.view.bringSubviewToFront(bottomView ?? UIView())
        self.view.bringSubviewToFront(headerView ?? UIView())
    }
    
    func gotoOrderView() {
        removeAllChildViews()
        selectedTabTwo?.isHidden = false
        headingLbl?.text = "Orders"
        let storyBoard : UIStoryboard = UIStoryboard(name: "Orders", bundle:nil)
        orders = storyBoard.instantiateViewController(withIdentifier: "OrdersVC") as? OrdersVC ?? OrdersVC()
        self.add(orders ?? OrdersVC(), frame: self.view.bounds)
        self.view.bringSubviewToFront(bottomView ?? UIView())
        self.view.bringSubviewToFront(headerView ?? UIView())
    }
    
    func gotoContactsView() {
        removeAllChildViews()
        selectedTabThree?.isHidden = false
        headingLbl?.text = "Contacts"
        let storyBoard : UIStoryboard = UIStoryboard(name: "Contact", bundle:nil)
        contact = storyBoard.instantiateViewController(withIdentifier: "ContactVC") as? ContactVC ?? ContactVC()
        self.add(contact ?? ContactVC(), frame: self.view.bounds)
        self.view.bringSubviewToFront(bottomView ?? UIView())
        self.view.bringSubviewToFront(headerView ?? UIView())
    }
    
    @IBAction func menuAction() {
        let storyboardBundle = Bundle.main
        let storyboard = UIStoryboard(name: "Home", bundle: storyboardBundle)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "SideBarViewController") as! SideBarViewController
        let menu = SideMenuNavigationController(rootViewController: dashboardVC)
        menu.leftSide = true
        menu.presentationStyle = .menuSlideIn
        let bounds = UIScreen.main.bounds
        menu.menuWidth = bounds.width/1.5
        dashboardVC.completionHandler = { textState in
            self.view.makeToast("Please check your internet connection")
        }
        present(menu, animated: true, completion: nil)
    }
        
    @IBAction func gotoHomeAction() {
        removeAllChildViews()
//        selectedTabOne?.isHidden = false
        headingLbl?.text = "Today's Visits"
        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
        homeView = storyBoard.instantiateViewController(withIdentifier: "HomeView") as? HomeView ?? HomeView()
        self.add(homeView ?? HomeView(), frame: self.view.bounds)
        self.view.bringSubviewToFront(bottomView ?? UIView())
        self.view.bringSubviewToFront(headerView ?? UIView())
    }
    
//    private func bringHeaderAndTabBarToFront() {
//        // Bring headerView to the front if it exists
//        if let headerView = headerView {
//            self.view.bringSubviewToFront(headerView)
//        }
//        
//        // Bring tab bar to the front to be on top of the header
//        if let tabBar = tabBar {
//            self.view.bringSubviewToFront(tabBar)
//        }
//    }
            
    func gotoposmAction() {
        removeAllChildViews()
        selectedTabFour?.isHidden = false
        headingLbl?.text = "POSM"
        let storyBoard : UIStoryboard = UIStoryboard(name: "POSM", bundle:nil)
        posm = storyBoard.instantiateViewController(withIdentifier: "POSMVC") as? POSMVC ?? POSMVC()
        self.add(posm ?? POSMVC(), frame: self.view.bounds)
        self.view.bringSubviewToFront(bottomView ?? UIView())
        self.view.bringSubviewToFront(headerView ?? UIView())
    }
    
    func removeAllChildViews() {
        selectedTabOne?.isHidden = true
        selectedTabTwo?.isHidden = true
        selectedTabThree?.isHidden = true
        selectedTabFour?.isHidden = true
        homeView?.remove()
        contact?.remove()
        visits?.remove()
        orders?.remove()
    }
    
    @IBAction func tabSelection(button: UIButton?) {
        if button?.tag ?? 0 == 0 {
            gotoVisitsView()
        } else if button?.tag ?? 0 == 1 {
            gotoOrderView()
        } else if button?.tag ?? 0 == 2 {
            gotoContactsView()
        } else if button?.tag ?? 0 == 3 {
            gotoposmAction()
        }
    }
}


