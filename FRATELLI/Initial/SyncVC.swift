import UIKit
import Alamofire

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

class SyncVC: UIViewController {
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    @IBOutlet var imageView5: UIImageView!
    @IBOutlet var backBtn: UIButton?
    let reachabilityManager = NetworkReachabilityManager()
    var appVersionOperation = AppVersionOperation()
    var customDateFormatter = CustomDateFormatter()
    
    var loaderLayers: [CAShapeLayer] = []
    let dispatchGroup = DispatchGroup()
    var isSideMenu: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageViews = [imageView1, imageView2, imageView3, imageView4, imageView5]
        for imageView in imageViews {
            if let imageView = imageView {
                addCircularLoader(to: imageView)
            }
        }
        if isSideMenu {
            backBtn?.isHidden = false
        } else {
            backBtn?.isHidden = true
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
    //        let syncGroup = DispatchGroup()
    //
    //        for syncEnum in SyncEnum.allCases {
    //            syncGroup.enter()
    //            let syncOperation = SyncOperation()
    //            syncOperation.executeSync(syncType: syncEnum.getSyncText(), syncName: syncEnum.rawValue) { error, response, statusCode in
    //                if let error = error {
    //                    print("Error for \(syncEnum.rawValue): \(error)")
    //                }
    //
    //                syncGroup.leave()
    //            }
    //        }
    //
    //        syncGroup.notify(queue: .main) {
    //            print("All sync operations completed!")
    //            for loaderLayer in self.loaderLayers {
    //                print("Stop Loadder")
    //                Defaults.isSyncUpProcessCompleted = true
    //                Utility.gotoTabbar()
    //            }
    //        }
    //        print("Loop started")
    //    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        Utility.gotoTabbar()
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if isSideMenu {
            ifSideMenuTrueAction()
        } else {
            ifSideMenuFalseAction()
        }
    }
    
    func ifSideMenuFalseAction() {
        let syncGroup = DispatchGroup()
        if !reachabilityManager!.isReachable {
            self.view.makeToast(INTERNET_NOT_AVAILABLE_STR)
            return
        }
        for loaderLayer in loaderLayers {
            startCircularLoaderAnimation(loaderLayer: loaderLayer)
        }
        for syncEnum in SyncEnum.allCases {
            syncGroup.enter()
            let syncOperation = SyncOperation()
            
            syncOperation.executeSync(syncType: syncEnum.getSyncText(), syncName: syncEnum.rawValue) { error, response, statusCode in
                if let error = error {
                    print("Error for \(syncEnum.rawValue): \(error)")
                }
                syncGroup.leave()
            }
        }
        
        syncGroup.notify(queue: .main) {
            print("All sync operations completed!")
            self.sendObjects()
            for loaderLayer in self.loaderLayers {
                print("Stop Loader")
            }
//            Defaults.isSyncUpProcessCompleted = true
//            Defaults.isSyncUpComplete = false
//            Utility.gotoTabbar()
        }
        print("Loop started")
    }
    
    func ifSideMenuTrueAction() {
        if !reachabilityManager!.isReachable {
            self.view.makeToast(INTERNET_NOT_AVAILABLE_STR)
            return
        }
        let deletionGroup = DispatchGroup()
        if isSideMenu {
            Defaults.isSyncUpProcessCompleted = false
            let tables = [
                "ContactsTable", "OutletsTable", "VisitsTable", "ProductsTable",
                "RecommendationsTable", "AdvocacyTable", "PromotionsTable",
                "OnTradeTable", "RiskStockTable", "RiskStockLineItemsTable",
                "OnAssetsTable", "SalesOrderTable", "SalesOrderLineItemsTable",
                "RQCRTable", "POSMTable", "POSMLineItemsTable", "AllVisibilityTable",
                "HomePOSMTable", "HomePOSMLineItemTable", "HomeAssetTable",
                "CallForHelpTable", "AddNewTaskTable", "POSMRequisitionTable",
                "AssetRequisitionTableAssetRequisitionTableAssetRequisitionTableAssetRequisitionTable", "SkipTable", "DistributorAccountsTable"
            ]
            for table in tables {
                deletionGroup.enter()
                DispatchQueue.global(qos: .background).async {
                    Database.deleteTable(tableName: table)
                    deletionGroup.leave()
                }
            }
        }
        deletionGroup.notify(queue: .main) {
            print("All tables deleted successfully, starting sync...")
            for loaderLayer in self.loaderLayers {
                self.startCircularLoaderAnimation(loaderLayer: loaderLayer)
            }
            let syncGroup = DispatchGroup()
            
            for syncEnum in SyncEnum.allCases {
                syncGroup.enter()
                let syncOperation = SyncOperation()
                syncOperation.executeSync(syncType: syncEnum.getSyncText(), syncName: syncEnum.rawValue) { error, response, statusCode in
                    if let error = error {
                        print("Error for \(syncEnum.rawValue): \(error)")
                    }
                    syncGroup.leave()
                }
            }
            syncGroup.notify(queue: .main) {
                print("All sync operations completed!")
                self.sendObjects()
                for loaderLayer in self.loaderLayers {
                    print("Stop Loader")
                    
                }
                
//                                    Defaults.isSyncUpProcessCompleted = true
//                                    Defaults.isSyncUpComplete = false
//                                    Utility.gotoTabbar()
            }
        }
        print("Loop started")
    }
    
    
    func sendObjects() {
        let authOperation = AuthOperation()
        let userDataCheckIn = [
            "Sync_Type__c": "Sync Down Check-In",
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
        
        let userDataPicklist = [
            "Sync_Type__c": "Sync Down Menu",
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
        if isSideMenu {
            userDataDict = ["records": [userDataPicklist]]
        } else {
            userDataDict = ["records": [userDataCheckIn]]
        }
        print(userDataDict)
        authOperation.sendSobjects(details: userDataDict) { error , resposne, statusCode in
            if statusCode == .success {
                Defaults.isSyncUpProcessCompleted = true
                Defaults.isSyncUpComplete = false
                Utility.gotoTabbar()
            } else {
                
            }
        }
    }
}
    
