//
//  POSMAssetReqVc.swift
//  FRATELLI
//
//  Created by Sakshi on 05/12/24.
//


import UIKit
import AVFoundation
import Photos

struct POSMItem {
    var label: String
    var quantity: Int
}

struct AssetItem {
    var label: String?
    var isAvailable: Bool?
    var image: String?
}

protocol CheckboxCallForAssetDelegate: AnyObject {
    func didToggleCheckbox(at indexPath: IndexPath, isChecked: Bool)
}

class POSMAssetReqVc: UIViewController, CheckboxCallForAssetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var tableVw1: UITableView?
    @IBOutlet var tableVw2: UITableView?
    @IBOutlet var searchPosmTxtFld: UITextField?
    @IBOutlet var searchAssetTxtFld: UITextField?
    @IBOutlet var posmItemLbl: UILabel?
    @IBOutlet var assetItemLbl: UILabel?
    @IBOutlet var topStackVw: UIStackView?
    @IBOutlet var secondStackVw: UIStackView?
    @IBOutlet var submitBtn: UIButton?
    var pickerView = UIPickerView()
//    var assetModel = [AssetModel]()
    var posmItems = [POSMItem]()
    var assetItems = [AssetItem]()
//    var onAssetsTable = OnAssetsTable()
    var pOSMRequisitionModel = [POSMRequisitionModel]()
    var pOSMRequisitionTable = POSMRequisitionTable()
    var assetRequisitionModel = [AssetRequisitionModel]()
    var assetRequisitionTable = AssetRequisitionTable()
    var activeTextField: UITextField?
    var selectedLabelId: String?
    var accountId: String = ""
    var currentPickerData: [String] = []
    var productPickerData = [String]()
    var selectedIndexPath: IndexPath?
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var qCROperation = QCROperation()
    var customDateFormatter = CustomDateFormatter()
    var pOSMTable = POSMTable()
    var pOSMLineItemsTable = POSMLineItemsTable()
    var appVersionOperation = AppVersionOperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialView()
        addTapGestureToDismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assetRequisitionModel = assetRequisitionTable.getAssetRequisitions()
        pOSMRequisitionModel = pOSMRequisitionTable.getPOSMRequisitions()
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        searchPosmTxtFld?.text = ""
        searchAssetTxtFld?.text = ""
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        return toolbar
    }
    
    func setUpInitialView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        searchPosmTxtFld?.layer.cornerRadius = 8
        searchAssetTxtFld?.layer.cornerRadius = 8
        searchPosmTxtFld?.delegate = self
        searchPosmTxtFld?.inputView = pickerView
        searchPosmTxtFld?.inputAccessoryView = createToolbar()
        searchPosmTxtFld?.borderWidth = 1
        searchPosmTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        tableVw1?.borderWidth = 1
        tableVw1?.layer.cornerRadius = 8
        tableVw1?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        tableVw2?.borderWidth = 1
        tableVw2?.layer.cornerRadius = 8
        tableVw2?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        topStackVw?.borderWidth = 1
        topStackVw?.layer.cornerRadius = 8
        topStackVw?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        secondStackVw?.borderWidth = 1
        secondStackVw?.layer.cornerRadius = 8
        secondStackVw?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        
        searchAssetTxtFld?.delegate = self
        searchAssetTxtFld?.inputView = pickerView
        searchAssetTxtFld?.inputAccessoryView = createToolbar()
        searchAssetTxtFld?.borderWidth = 1
        searchAssetTxtFld?.layer.borderColor = CGColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        submitBtn?.layer.cornerRadius = 8.0
        submitBtn?.layer.masksToBounds = true
        tableVw1?.delegate = self
        tableVw1?.dataSource = self
        tableVw2?.delegate = self
        tableVw2?.dataSource = self
        searchAssetTxtFld?.setLeftPaddingPoints(12.0)
        searchPosmTxtFld?.setLeftPaddingPoints(12.0)
    }
        
    func didToggleCheckbox(at indexPath: IndexPath, isChecked: Bool) {
        assetItems[indexPath.row].isAvailable = isChecked
        print("Checkbox toggled at \(indexPath.row), isChecked: \(isChecked)")
        tableVw2?.reloadRows(at: [indexPath], with: .none)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    func sendPOSMReq() {
//        let pOSMModel = POSMModel(
//            localId: nil,
//            ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
//            outerName: "",
//            outerId: accountId,
//            Visit__c: "",
//            OwnerId: Defaults.userId,
//            isSync: "0",
//            createdAt: customDateFormatter.getFormattedDateForAccount(),
//            Visit_Date_c: "",
//            Visit_Order_c: ""
//        )
//        pOSMTable.savePOSM(posm: pOSMModel) { success, error in
//            if success {
//                self.sendPOSMLineItems()
//            } else if let error = error {
//                print("Error saving POSM \(error)")
//                SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save POSM. Please try again.")
//            }
//        }
//    }
//    
//    func showAlert() {
//        let checkInalert = UIAlertController(
//            title: "Confirmation",
//            message: "Are you sure you want to save POSM Request Form?",
//            preferredStyle: .alert
//        )
//        self.present(checkInalert, animated: true, completion: nil)
//        checkInalert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
//            print("Cancel tapped")
//        }))
//        
//        checkInalert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//            Utility.gotoTabbar()
//            SceneDelegate.getSceneDelegate().window?.makeToast(POSMREQ_CREATED)
//        }))
//    }
//    
//    func sendPOSMLineItems() {
//        guard !posmItems.isEmpty else { return }
//        for posmItemsdata in posmItems {
//            let pOSMLineItemsModel = POSMLineItemsModel(
//                localId: nil,
//                ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
//                PosmItemId: posmItemsdata.labelId,
//                POSM_Asset_name__c: posmItemsdata.label,
//                Quantity__c: "\(posmItemsdata.quantity)",
//                OwnerId: Defaults.userId,
//                isSync: "0",
//                createdAt: customDateFormatter.getFormattedDateForAccount()
//            )
//            pOSMLineItemsTable.savePOSMLineItem(posmLineItem: pOSMLineItemsModel) { success, error in
//                if success {
//                    self.showAlert()
//                } else if let error = error {
//                    print("Error saving POSM \(error)")
//                    SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save POSM. Please try again.")
//                }
//            }
//        }
//    }
    
    func sendPOSMReqAndLineItems(completion: @escaping () -> Void) {
        let pOSMModel = POSMModel(
            localId: nil,
            ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
            outerName: "",
            outerId: currentVisitId,
            Visit__c: "",
            OwnerId: Defaults.userId,
            isSync: "0",
            createdAt: customDateFormatter.getFormattedDateForAccount(),
            Visit_Date_c: visitPlanDate,
            Visit_Order_c: currentSelectedVisitId
        )
        
        pOSMTable.savePOSM(posm: pOSMModel) { success, error in
            if success {
                print("✅ POSM Header saved")

                self.sendPOSMLineItems {
                    print("✅ POSM Line Items saved")
                    completion()
                }

            } else if let error = error {
                print("❌ Error saving POSM \(error)")
                SceneDelegate.getSceneDelegate().window?.makeToast("Failed to save POSM. Please try again.")
            }
        }
    }
    
    
    func sendPOSMLineItems(completion: @escaping () -> Void) {
        guard !posmItems.isEmpty else {
            completion()
            return
        }

        let dispatchGroup = DispatchGroup()

        for item in posmItems {
            dispatchGroup.enter()

            let pOSMLineItemsModel = POSMLineItemsModel(
                localId: nil,
                ExternalId: "\(currentVisitId)\(CustomDateFormatter.getCurrentDateTime())",
                PosmItemId: "",
                POSM_Asset_name__c: item.label,
                Quantity__c: "\(item.quantity)",
                OwnerId: Defaults.userId,
                isSync: "0",
                createdAt: customDateFormatter.getFormattedDateForAccount()
            )

            pOSMLineItemsTable.savePOSMLineItem(posmLineItem: pOSMLineItemsModel) { success, error in
                if success {
                    print("✅ Saved POSM Line Item: \(item.label)")
                } else if let error = error {
                    print("❌ Error saving POSM Line Item: \(error)")
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    @IBAction func submitAction() {
        let _: [String: Any] = [
            "posmItems": posmItems.map { ["label": $0.label, "quantity": $0.quantity] },
            "assetItems": assetItems.map { ["label": $0.label ?? "", "isAvailable": $0.isAvailable ?? false, "image": $0.image ?? ""] }
        ]
        skipTable.updatePOSMRequestVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, posmRequestVisibility: "0") { success, error in
            if success {
                print("posmRequestVisibility skip updated successfully!")
            } else {
                print("Failed to update posmRequestVisibility skip: \(error ?? "Unknown error")")
            }
        }
        print(assetItems)
        guard !assetItems.isEmpty || !posmItems.isEmpty else {
            self.showAlert(title: "Alert", message: "No Asset or POSM added. you cannot submit.")
            return
        }
        sendPOSMReqAndLineItems {
            self.uploadAssetsToServer(assets: self.assetItems)
        }
    }
    
    func saveposmRequisationinDB(posm: [POSMItem]) {
        
    }
    
    func uploadAssetsToServer(assets: [AssetItem]) {
        // 1. Check if at least one file is selected
        if !assetItems.isEmpty {
            let isAnyFileSelected = assets.contains { $0.image != nil && !$0.image!.isEmpty }
            guard isAnyFileSelected else {
                showAlert(title: "No Files Selected", message: "Please select at least one file before proceeding.")
                return
            }
        }

        // 2. Validate for mandatory images (e.g., based on asset name keywords like "cooler", "display")
        let keywordsRequiringImage = ["cooler", "display", "banner", "standee"]
        let missingImages = assets.filter { session in
            guard let assetName = session.label else { return false }
            return keywordsRequiringImage.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
                   (session.image == nil || session.image?.isEmpty == true)
        }

        if !missingImages.isEmpty {
            let assetNames = missingImages.compactMap { $0.label }.joined(separator: ",\n")
            showAlert(title: "Missing Images", message: "Image is mandatory for:\n\(assetNames)")
            return
        }

        // 3. Validate for PDF-mandatory assets (e.g., "Menu Listing")
        let missingPDFAssets = assets.filter { session in
            guard let assetName = session.label else { return false }
            return assetName.localizedCaseInsensitiveContains("menu listing") &&
                   (session.image == nil || session.image?.isEmpty == true)
        }

        if !missingPDFAssets.isEmpty {
            let assetNames = missingPDFAssets.compactMap { $0.label }.joined(separator: ",\n")
            showAlert(title: "Missing PDF", message: "PDF is mandatory for:\n\(assetNames)")
            return
        }

        // 4. Begin saving to local database
        let dispatchGroup = DispatchGroup()
        var saveFailures: [String] = []

        for session in assets {
            guard let fileName = session.image, !fileName.isEmpty else { continue }

            let model = AssetRequisitionServerModel(
                localId: nil,
                userId: Defaults.userId ?? "",
                fileType: fileName.lowercased().hasSuffix(".pdf") ? "pdf" : "image",
                fileName: fileName,
                isSync: "0",
                createdAt: getCurrentTimeStamp(),
                assetName: session.label,
                externalId: externalID,
                dealerDistributorCorpId: currentVisitId,
                deviceName: UIDevice.current.name,
                deviceVersion: appVersionOperation.getCurrentAppVersion() ?? "",
                deviceType: "iOS",
                visitOrderId: currentSelectedVisitId,
                imagePublicUrl: ""
            )

            dispatchGroup.enter()
            AssetRequisitionServerTable().saveRecord(model) { success, error in
                if success {
                    print("✅ Saved: \(fileName)")
                } else {
                    print("❌ Failed to save \(fileName). Error: \(error ?? "-")")
                    saveFailures.append(fileName)
                }
                dispatchGroup.leave()
            }
        }

        // 5. On complete
        dispatchGroup.notify(queue: .main) {
            if saveFailures.isEmpty {
                self.view.makeToast("All files saved locally. Uploading...", duration: 1.5, position: .top)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "AddNewTasksVC") as? AddNewTasksVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                let failed = saveFailures.joined(separator: ", ")
                self.showAlert(title: "Save Failed", message: "Failed to save files:\n\(failed)")
            }
        }
    }
    
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        self.present(alert, animated: true)
//    }
    
    func getCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    
    
    
    
    
//    func uploadAssetsToServer(assets: [AssetItem]) {
//        uploadNextAsset(from: assets, index: 0)
//    }
//
//    private func uploadNextAsset(from assets: [AssetItem], index: Int) {
//        guard index < assets.count else {
//            print("✅ All assets uploaded successfully.")
//            let storyboard = UIStoryboard(name: "Home", bundle: nil)
//            if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "AddNewTasksVC") as? AddNewTasksVC {
//                self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
//            }
//            return
//        }
//        
//        let asset = assets[index]
//        
//        guard let imageName = asset.image,
//              let image = loadImageFromDocuments(imageName: imageName) else {
//            print("⚠️ Error: Could not find image for asset \(asset.label ?? "Unknown")")
//            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
//            return
//        }
//        
//        guard let base64String = convertImageToBase64(image: image) else {
//            print("⚠️ Error: Could not convert image \(asset.label ?? "") to Base64")
//            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
//            return
//        }
//        
//        guard let hexString = convertBase64ToHex(base64String: base64String) else {
//            print("⚠️ Error: Could not convert Base64 to Hex for \(asset.label ?? "")")
//            uploadNextAsset(from: assets, index: index + 1) // Move to next asset
//            return
//        }
//        
//        let params: [String: Any] = [
//            "Title": "Asset-\(asset.label ?? "")-000\(index)",
//            "AccountId": currentVisitId,
//            "PathOnClient": asset.image ?? "",
//            "FileDataHex": hexString
//        ]
//        print(params)
//        qCROperation.executeUploadImage(localId: 0, param: params) { error, response, statusCode in
//            if let error = error {
//                print("❌ Error uploading \(asset.label ?? ""): \(error)")
//            } else {
//                print("✅ Uploaded \(asset.label ?? "") successfully: \(response ?? [:])")
//            }
//            self.uploadNextAsset(from: assets, index: index + 1)
//        }
//    }
    
    private func loadImageFromDocuments(imageName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
        guard let compressedImageData = resizedImage.jpegData(compressionQuality: 0.2) else { return nil }
        print("Compressed Image Size: \(Double(compressedImageData.count) / 1024.0) KB")
        return compressedImageData.base64EncodedString()
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = (widthRatio > heightRatio) ?
                      CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
                      CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func convertBase64ToHex(base64String: String) -> String? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return imageData.map { String(format: "%02x", $0) }.joined()
    }
    
    @IBAction func skipAction() {
        skipTable.updatePOSMRequestVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, posmRequestVisibility: "1") { success, error in
            if success {
                print("posmRequestVisibility skip updated successfully!")
            } else {
                print("Failed to update posmRequestVisibility skip: \(error ?? "Unknown error")")
            }
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "AddNewTasksVC") as? AddNewTasksVC {
            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
        }
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneButtonTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        guard selectedRow >= 0 else { return }
        let selectedValue = currentPickerData[selectedRow]
        if activeTextField == searchPosmTxtFld {
            if posmItems.contains(where: { $0.label == selectedValue }) {
                self.showAlert(title: "Alert", message: "Selected POSM is already added.")
            } else {
                posmItems.append(POSMItem(label: selectedValue, quantity: 1))
                tableVw1?.reloadData()
            }
        } else if activeTextField == searchAssetTxtFld {
            if assetItems.contains(where: { $0.label == selectedValue }) {
                self.showAlert(title: "Alert", message: "Selected Asset is already added.")
            } else {
                assetItems.append(AssetItem(label: selectedValue, isAvailable: false, image: nil))
                tableVw2?.reloadData()
            }
        }
        activeTextField?.resignFirstResponder()
        activeTextField?.text = ""
    }
}

// MARK: - UITextFieldDelegate
extension POSMAssetReqVc: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchPosmTxtFld {
            currentPickerData = pOSMRequisitionModel.map { $0.Label ?? "" }
            pickerView.reloadAllComponents()
        } else if textField == searchAssetTxtFld {
            currentPickerData = assetRequisitionModel.map { $0.Label ?? "" }
            pickerView.reloadAllComponents()
        }
        activeTextField = textField
    }
}

