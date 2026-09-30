//
//  SyncInVC.swift
//  FRATELLI
//
//  Created by Sakshi on 23/12/24.
//

import UIKit
import Alamofire

class SyncInVC: UIViewController {
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    @IBOutlet var imageView5: UIImageView!
    @IBOutlet var imageView6: UIImageView!
    @IBOutlet var imageView7: UIImageView!
    @IBOutlet var imageView8: UIImageView!
    @IBOutlet var imageView9: UIImageView!
    var syncDownOperations = SyncDownOperations()
    var loaderLayers: [CAShapeLayer] = []
    let dispatchGroup = DispatchGroup()
    var completionhandler: (String) -> Void = {_ in }
    let reachabilityManager = NetworkReachabilityManager()
    var customDateFormatter = CustomDateFormatter()
    var appVersionOperation = AppVersionOperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageViews = [imageView1, imageView2, imageView3, imageView4, imageView5, imageView6, imageView7, imageView8, imageView9]
        for imageView in imageViews {
            if let imageView = imageView {
                addCircularLoader(to: imageView)
            }
        }
    }
    
    func addCircularLoader(to imageView: UIImageView) {
        let imageCenter = imageView.convert(imageView.bounds.center, to: view)
        let circularPath = UIBezierPath(arcCenter: imageCenter, radius: imageView.frame.width / 2 , startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        let loaderLayer = CAShapeLayer()
        loaderLayer.path = circularPath.cgPath
        loaderLayer.strokeColor = CGColor(
            red: 68 / 255.0,
            green: 140.0 / 255.0,
            blue: 238.0 / 255.0,
            alpha: 1.0
        )
        loaderLayer.fillColor = UIColor.clear.cgColor
        loaderLayer.lineWidth = 5.0
        loaderLayer.strokeEnd = 0.0
        view.layer.addSublayer(loaderLayer)
        loaderLayers.append(loaderLayer)
    }
    
    func startCircularLoaderAnimation(loaderLayer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1.0
        animation.duration = 2.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        loaderLayer.add(animation, forKey: "circularLoader")
    }
    
//    @IBAction func buttonClicked(_ sender: UIButton) {
//        if !reachabilityManager!.isReachable {
//            self.view.makeToast(INTERNET_NOT_AVAILABLE_STR)
//            return
//        }
//        for loaderLayer in loaderLayers {
//            startCircularLoaderAnimation(loaderLayer: loaderLayer)
//        }
//        syncDownOperations.syncInDataForAccount()
//        syncDownOperations.completionhandler = { updateTable in
//            SceneDelegate.getSceneDelegate().window?.makeToast(TASKSUCCESSFULLY_SYNCED)
//        }
//    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        guard let reachabilityManager = reachabilityManager, reachabilityManager.isReachable else {
            self.view.makeToast(INTERNET_NOT_AVAILABLE_STR)
            sender.isEnabled = true
            return
        }
        for loaderLayer in loaderLayers {
            startCircularLoaderAnimation(loaderLayer: loaderLayer)
        }
        syncDownOperations.syncInDataForAccount()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("MyNotification"), object: sender)
//        sender.isEnabled = true
//        syncDownOperations.completionhandler = { updateTable in
//            DispatchQueue.main.async {
//                SceneDelegate.getSceneDelegate().window?.makeToast(TASKSUCCESSFULLY_SYNCED)
//                sender.isEnabled = true
//                self.sendObjects()
//                
//            }
//        }
    }
    
    @objc func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            SceneDelegate.getSceneDelegate().window?.makeToast(TASKSUCCESSFULLY_SYNCED)
            if let button = notification.object as? UIButton {
                button.isEnabled = true
            }
            self.sendObjects()
        }
    }
    
    func sendObjects() {
        let authOperation = AuthOperation()
        let userData = [
            "Sync_Type__c": "Sync Up",
            "Sync_Date_Time__c": customDateFormatter.getFormattedDateForAccount(),
            "Login_User__c": Defaults.userId ?? "",
            "Device_Id__c": DeviceId,
            "Device_Type__c": "iOS",
            "Device_Name__c": UIDevice.current.name,
            "New_Outlet_Count__c": 0,
            "Photo_Upload_Count__c": 0,
            "Visit_Count__c": 0,
            "Device_Version__c": appVersionOperation.getCurrentAppVersion() ?? "",
            "attributes": [
                "referenceId": "ref1",
                "type": "Application_Sync_Configurer__c"
            ]
        ] as [String : Any]
        var userDataDict: [String : Any] = [:]
        userDataDict = ["records": [userData]]
        print(userDataDict)
        authOperation.sendSobjects(details: userDataDict) { error , resposne, statusCode in
            if statusCode == .success {
                Defaults.isSyncUpProcessCompleted = true
                Defaults.isSyncUpComplete = false
                Utility.gotoTabbar()
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
