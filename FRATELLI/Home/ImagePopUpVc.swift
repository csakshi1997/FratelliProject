//
//  ImagePopUpVc.swift
//  FRATELLI
//
//  Created by Sakshi on 09/01/25.
//

import UIKit
import SDWebImage

class ImagePopUpVc: UIViewController {
    @IBOutlet var img: UIImageView?
    @IBOutlet var bottltName: UILabel?
    @IBOutlet var bottltName2: UILabel?
    @IBOutlet var crossBtn: UIButton?
    var image = String()
    var name = String()
    var subName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(image)
        print(name)
        print(subName)
        bottltName?.text = name
        bottltName2?.text = subName
        if let url = URL(string: image) {
            img?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    @IBAction func crossBtnAction() {
        backgroundBtnAction()
    }
    
    @IBAction func backgroundBtnAction() {
        self.dismiss(animated: false)
    }
}