extension POSMAssetReqVc: ImagePopForVisibilityDelegate {
    func didUpdateImage(image: UIImage, forIndex index: IndexPath) {
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            assetItems[index.row].image = fileName
        }
        tableVw2?.reloadRows(at: [index], with: .automatic)
    }
}

extension POSMAssetReqVc: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = currentPickerData[row]
        if activeTextField == searchPosmTxtFld {
            searchPosmTxtFld?.text = selectedValue
        } else if activeTextField == searchAssetTxtFld {
            searchAssetTxtFld?.text = selectedValue
        }
    }
}

extension POSMAssetReqVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == tableVw1 ? posmItems.count : assetItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableVw1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "POSMReqCell", for: indexPath) as! POSMReqCell
            let item = posmItems[indexPath.row]
            cell.PosmTxtFld?.text = item.label
            cell.PosmQuantityLbl?.text = "\(item.quantity)"
            cell.posmIncreaseBtn?.tag = indexPath.row
            cell.posmDecreaseBtn?.tag = indexPath.row
            cell.posmIncreaseBtn?.addTarget(self, action: #selector(increasePOSMQuantity(_:)), for: .touchUpInside)
            cell.posmDecreaseBtn?.addTarget(self, action: #selector(decreasePOSMQuantity(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetReqCell", for: indexPath) as! AssetReqCell
            let item = assetItems[indexPath.row]
            cell.assetTxtFld?.text = item.label
            cell.indexPath = indexPath
            cell.delegate = self
            cell.isAvailable?.isSelected = item.isAvailable ?? false
            cell.isAvailable?.setImage(UIImage(named: item.isAvailable == true ? "checkBox" : "uncheck"), for: .normal)
            cell.clickImage?.tag = indexPath.row
            cell.clickImage?.addTarget(self, action: #selector(selectImageButtonTapped(_:)), for: .touchUpInside)
            cell.clickImage?.setImage(UIImage(named: "cameraVisibility"), for: .normal)
            //            if let imageName = item.image {
            //                let imageUrl = getDocumentsDirectory().appendingPathComponent(imageName)
            //                if let imageData = try? Data(contentsOf: imageUrl) {
            //                    let image = UIImage(data: imageData)
            //                    cell.clickImage?.setImage(image, for: .normal)
            //                }
            //            }
            if let fileName = assetItems[indexPath.row].image,
               let imagePath = getImagePath(for: fileName) {
                let image = UIImage(contentsOfFile: imagePath.path)
                cell.clickImage?.setImage(image, for: .normal)
            } else {
                print("⚠️ Error: Could not find image for asset \(assetItems[indexPath.row].label ?? "Unknown")")
            }
            return cell
        }
    }
    
    @objc func increasePOSMQuantity(_ sender: UIButton) {
        let index = sender.tag
        posmItems[index].quantity += 1
        tableVw1?.reloadData()
    }
    
    @objc func decreasePOSMQuantity(_ sender: UIButton) {
        let index = sender.tag
        if posmItems[index].quantity > 1 {
            posmItems[index].quantity -= 1
            tableVw1?.reloadData()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getImagePath(for fileName: String) -> URL? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    @objc func selectImageButtonTapped(_ sender: UIButton) {
        let indexPathRow = sender.tag
        selectedIndexPath = IndexPath(row: indexPathRow, section: 0)
        
        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            
            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
                popoverController.permittedArrowDirections = .any
            }
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        func requestCameraPermission() {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showImagePicker(sourceType: .camera)
                    } else {
                        self.showPermissionAlert(for: "Camera")
                    }
                }
            }
        }
        
        func requestPhotoLibraryPermission() {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        showImagePicker(sourceType: .photoLibrary)
                    default:
                        self.showPermissionAlert(for: "Photo Library")
                    }
                }
            }
        }
        
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraStatus {
            case .authorized:
                showImagePicker(sourceType: .camera)
            case .notDetermined:
                requestCameraPermission()
            default:
                self.showPermissionAlert(for: "Camera")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(for feature: String) {
        let alert = UIAlertController(
            title: "\(feature) Access Denied",
            message: "Please enable access to \(feature) in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        //
        if let imageData = selectedImage.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            if let indexPath = selectedIndexPath {
                assetItems[indexPath.row].image = fileName
                tableVw2?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

class POSMReqCell: UITableViewCell {
    @IBOutlet var posmIncreaseBtn: UIButton?
    @IBOutlet var posmDecreaseBtn: UIButton?
    @IBOutlet var PosmTxtFld: UITextField?
    @IBOutlet var PosmQuantityLbl: UILabel?
}

class AssetReqCell: UITableViewCell {
    @IBOutlet var assetTxtFld: UITextField?
    @IBOutlet var isAvailable: UIButton?
    weak var delegate: CheckboxCallForAssetDelegate?
    var indexPath: IndexPath!
    @IBOutlet var clickImage: UIButton?
    
    @IBAction func checkboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        let newImageName = sender.isSelected ? "checkBox" : "uncheck"
        sender.setImage(UIImage(named: newImageName), for: .normal)
        delegate?.didToggleCheckbox(at: indexPath, isChecked: sender.isSelected)
    }
}











