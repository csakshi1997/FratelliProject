//
//  BubbleGroup.swift
//  TaskManagerApp
//
//  Created by Chaman Sharma on 14/05/23.
//

import UIKit

class BubbleModel {
    var imageUrl: String?
}

enum BubbleAlignment: Int {
    case left
    case right
}

@IBDesignable
class BubbleGroup: UIView {
    var itemArray = [BubbleModel]()
    var bubbleSelected: (() -> Void)?
    var bubbleAlignment: BubbleAlignment?
    var explicitlyWidth: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func bubbleAction() {
        self.bubbleSelected?()
    }
    
    func setupView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let bubbleHeight = self.frame.size.height
        let bubbleWidth = self.frame.size.height
        self.backgroundColor = .clear
        let totalBubbleShown = Int((explicitlyWidth ?? 0.0) / bubbleWidth)
        var xPosition = 0.0
        if totalBubbleShown > itemArray.count && bubbleAlignment == .right {
            xPosition = CGFloat(totalBubbleShown - itemArray.count) * bubbleWidth
            if itemArray.count > 1 {
                xPosition = xPosition + (bubbleWidth / 2.0)
            }
        }
        for index in 0..<totalBubbleShown {
            if index < itemArray.count {
                let bubbleModel = itemArray[index]
                
                let view = UIView(frame: CGRect(x: xPosition, y: 0, width: bubbleWidth, height: bubbleHeight))
                view.cornerRadius = bubbleHeight / 2.0
                view.borderColor = .white
                view.borderWidth = 2.0
                view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.addSubview(view)
                
                let userImage = UIImageView(frame: CGRect(x: 0, y: 0, width: bubbleWidth, height: bubbleHeight))
                userImage.layer.masksToBounds = true
                userImage.cornerRadius = bubbleHeight / 2.0
                userImage.image = UIImage(named: "Avatar")
                if !((bubbleModel.imageUrl ?? EMPTY).isEmpty) {
                }
                view.addSubview(userImage)
                
                let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bubbleWidth, height: bubbleHeight))
                nameLabel.cornerRadius = bubbleHeight / 2.0
                nameLabel.textColor = .white
                nameLabel.textAlignment = .center
                nameLabel.font = UIFont(name: "Poppins-Bold", size: 10)
                if index == totalBubbleShown - 1 {
                    let restCount = itemArray.count - totalBubbleShown
                    nameLabel.text = "+\(restCount)"
                } else {
                    nameLabel.text = EMPTY
                }
                xPosition = xPosition + (bubbleWidth / 2.0)
            }
        }
        
        let button = UIButton(frame: CGRect(x: xPosition, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        button.addTarget(self, action: #selector(bubbleAction), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.clear
        self.addSubview(button)
    }
}
