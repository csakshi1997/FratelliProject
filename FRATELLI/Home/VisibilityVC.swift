//
//  VisibilityVC.swift
//  FRATELLI
//
//  Created by Sakshi on 05/12/24.
//


import UIKit
import AVFoundation
import Photos
import MaterialComponents.MaterialTextControls_OutlinedTextFields

protocol CheckboxCellDelegate: AnyObject {
    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool)
}

protocol ImagePopForVisibilityDelegate: AnyObject {
    func didUpdateImage(image: UIImage, forIndex index: IndexPath)
}

class VisibilityVC: UIViewController, CheckboxCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIDocumentPickerDelegate {
    @IBOutlet var TableVw: UITableView?
    @IBOutlet var nodataVw: UIView?
    @IBOutlet var footerView: UIView?
    @IBOutlet var countLbl: UILabel?
    @IBOutlet var proceedBtn: UIButton?
    @IBOutlet var txtView: UITextView?
    var date: String?
    var time: String?
    var address: String?
    var accountId: String = ""
    var assetModel = [AssetModel]()
    var onAssetsTable = OnAssetsTable()
    var allVisibilityData: [AllVisibilityModel] = []
    var sessionModel = [sessetmodel]()
    var customDateFormatter = CustomDateFormatter()
    var allVisibilityTable = AllVisibilityTable()
    var selectedIndexPath: IndexPath?
    let characterLimit = 212
    var skipTable = SkipTable()
    var skipModel = SkipModel()
    var qCROperation = QCROperation()
    var outletsTable = OutletsTable()
    var outlets : Outlet?
    var assetVisibility = ""
    var pdfOnlyAssets = [String]()
    var imageMandatoryAssets = [String]()
    let uploader = UploadFileToServer()
    var appVersionOperation = AppVersionOperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlets = outletsTable.getOutletData(forAccountId: currentVisitId)
        assetVisibility = outlets?.Asset_Visibility__c ?? ""
        print("🔍 Raw Asset Visibility: \(assetVisibility)")
        
        let assetArray = assetVisibility
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        pdfOnlyAssets = assetArray.filter { $0 == "Menu Listing" }
        imageMandatoryAssets = assetArray.filter { $0 != "Menu Listing" }
        
        print("📄 PDF Only Assets: \(pdfOnlyAssets)")
        print("📸 Image Mandatory Assets: \(imageMandatoryAssets)")
        
        txtView?.delegate = self
        proceedBtn?.layer.masksToBounds = true
        proceedBtn?.layer.cornerRadius = 8
        TableVw?.delegate = self
        TableVw?.dataSource = self
        TableVw?.reloadData()
        txtView?.dropShadow()
        proceedBtn?.layer.cornerRadius = 8.0
        proceedBtn?.layer.masksToBounds = true
        txtView?.placeholder = "Add Remark"
        txtView?.textColor = .darkGray
        txtView?.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 13)
        addTapGestureToDismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textView = txtView?.viewWithTag(101) as? UITextView {
            textView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assetModel = onAssetsTable.getAssets()
        if assetModel.isEmpty {
            nodataVw?.isHidden = false
            print("assetModel is empty. Please check its initialization.")
        } else {
            initializeSessionModel()
            nodataVw?.isHidden = true
        }
    }
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == txtView {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = size.height
                }
            }
            let currentCount = textView.text.count
            countLbl?.text = "\(currentCount)"
            if textView.text.isEmpty {
                textView.setPlaceholder("Add Remark")
            } else {
                textView.removePlaceholder()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let updatedTextLength = currentText.count - range.length + text.count
        return updatedTextLength <= 212
    }
    
    func initializeSessionModel() {
        if sessionModel.isEmpty {
            sessionModel = assetModel.map { asset in
                let session = sessetmodel()
                session.asset = asset.Label
                session.isPresent = false
                session.isMaintenance = false
                return session
            }
            TableVw?.reloadData()
        }
    }
    
    func didToggleCheckbox(at indexPath: IndexPath, isFirst: Bool, isChecked: Bool) {
        let session = sessionModel[indexPath.row]
        if isFirst {
            session.isPresent = isChecked
        } else {
            session.isMaintenance = isChecked
        }
        print("Updated \(session.asset ?? ""): isPresent = \(session.isPresent ?? false), isMaintenance = \(session.isMaintenance ?? false)")
    }
    
