//
//  CustomTextField.swift
//  FRATELLI
//
//  Created by Sakshi on 20/11/24.
//

import UIKit

class CustomTextField: UITextField {
    
    private let placeholderLabel = UILabel()
    private var placeholderFont: UIFont?
    
    override var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Setup the placeholder label
        placeholderLabel.font = font
        placeholderFont = font
        placeholderLabel.textColor = .gray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        
        // Constraints for the placeholder label
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8) // Start from top when floating
        ])
        
        // Style the text field
        borderStyle = .none
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 8
        
        // Add editing actions
        addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
    }
    
    @objc private func editingBegan() {
        if text?.isEmpty ?? true {
            animatePlaceholder(up: true)
        }
    }
    
    @objc private func editingEnded() {
        if text?.isEmpty ?? true {
            animatePlaceholder(up: false)
        }
    }
    
    private func animatePlaceholder(up: Bool) {
        let yOffset: CGFloat = up ? -bounds.height / 2 : 0
        let xOffset: CGFloat = 8 // Keeps the horizontal alignment consistent with the left padding
        
        UIView.animate(withDuration: 0.3) {
            self.placeholderLabel.transform = CGAffineTransform(translationX: xOffset, y: yOffset)
            self.placeholderLabel.font = up ? UIFont.systemFont(ofSize: 12) : self.placeholderFont
            self.placeholderLabel.textColor = UIColor(red: 114.0 / 255.0, green: 47.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        }
    }
}
