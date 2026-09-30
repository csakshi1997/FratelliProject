//
//  Utility.swift
//  FRATELLI
//
//  Created by Sakshi on 21/10/24.
//

import UIKit
import AVFoundation

class Utility {
    static var tabbarView: TabbarView?
    static var isMenuOpen : Bool = false
    static var isFromHome : Bool = false
    static var fromOtherScreen : Bool = false
    static var button = UIButton()
    static var containerController : UIViewController?
    static var presentController : UIViewController?
    
    func getActualValue(key : String, dict : [String : Any]) -> String {
        if dict[key] is String {
            return dict[key] as! String
        } else if dict[key] is Int {
            return String(dict[key] as! Int)
        } else if dict[key] is Float {
            return String(format: "%.2f", dict[key] as! Float)
        } else if dict[key] is Double {
            return String(format: "%.2f", dict[key] as! Double)
        } else if dict[key] is Bool {
            return String(dict[key] as! Bool)
        } else {
            return EMPTY
        }
    }
    
    static func getConvertedPoint(_ targetView: UIView, baseView: UIView?) -> CGPoint {
        var pnt = targetView.frame.origin
        if nil == targetView.superview {
            return pnt
        }
        var superView = targetView.superview
        while superView != baseView {
            pnt = superView!.convert(pnt, to: superView!.superview)
            if nil == superView!.superview {
                break
            } else {
                superView = superView!.superview
            }
        }
        return superView!.convert(pnt, to: baseView)
    }
    
