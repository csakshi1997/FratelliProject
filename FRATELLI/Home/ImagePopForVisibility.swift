//
//  ImagePopForVisibility.swift
//  FRATELLI
//
//  Created by Sakshi on 14/01/25.
//

import UIKit

class ImagePopForVisibility: UIViewController {
    @IBOutlet var img: UIImageView?
    @IBOutlet var crossBtn: UIButton?
    @IBOutlet var editBtn: UIButton?
    var image = String()
    var name = String()
    var subName = String()
    var imageURL: URL?
    var cellIndex: IndexPath?
    weak var delegate: ImagePopForVisibilityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageURL = imageURL {
            img?.image = UIImage(contentsOfFile: imageURL.path)
        }
        crossBtn?.layer.cornerRadius = 8
        editBtn?.layer.cornerRadius = 8
    }
    
    @IBAction func crossBtnAction() {
        backgroundBtnAction()
    }
    
    @IBAction func backgroundBtnAction() {
        self.dismiss(animated: false)
    }
    
    @IBAction func editBtnAction() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
}

extension ImagePopForVisibility: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let newImage = info[.originalImage] as? UIImage, let cellIndex = cellIndex else { return }

        // Notify the delegate about the updated image
        delegate?.didUpdateImage(image: newImage, forIndex: cellIndex)

        picker.dismiss(animated: true) { [weak self] in
            self?.dismiss(animated: true, completion: nil) // Close the preview screen
        }
    }
}