//    private func uploadNextAsset(from assets: [sessetmodel], index: Int) {
//        let asset = assets[index]
//        guard let imageName = asset.image,
//              let image = loadImageFromDocuments(imageName: imageName) else {
//            print("⚠️ Error: Could not find image for asset \(asset.asset ?? "Unknown")")
//            uploadNextAsset(from: assets, index: index + 1)
//            return
//        }
//        
//        guard let base64String = convertImageToBase64(image: image) else {
//            print("⚠️ Error: Could not convert image \(asset.asset ?? "") to Base64")
//            uploadNextAsset(from: assets, index: index + 1)
//            return
//        }
//        
//        guard let hexString = convertBase64ToHex(base64String: base64String) else {
//            print("⚠️ Error: Could not convert Base64 to Hex for \(asset.asset ?? "")")
//            uploadNextAsset(from: assets, index: index + 1)
//            return
//        }
//        
//        let params: [String: Any] = [
//            "Title": "OutletVisibility-\(asset.asset ?? "")-000\(index)",
//            "AccountId": currentVisitId,
//            "PathOnClient": asset.image ?? "",
//            "FileDataHex": hexString
//        ]
//        print(params)
//        qCROperation.executeUploadImage(localId: 0, param: params) { error, response, statusCode in
//            if let error = error {
//                print("❌ Error uploading \(asset.asset ?? ""): \(error)")
//            } else {
//                SceneDelegate.getSceneDelegate().window?.makeToast(VISIBILITY_CREATED)
//            }
//            self.uploadNextAsset(from: assets, index: index + 1)
//        }
//    }
    
    private func uploadNextAsset(from assets: [sessetmodel], index: Int) {
        guard index < assets.count else {
            print("✅ All assets uploaded successfully.")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "AddNewTasksVC") as? AddNewTasksVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return
        }
        
        let asset = assets[index]
        guard let fileName = asset.image else {
            print("⚠️ No file name for asset \(asset.asset ?? "")")
            uploadNextAsset(from: assets, index: index + 1)
            return
        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("⚠️ File not found: \(fileName)")
            uploadNextAsset(from: assets, index: index + 1)
            return
        }
        
        let uploader = UploadFileToServer()
        let userId = currentVisitId
        
        var mimeType = "application/octet-stream"
        
        if fileName.lowercased().hasSuffix(".pdf") {
            mimeType = "application/pdf"
        } else if fileName.lowercased().hasSuffix(".jpg") || fileName.lowercased().hasSuffix(".jpeg") {
            mimeType = "image/jpeg"
        } else if fileName.lowercased().hasSuffix(".png") {
            mimeType = "image/png"
        }
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            uploader.uploadFileToServer(userId: userId, fileData: fileData, fileName: fileName, mimeType: mimeType) { success, url in
                DispatchQueue.main.async {
                    if success {
                        print("✅ File Uploaded: \(url ?? "")")
                    } else {
                        print("❌ Upload Failed: \(url ?? "Unknown error")")
                    }
                    self.uploadNextAsset(from: assets, index: index + 1)
                }
            }
        } catch {
            print("❌ File read error: \(error.localizedDescription)")
            uploadNextAsset(from: assets, index: index + 1)
        }
    }
    
    private func loadImageFromDocuments(imageName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300)) // Resize image
        guard let compressedImageData = resizedImage.jpegData(compressionQuality: 0.2) else { return nil } // Compress image
        print("Compressed Image Size: \(Double(compressedImageData.count) / 1024.0) KB") // Debug: Check file size
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
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        guard let indexPath = selectedIndexPath else { return }
        
        let fileName = selectedURL.lastPathComponent
        sessionModel[indexPath.row].image = fileName
        
        let destURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let fileData = try Data(contentsOf: selectedURL)
            try fileData.write(to: destURL)
        } catch {
            print("❌ Error saving PDF: \(error)")
        }
        
        TableVw?.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func presentDocumentPicker() {
        let types = ["com.adobe.pdf"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true)
    }
    
    @objc func selectImageButtonTapped(_ sender: UIButton) {
        let indexPathRow = sender.tag
        selectedIndexPath = IndexPath(row: indexPathRow, section: 0)
        
        guard let assetName = sessionModel[indexPathRow].asset else { return }
        
        if assetName.localizedCaseInsensitiveContains("Menu Listing") {
            presentDocumentPicker()
            return
        }
        
        func showImagePicker(sourceType: UIImagePickerController.SourceType) {
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "Unavailable", message: "This source is not available on your device.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            
            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
                popoverController.permittedArrowDirections = .any
            }
            
            self.present(imagePicker, animated: true)
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
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let alert = UIAlertController(title: "Camera Unavailable", message: "This device does not support the camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        
        self.present(alert, animated: true)
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
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            if let indexPath = selectedIndexPath {
                sessionModel[indexPath.row].image = fileName
                TableVw?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //    @IBAction func proceedAction() {
    //        let isAnyImageSelected = sessionModel.contains { $0.image != nil && $0.image != "" }
    //        if !isAnyImageSelected {
    //            showAlert()
    //            return
    //        }
    //
    //        guard !sessionModel.isEmpty else { return }
    //        let remarkText = txtView?.text
    //        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
    //            guard let self = self else { return }
    //            var visibilityData: [AllVisibilityModel] = []
    //
    //            for session in self.sessionModel {
    //                guard let imageName = session.image,
    //                      let image = self.loadImageFromDocuments(imageName: imageName),
    //                      let base64String = self.convertImageToBase64(image: image),
    //                      let hexString = self.convertBase64ToHex(base64String: base64String) else {
    //                    continue
    //                }
    //
    //                let visibilityModel = AllVisibilityModel(
    //                    LocalId: nil,
    //                    External_Id__c: externalID,
    //                    outletId: currentVisitId,
    //                    assetName: session.asset,
    //                    addRemark: remarkText,
    //                    assetItemImg: session.image,
    //                    isPresent: session.isPresent ?? false ? "1" : "0",
    //                    isMaintenance: session.isMaintenance ?? false ? "1" : "0",
    //                    isSync: "0",
    //                    hexString: hexString,
    //                    createdAt: customDateFormatter.getFormattedDateForAccount()
    //                )
    //                visibilityData.append(visibilityModel)
    //            }
    //            allVisibilityTable.saveVisibility(models: visibilityData) { success, error in
    //                DispatchQueue.main.async {
    //                    if success {
    //                        self.skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "0") { success, error in
    //                            if success {
    //                                SceneDelegate.getSceneDelegate().window?.makeToast(VISIBILITY_CREATED)
    //                                let storyboard = UIStoryboard(name: "Home", bundle: nil)
    //                                if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
    //                                    self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
    //                                }
    //                            } else {
    //                                print("Failed to update assetVisibility skip: \(error ?? "Unknown error")")
    //                            }
    //                        }
    //                    } else {
    //                        SceneDelegate.getSceneDelegate().window?.makeToast(SOMETHING_WENT_WRONG_STR)
    //                    }
    //                }
    //            }
    //        }
    //    }
//    
//    @IBAction func proceedAction() {
//        let isAnyFileSelected = sessionModel.contains { $0.image != nil && !$0.image!.isEmpty }
//        if !isAnyFileSelected {
//            showAlert()
//            return
//        }
//
//        guard !sessionModel.isEmpty else { return }
//
//        let missingImages = sessionModel.filter { session in
//            guard let assetName = session.asset else { return false }
//            return imageMandatoryAssets.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
//                   (session.image == nil || session.image?.isEmpty == true)
//        }
//
//        if !missingImages.isEmpty {
//            let assetNames = missingImages.compactMap { $0.asset }.joined(separator: ",\n")
//            self.view.makeToast("Image is mandatory for:\n\(assetNames)")
//            return
//        }
//
//        let pdfOnlyAssets = sessionModel.filter { session in
//            guard let assetName = session.asset else { return false }
//            return assetName.localizedCaseInsensitiveContains("Menu Listing") &&
//                   (session.image == nil || session.image?.isEmpty == true)
//        }
//
//        if !pdfOnlyAssets.isEmpty {
//            let assetNames = pdfOnlyAssets.compactMap { $0.asset }.joined(separator: ",\n")
//            self.view.makeToast("PDF is mandatory for:\n\(assetNames)")
//            return
//        }
//
//        uploadAllFilesToServer()
//    }
    
//    @IBAction func proceedAction() {
//        let isAnyFileSelected = sessionModel.contains { $0.image != nil && !$0.image!.isEmpty }
//        if !isAnyFileSelected {
//            showAlert(title: "No Files Selected", message: "Please select at least one file before proceeding.")
//            return
//        }
//        
//        guard !sessionModel.isEmpty else { return }
//        
//        let missingImages = sessionModel.filter { session in
//            guard let assetName = session.asset else { return false }
//            return imageMandatoryAssets.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
//            (session.image == nil || session.image?.isEmpty == true)
//        }
//        
//        if !missingImages.isEmpty {
//            let assetNames = missingImages.compactMap { $0.asset }.joined(separator: ",\n")
//            showAlert(title: "Missing Images", message: "Image is mandatory for:\n\(assetNames)")
//            return
//        }
//        
//        let pdfOnlyAssets = sessionModel.filter { session in
//            guard let assetName = session.asset else { return false }
//            return assetName.localizedCaseInsensitiveContains("Menu Listing") &&
//            (session.image == nil || session.image?.isEmpty == true)
//        }
//        
//        if !pdfOnlyAssets.isEmpty {
//            let assetNames = pdfOnlyAssets.compactMap { $0.asset }.joined(separator: ",\n")
//            showAlert(title: "Missing PDF", message: "PDF is mandatory for:\n\(assetNames)")
//            return
//        }
//        
//        let dispatchGroup = DispatchGroup()
//        var saveFailures: [String] = []
//        
//        for session in sessionModel {
//            guard let fileName = session.image, !fileName.isEmpty else { continue }
//            
//            let model = VisibilityServerModel(
//                localId: nil,
//                userId: Defaults.userId ?? "",
//                fileType: fileName.lowercased().hasSuffix(".pdf") ? "pdf" : "image",
//                fileName: fileName,
//                isSync: "0",
//                createdAt: getCurrentTimeStamp()
//            )
//            
//            dispatchGroup.enter()
//            VisibilityServerTable().saveRecord(model) { success, error in
//                if success {
//                    print("✅ Saved file: \(fileName)")
//                } else {
//                    saveFailures.append(fileName)
//                    print("❌ Failed to save file: \(fileName), error: \(error ?? "-")")
//                }
//                dispatchGroup.leave()
//            }
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            if !saveFailures.isEmpty {
//                let failedFiles = saveFailures.joined(separator: ", ")
//                self.showAlert(title: "Save Failed", message: "Some files couldn't be saved:\n\(failedFiles)")
//            } else {
//                self.view.makeToast("All files saved locally. Uploading...", duration: 1.5, position: .top)
//                
//            }
//        }
//    }
    
    @IBAction func proceedAction() {
        //        let isAnyFileSelected = sessionModel.contains { $0.image != nil && !$0.image!.isEmpty }
        //        if !isAnyFileSelected {
        //            showAlert(title: "No Files Selected", message: "Please select at least one file before proceeding.")
        //            return
        //        }
        //
        //        guard !sessionModel.isEmpty else { return }
        //
        //        let missingImages = sessionModel.filter { session in
        //            guard let assetName = session.asset else { return false }
        //            return imageMandatoryAssets.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
        //                   (session.image == nil || session.image?.isEmpty == true)
        //        }
        //
        //        if !missingImages.isEmpty {
        //            let assetNames = missingImages.compactMap { $0.asset }.joined(separator: ",\n")
        //            showAlert(title: "Missing Images", message: "Image is mandatory for:\n\(assetNames)")
        //            return
        //        }
        //
        //        let pdfOnlyAssets = sessionModel.filter { session in
        //            guard let assetName = session.asset else { return false }
        //            return assetName.localizedCaseInsensitiveContains("Menu Listing") &&
        //                   (session.image == nil || session.image?.isEmpty == true)
        //        }
        //
        //        if !pdfOnlyAssets.isEmpty {
        //            let assetNames = pdfOnlyAssets.compactMap { $0.asset }.joined(separator: ",\n")
        //            showAlert(title: "Missing PDF", message: "PDF is mandatory for:\n\(assetNames)")
        //            return
        //        }
        
        let isAnyFileSelected = sessionModel.contains { $0.image != nil && !$0.image!.isEmpty }
        guard isAnyFileSelected else {
            showAlert(title: "No Files Selected", message: "Please select at least one file before proceeding.")
            return
        }
        
        guard !sessionModel.isEmpty else { return }
        
        // 2. Validate missing mandatory images
        let missingImages = sessionModel.filter { session in
            guard let assetName = session.asset else { return false }
            return imageMandatoryAssets.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
            (session.image == nil || session.image?.isEmpty == true)
        }
        
        if !missingImages.isEmpty {
            let assetNames = missingImages.compactMap { $0.asset }.joined(separator: ",\n")
            showAlert(title: "Missing Images", message: "Image is mandatory for:\n\(assetNames)")
            return
        }
        
        // 3. Validate missing PDFs for "Menu Listing"
        let missingPDFs = pdfOnlyAssets.filter { requiredPDFAsset in
            !sessionModel.contains { session in
                guard let assetName = session.asset?.lowercased(), let imageName = session.image else { return false }
                return assetName.contains(requiredPDFAsset.lowercased()) && imageName.hasSuffix(".pdf")
            }
        }
        
        if !missingPDFs.isEmpty {
            let assetNames = missingPDFs.joined(separator: ",\n")
            showAlert(title: "Missing PDF", message: "PDF is mandatory for:\n\(assetNames)")
            return
        }
        
        
        let dispatchGroup = DispatchGroup()
        var saveFailures: [String] = []
        
        for session in sessionModel {
            guard let fileName = session.image, !fileName.isEmpty else { continue }
            
            //            let model = VisibilityServerModel(
            //                localId: nil,
            //                userId: Defaults.userId ?? "",
            //                fileType: fileName.lowercased().hasSuffix(".pdf") ? "pdf" : "image",
            //                fileName: fileName,
            //                isSync: "0",
            //                createdAt: getCurrentTimeStamp()
            //            )
            
            let model = VisibilityServerModel(
                localId: nil,
                userId: Defaults.userId,
                fileType: fileName.lowercased().hasSuffix(".pdf") ? "pdf" : "image",
                fileName: fileName,
                isSync: "0",
                createdAt: getCurrentTimeStamp(),
                assetName: session.asset,
                externalId: externalID,
                dealerDistributorCorpId: currentVisitId,
                deviceName: UIDevice.current.name,
                deviceVersion: appVersionOperation.getCurrentAppVersion() ?? "",
                deviceType: "iOS",
                visitOrderId: currentSelectedVisitId.isEmpty ? "" : currentSelectedVisitId,
                imagePublicUrl: ""
            )
            
            dispatchGroup.enter()
            VisibilityServerTable().saveRecord(model) { success, error in
                if success {
                    print("✅ Saved file: \(fileName)")
                } else {
                    saveFailures.append(fileName)
                    print("❌ Failed to save file: \(fileName), error: \(error ?? "-")")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !saveFailures.isEmpty {
                let failedFiles = saveFailures.joined(separator: ", ")
                self.showAlert(title: "Save Failed", message: "Some files couldn't be saved:\n\(failedFiles)")
            } else {
                self.view.makeToast("All files saved locally. Uploading...", duration: 1.5, position: .top)
                
                // ✅ Push to POSMAssetReqVc after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func getCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
//
//    func uploadAllFilesToServer(index: Int = 0) {
//        guard index < sessionModel.count else {
//            print("✅ All files uploaded.")
//            DispatchQueue.main.async {
//                let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                if let vc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            return
//        }
//
//        let session = sessionModel[index]
//        guard let fileName = session.image else {
//            uploadAllFilesToServer(index: index + 1)
//            return
//        }
//
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//        guard FileManager.default.fileExists(atPath: fileURL.path) else {
//            print("❌ File not found at: \(fileName)")
//            uploadAllFilesToServer(index: index + 1)
//            return
//        }
//
//        let mimeType: String
//        if fileName.lowercased().hasSuffix(".pdf") {
//            mimeType = "application/pdf"
//        } else if fileName.lowercased().hasSuffix(".jpg") || fileName.lowercased().hasSuffix(".jpeg") {
//            mimeType = "image/jpeg"
//        } else if fileName.lowercased().hasSuffix(".png") {
//            mimeType = "image/png"
//        } else {
//            mimeType = "application/octet-stream"
//        }
//
//        do {
//            let fileData = try Data(contentsOf: fileURL)
//            let uploader = UploadFileToServer()
//            uploader.uploadFileToServer(userId: Defaults.userId ?? EMPTY, fileData: fileData, fileName: fileName, mimeType: mimeType) { success, url in
//                if success {
//                    print("✅ Uploaded: \(session.asset ?? "") => \(url ?? "")")
//                } else {
//                    print("❌ Upload failed for \(session.asset ?? "")")
//                }
//                self.uploadAllFilesToServer(index: index + 1)
//            }
//        } catch {
//            print("❌ Failed to read file data for \(fileName): \(error)")
//            uploadAllFilesToServer(index: index + 1)
//        }
//    }
    
//    func uploadAllFilesToServer(index: Int = 0) {
//        if index == 0 {
//            self.view.makeToast("Uploading files...", duration: 1.5, position: .top)
//        }
//
//        guard index < sessionModel.count else {
//            print("✅ All files uploaded.")
//            DispatchQueue.main.async {
//                self.view.makeToast("All files uploaded successfully!", duration: 2.0, position: .center)
//                let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                if let vc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            return
//        }
//
//        let session = sessionModel[index]
//        guard let fileName = session.image else {
////            self.view.makeToast("⚠️ Missing file name for \(session.asset ?? "Asset")", duration: 2.0, position: .bottom)
//            uploadAllFilesToServer(index: index + 1)
//            return
//        }
//
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//        guard FileManager.default.fileExists(atPath: fileURL.path) else {
//            self.view.makeToast("❌ File not found: \(fileName)", duration: 2.0, position: .bottom)
//            uploadAllFilesToServer(index: index + 1)
//            return
//        }
//
//        let mimeType: String
//        if fileName.lowercased().hasSuffix(".pdf") {
//            mimeType = "application/pdf"
//        } else if fileName.lowercased().hasSuffix(".jpg") || fileName.lowercased().hasSuffix(".jpeg") {
//            mimeType = "image/jpeg"
//        } else if fileName.lowercased().hasSuffix(".png") {
//            mimeType = "image/png"
//        } else {
//            mimeType = "application/octet-stream"
//        }
//
//        do {
//            let fileData = try Data(contentsOf: fileURL)
//            let uploader = UploadFileToServer()
//            uploader.uploadFileToServer(userId: Defaults.userId ?? EMPTY, fileData: fileData, fileName: fileName, mimeType: mimeType) { success, url in
//                DispatchQueue.main.async {
//                    if success {
//                        self.view.makeToast("✅ Uploaded: \(session.asset ?? "Asset")", duration: 1.5, position: .bottom)
//                    } else {
//                        self.view.makeToast("❌ Upload failed: \(session.asset ?? "Asset")", duration: 2.0, position: .bottom)
//                    }
//                    self.uploadAllFilesToServer(index: index + 1)
//                }
//            }
//        } catch {
//            self.view.makeToast("❌ Read error for: \(fileName)", duration: 2.0, position: .bottom)
//            uploadAllFilesToServer(index: index + 1)
//        }
//    }
    
    func showAlert() {
        let checkInalert = UIAlertController(
            title: "Alert",
            message: "Please select atleast one image",
            preferredStyle: .alert
        )
        self.present(checkInalert, animated: true, completion: nil)
        checkInalert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            print("Cancel tapped")
        }))
    }
    
    func uploadAssetsToServer(assets: [sessetmodel]) {
        guard !assets.isEmpty else {
            print("No assets to upload.")
            return
        }
        uploadNextAsset(from: assets, index: 0)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    @IBAction func skipAction() {
    //        skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "1") { success, error in
    //            if success {
    //                print("assetVisibility skip updated successfully!")
    //            } else {
    //                print("Failed to update assetVisibility skip: \(error ?? "Unknown error")")
    //            }
    //        }
    //        let storyboard = UIStoryboard(name: "Home", bundle: nil)
    //        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
    //            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
    //        }
    //    }
    
    @IBAction func skipAction() {
        let assetArray = assetVisibility
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let pdfOnlyAssets = assetArray.filter { $0.localizedCaseInsensitiveContains("Menu Listing") }
        let imageMandatoryAssets = assetArray.filter { $0 != "Menu Listing" }
        
        let isPdfUploaded = sessionModel.contains { session in
            guard let name = session.asset?.lowercased() else { return false }
            return name.contains("menu listing") && (session.image?.hasSuffix(".pdf") == true)
        }
        
        if pdfOnlyAssets.contains(where: { $0.localizedCaseInsensitiveContains("Menu Listing") }) && !isPdfUploaded {
            self.view.makeToast("Please upload a PDF for Menu Listing before skipping.")
            return
        }
        
        let missingImages = sessionModel.filter { session in
            guard let assetName = session.asset else { return false }
            return imageMandatoryAssets.contains(where: { assetName.localizedCaseInsensitiveContains($0) }) &&
            (session.image == nil || session.image?.isEmpty == true)
        }
        
        if !missingImages.isEmpty {
            let assetNames = missingImages.compactMap { $0.asset }.joined(separator: ",\n")
            self.view.makeToast("Image is mandatory for:\n\(assetNames)")
            return
        }
        
        skipTable.updateAssetVisibilityByVisitOrder(visitOrderId: currentSelectedVisitId, assetVisibility: "1") { success, error in
            if success {
                print("✅ assetVisibility skip updated successfully!")
            } else {
                print("❌ Failed to update assetVisibility skip: \(error ?? "Unknown error")")
            }
        }
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let pOSMAssetReqVc = storyboard.instantiateViewController(withIdentifier: "POSMAssetReqVc") as? POSMAssetReqVc {
            self.navigationController?.pushViewController(pOSMAssetReqVc, animated: true)
        }
    }
}

extension VisibilityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VisibilityCell = tableView.dequeueReusableCell(withIdentifier: "VisibilityCell", for: indexPath) as! VisibilityCell
        let session = sessionModel[indexPath.row]
        
        cell.headingLbl?.text = session.asset
        cell.indexPath = indexPath
        cell.delegate = self
        cell.parentVC = self
        cell.firstBtn.isSelected = session.isPresent ?? false
        cell.firstBtn.setImage(UIImage(named: session.isPresent == true ? "checkBox" : "uncheck"), for: .normal)
        cell.secondBtn.isSelected = session.isMaintenance ?? false
        cell.secondBtn.setImage(UIImage(named: session.isMaintenance == true ? "checkBox" : "uncheck"), for: .normal)
        
        cell.clickImage?.tag = indexPath.row
        cell.clickImage?.addTarget(self, action: #selector(selectImageButtonTapped(_:)), for: .touchUpInside)
        cell.clickImage?.setImage(nil, for: .normal)
        
        if let imageName = session.image {
            let fileUrl = getDocumentsDirectory().appendingPathComponent(imageName)
            
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                if imageName.lowercased().hasSuffix(".pdf") {
                    let pdfIcon = UIImage(systemName: "doc.richtext") ?? UIImage(named: "pdf_icon")
                    cell.imgView?.image = UIImage(named: "")
                    cell.clickImage?.setImage(pdfIcon, for: .normal)
                    cell.clickImage?.tintColor = .systemBlue
                    cell.clickImage?.imageView?.contentMode = .scaleAspectFit
                    cell.clickImage?.clipsToBounds = true
                } else {
                    if let imageData = try? Data(contentsOf: fileUrl),
                       let image = UIImage(data: imageData) {
                        cell.clickImage?.setImage(image, for: .normal)
                        cell.clickImage?.imageView?.contentMode = .scaleAspectFill
                        cell.clickImage?.clipsToBounds = true
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension VisibilityVC: ImagePopForVisibilityDelegate {
    func didUpdateImage(image: UIImage, forIndex index: IndexPath) {
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString + ".png"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
            sessionModel[index.row].image = fileName
        }
        TableVw?.reloadRows(at: [index], with: .automatic)
    }
}

class VisibilityCell: UITableViewCell {
    @IBOutlet var headingLbl: UILabel!
    @IBOutlet var firstBtn: UIButton!
    @IBOutlet var secondBtn: UIButton!
    @IBOutlet var clickImage: UIButton?
    @IBOutlet var imgView: UIImageView?
    @IBOutlet var vW: UIView?
    weak var delegate: CheckboxCellDelegate?
    var indexPath: IndexPath!
    var parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vW?.dropShadow()
        firstBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        secondBtn.setImage(UIImage(named: "uncheck"), for: .normal)
    }
    
    @IBAction func primaryCheckboxTapped(_ sender: UIButton) {
        toggleButtonImage(sender)
        DispatchQueue.main.async {
            self.delegate?.didToggleCheckbox(at: self.indexPath, isFirst: true, isChecked: sender.isSelected)
        }
    }
    
    @IBAction func secondaryCheckboxTapped(_ sender: UIButton) {
        toggleButtonImage(sender)
        DispatchQueue.main.async {
            self.delegate?.didToggleCheckbox(at: self.indexPath, isFirst: false, isChecked: sender.isSelected)
        }
    }
    
    private func toggleButtonImage(_ button: UIButton) {
        DispatchQueue.main.async {
            button.isSelected.toggle()
            let newImageName = button.isSelected ? "checkBox" : "uncheck"
            button.setImage(UIImage(named: newImageName), for: .normal)
        }
    }
}

class sessetmodel {
    var asset: String?
    var isPresent: Bool?
    var isMaintenance: Bool?
    var image: String?
}