    static func gotoTabbar() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Tabbar", bundle:nil)
        tabbarView = storyBoard.instantiateViewController(withIdentifier: "TabbarView") as? TabbarView
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: tabbarView ?? TabbarView())
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }
    
    static func gotoSyncVc(isFromSideMenu: Bool) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "SyncVC") as! SyncVC
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: viewController)
        if isFromSideMenu {
            viewController.isSideMenu = true
        } else {
            viewController.isSideMenu = false
        }
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }
    
    static func gotoLoginView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: viewController)
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }
    
    static func showAlertForSyncDown() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let rootViewController = scene.windows.first?.rootViewController
            let checkInAlert = UIAlertController(
                title: "Synced Up!",
                message: "Hey, Your data has been synced to the Server for Today. Now sync down your visits for the next day.",
                preferredStyle: .alert
            )
            rootViewController?.present(checkInAlert, animated: true, completion: nil)
            checkInAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                Defaults.isSyncUpComplete = true
                Defaults.isStartDay = false
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.stopLocationTracking()
                    Defaults.isTrackingStart = false
                }
                Utility.gotoTabbar()
            }))
        }
    }
    
    static func showAlertForTokenExpired() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let rootViewController = scene.windows.first?.rootViewController
            let checkInAlert = UIAlertController(
                title: "Alert!",
                message: "Hey, You have already spent more time, now your Token is expired. please login again and fetch updated data.",
                preferredStyle: .alert
            )
            rootViewController?.present(checkInAlert, animated: true, completion: nil)
            checkInAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                Utility.logoutAction(isRedirectedToLogin: true)
            }))
        }
    }
    
    static func tokenExpiredAction() {
        SceneDelegate.getSceneDelegate().window?.makeToast(SESSION_EXPIRED)
        self.logoutAction()
    }
    
    static func logoutAction(isRedirectedToLogin: Bool = true) {
        Defaults.userId = ""
        Defaults.isUserLoggedIn = false
        Defaults.isSyncUpProcessCompleted = false
        Database.deleteTable(tableName: "ContactsTable")
        Database.deleteTable(tableName: "OutletsTable")
        Database.deleteTable(tableName: "VisitsTable")
        Database.deleteTable(tableName: "ProductsTable")
        Database.deleteTable(tableName: "RecommendationsTable")
        Database.deleteTable(tableName: "AdvocacyTable")
        Database.deleteTable(tableName: "PromotionsTable")
        Database.deleteTable(tableName: "OnTradeTable")
        Database.deleteTable(tableName: "RiskStockTable")
        Database.deleteTable(tableName: "RiskStockLineItemsTable")
        Database.deleteTable(tableName: "OnAssetsTable")
        Database.deleteTable(tableName: "SalesOrderTable")
        Database.deleteTable(tableName: "SalesOrderLineItemsTable")
        Database.deleteTable(tableName: "RQCRTable")
        Database.deleteTable(tableName: "POSMTable")
        Database.deleteTable(tableName: "POSMLineItemsTable")
        Database.deleteTable(tableName: "AllVisibilityTable")
        Database.deleteTable(tableName: "HomePOSMTable")
        Database.deleteTable(tableName: "HomePOSMLineItemTable")
        Database.deleteTable(tableName: "HomeAssetTable")
        Database.deleteTable(tableName: "CallForHelpTable")
        Database.deleteTable(tableName: "AddNewTaskTable")
        Database.deleteTable(tableName: "POSMRequisitionTable")
        Database.deleteTable(tableName: "AssetRequisitionTable")
        Database.deleteTable(tableName: "SkipTable")
        Database.deleteTable(tableName: "DistributorAccountsTable")
        Defaults.isTrackingStart = false
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.stopLocationTracking()
            appDelegate.monitor.cancel()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        if isRedirectedToLogin {
            Defaults.isAuthenticationfailedAtTheTimeOfSync = false
            self.gotoLoginView()
        }
    }
    
    static func logoutWithoutDatabaseAffection(sessionTimeOutAtTheTimeOfSync: Bool) {
        if sessionTimeOutAtTheTimeOfSync {
            Defaults.isTrackingStart = false
            Defaults.isAuthenticationfailedAtTheTimeOfSync = true
            self.gotoLoginView()
        }
    }
    
    static func getUniqueName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSSS"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
    static func getStatus(responseCode: Int) -> ResponseStatus {
        switch responseCode {
        case 200, 201, 203, 204:
            return ResponseStatus.success
        case 409:
            return ResponseStatus.alreadyRegister
        case 500:
            return ResponseStatus.error
        case 401:
            return ResponseStatus.tokenExpired
        case 400:
            return ResponseStatus.badRequest
        default:
            return ResponseStatus.error
        }
    }
    
    static func setRightViewController(containerController: UIViewController, childViewController : UIViewController, isAnimated : Bool, fromOtherSCreen : Bool = false ) {
        self.fromOtherScreen = fromOtherSCreen
        presentController = childViewController
        removeAllChildController(containerController: containerController)
        let navigationController = UINavigationController(rootViewController: childViewController)
        navigationController.isNavigationBarHidden = true
        containerController.addChild(navigationController)
        containerController.view.addSubview(navigationController.view)
        navigationController.view.dropShadow(color: UIColor.black, opacity: 1.0, offSet: CGSize(width: -1, height: 1), radius:0.0, scale: true)
        navigationController.didMove(toParent: containerController)
        isMenuOpen = false
        if isAnimated {
            navigationController.view.frame.origin.x = getSideMenuWidth()
            UIView.animate(withDuration: 0.2, animations: {
                navigationController.view.frame.origin.x = 0
            })
        }
    }
    
    static func removeAllChildController(containerController: UIViewController) {
        for(_, controller) in containerController.children.enumerated() {
            controller.removeFromParent()
            controller.view.removeFromSuperview()
        }
    }
    
    static var overlayView: UIView?
    static var sideBarVC: SideBarViewController?

    static func gotoSideMenu(containerController: UIViewController, isFromHome: Bool = false) {
        fromOtherScreen = false
        self.containerController = containerController
        self.isFromHome = isFromHome
        if isMenuOpen && !isFromHome {
            UIView.animate(withDuration: 0.3, animations: {
                sideBarVC?.view.frame.origin.x = -getSideMenuWidth()
                overlayView?.alpha = 0
            }) { _ in
                sideBarVC?.view.removeFromSuperview()
                sideBarVC?.removeFromParent()
                overlayView?.removeFromSuperview()
                overlayView = nil
                self.isMenuOpen = false
            }
        } else {
            overlayView = UIView(frame: containerController.view.bounds)
            overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            overlayView?.alpha = 0
            containerController.view.addSubview(overlayView!)
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let sideMenu = storyboard.instantiateViewController(withIdentifier: "SideBarViewController") as? SideBarViewController else {
                print("Failed to load SideBarViewController")
                return
            }
            self.sideBarVC = sideMenu
            sideMenu.view.frame = CGRect(x: -getSideMenuWidth(), y: 35, width: getSideMenuWidth(), height: containerController.view.frame.height)
            containerController.addChild(sideMenu)
            containerController.view.addSubview(sideMenu.view)
            sideMenu.didMove(toParent: containerController)
            UIView.animate(withDuration: 0.3, animations: {
                sideMenu.view.frame.origin.x = 0
                overlayView?.alpha = 1
            })
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSideMenu))
            overlayView?.addGestureRecognizer(tapGesture)

            self.isMenuOpen = true
        }
    }

    @objc static func dismissSideMenu() {
        if !fromOtherScreen {
            guard containerController != nil else { return }
            
            UIView.animate(withDuration: 0.3, animations: {
                sideBarVC?.view.frame.origin.x = -getSideMenuWidth()
                overlayView?.alpha = 0
            }) { _ in
                sideBarVC?.view.removeFromSuperview()
                sideBarVC?.removeFromParent()
                overlayView?.removeFromSuperview()
                overlayView = nil
                self.isMenuOpen = false
            }
        }
    }

    static func getSideMenuWidth() -> CGFloat {
        return 250.0
    }

    
}
