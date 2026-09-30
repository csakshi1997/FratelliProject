//
//  Extensions.swift
//  FRATELLI
//
//  Created by Sakshi on 18/10/24.
//

import UIKit
import Toast_Swift

extension UIImage {
    class func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 1.0, height: 1.0))
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
    }
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        // Clear any existing masks
        layer.mask = nil
        
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

extension UIColor {
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 {
            self.init("ff0000") // return red color for wrong hex input
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}

import UIKit

extension UIButton {
    func roundCornersOnRight(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    func roundCornersOnLeft(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
}


extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func removeSpecialCharacters(from string: String) -> String {
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_-=[]{}|:\"<>,./?")
        let components = string.components(separatedBy: specialCharacterSet)
        return components.joined()
    }
}

extension Array {
    
    var fancyString: String {
        let formatted = self.description.replacingOccurrences(of: " ", with: "")
        return formatted
    }
}

extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-,#=().!_")
        return self.filter {okayChars.contains($0) }
    }
}

extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UIViewController {
    func loader(isShown: Bool) {
        if isShown {
            self.view.makeToastActivity(ToastPosition.center)
            self.view.isUserInteractionEnabled = false
        } else {
            self.view.hideToastActivity()
            self.view.isUserInteractionEnabled = true
        }
    }
}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

extension UIImage {
    func getThumbnail() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: imageReference)
    }
}

//extension UIView {
//    func addShadow() {
//        self.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor.lightText.cgColor
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOpacity = 0.8
//        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)  // Shadow on bottom
//        self.layer.shadowRadius = 3.0
//    }
//}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView {
    func setLeftPaddingPointsTextView(_ amount: CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top, left: amount, bottom: self.textContainerInset.bottom, right: self.textContainerInset.right)
    }
    
    func setRightPaddingPointsTextView(_ amount: CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top, left: self.textContainerInset.left, bottom: self.textContainerInset.bottom, right: amount)
    }
}

extension UISearchBar {
    func setTextFieldLeftPadding(_ amount: CGFloat) {
        let textField = self.searchTextField
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
    }
    
    func setTextFieldRightPadding(_ amount: CGFloat) {
        let textField = self.searchTextField
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
    }
}

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
@IBDesignable
class LayoutableButton: UIButton {
    
    enum VerticalAlignment : String {
        case center, top, bottom, unset
    }
    
    
    enum HorizontalAlignment : String {
        case center, left, right, unset
    }
    
    
    @IBInspectable
    var imageToTitleSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    var imageVerticalAlignment: VerticalAlignment = .unset {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageHorizontalAlignment: HorizontalAlignment = .unset {
        didSet {
            setNeedsLayout()
        }
    }
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'imageVerticalAlignment' instead.")
    @IBInspectable
    var imageVerticalAlignmentName: String {
        get {
            return imageVerticalAlignment.rawValue
        }
        set {
            if let value = VerticalAlignment(rawValue: newValue) {
                imageVerticalAlignment = value
            } else {
                imageVerticalAlignment = .unset
            }
        }
    }
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'imageHorizontalAlignment' instead.")
    @IBInspectable
    var imageHorizontalAlignmentName: String {
        get {
            return imageHorizontalAlignment.rawValue
        }
        set {
            if let value = HorizontalAlignment(rawValue: newValue) {
                imageHorizontalAlignment = value
            } else {
                imageHorizontalAlignment = .unset
            }
        }
    }
    
    var extraContentEdgeInsets:UIEdgeInsets = UIEdgeInsets.zero
    
    override var contentEdgeInsets: UIEdgeInsets {
        get {
            return super.contentEdgeInsets
        }
        set {
            super.contentEdgeInsets = newValue
            self.extraContentEdgeInsets = newValue
        }
    }
    
    var extraImageEdgeInsets:UIEdgeInsets = UIEdgeInsets.zero
    
    override var imageEdgeInsets: UIEdgeInsets {
        get {
            return super.imageEdgeInsets
        }
        set {
            super.imageEdgeInsets = newValue
            self.extraImageEdgeInsets = newValue
        }
    }
    
    var extraTitleEdgeInsets:UIEdgeInsets = UIEdgeInsets.zero
    
    override var titleEdgeInsets: UIEdgeInsets {
        get {
            return super.titleEdgeInsets
        }
        set {
            super.titleEdgeInsets = newValue
            self.extraTitleEdgeInsets = newValue
        }
    }
    
    //Needed to avoid IB crash during autolayout
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.imageEdgeInsets = super.imageEdgeInsets
        self.titleEdgeInsets = super.titleEdgeInsets
        self.contentEdgeInsets = super.contentEdgeInsets
    }
    
    override func layoutSubviews() {
        if let imageSize = self.imageView?.image?.size,
           let font = self.titleLabel?.font,
           let textSize = self.titleLabel?.attributedText?.size() ?? self.titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: font]) {
            
            var _imageEdgeInsets = UIEdgeInsets.zero
            var _titleEdgeInsets = UIEdgeInsets.zero
            var _contentEdgeInsets = UIEdgeInsets.zero
            
            let halfImageToTitleSpacing = imageToTitleSpacing / 2.0
            
            switch imageVerticalAlignment {
            case .bottom:
                _imageEdgeInsets.top = (textSize.height + imageToTitleSpacing) / 2.0
                _imageEdgeInsets.bottom = (-textSize.height - imageToTitleSpacing) / 2.0
                _titleEdgeInsets.top = (-imageSize.height - imageToTitleSpacing) / 2.0
                _titleEdgeInsets.bottom = (imageSize.height + imageToTitleSpacing) / 2.0
                _contentEdgeInsets.top = (min (imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                _contentEdgeInsets.bottom = (min (imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                //only works with contentVerticalAlignment = .center
                contentVerticalAlignment = .center
            case .top:
                _imageEdgeInsets.top = (-textSize.height - imageToTitleSpacing) / 2.0
                _imageEdgeInsets.bottom = (textSize.height + imageToTitleSpacing) / 2.0
                _titleEdgeInsets.top = (imageSize.height + imageToTitleSpacing) / 2.0
                _titleEdgeInsets.bottom = (-imageSize.height - imageToTitleSpacing) / 2.0
                _contentEdgeInsets.top = (min (imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                _contentEdgeInsets.bottom = (min (imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                //only works with contentVerticalAlignment = .center
                contentVerticalAlignment = .center
            case .center:
                //only works with contentVerticalAlignment = .center
                contentVerticalAlignment = .center
                break
            case .unset:
                break
            }
            
            switch imageHorizontalAlignment {
            case .left:
                _imageEdgeInsets.left = -halfImageToTitleSpacing
                _imageEdgeInsets.right = halfImageToTitleSpacing
                _titleEdgeInsets.left = halfImageToTitleSpacing
                _titleEdgeInsets.right = -halfImageToTitleSpacing
                _contentEdgeInsets.left = halfImageToTitleSpacing
                _contentEdgeInsets.right = halfImageToTitleSpacing
            case .right:
                _imageEdgeInsets.left = textSize.width + halfImageToTitleSpacing
                _imageEdgeInsets.right = -textSize.width - halfImageToTitleSpacing
                _titleEdgeInsets.left = -imageSize.width - halfImageToTitleSpacing
                _titleEdgeInsets.right = imageSize.width + halfImageToTitleSpacing
                _contentEdgeInsets.left = halfImageToTitleSpacing
                _contentEdgeInsets.right = halfImageToTitleSpacing
            case .center:
                _imageEdgeInsets.left = textSize.width / 2.0
                _imageEdgeInsets.right = -textSize.width / 2.0
                _titleEdgeInsets.left = -imageSize.width / 2.0
                _titleEdgeInsets.right = imageSize.width / 2.0
                _contentEdgeInsets.left = -((imageSize.width + textSize.width) - max (imageSize.width, textSize.width)) / 2.0
                _contentEdgeInsets.right = -((imageSize.width + textSize.width) - max (imageSize.width, textSize.width)) / 2.0
            case .unset:
                break
            }
            
            _contentEdgeInsets.top += extraContentEdgeInsets.top
            _contentEdgeInsets.bottom += extraContentEdgeInsets.bottom
            _contentEdgeInsets.left += extraContentEdgeInsets.left
            _contentEdgeInsets.right += extraContentEdgeInsets.right
            
            _imageEdgeInsets.top += extraImageEdgeInsets.top
            _imageEdgeInsets.bottom += extraImageEdgeInsets.bottom
            _imageEdgeInsets.left += extraImageEdgeInsets.left
            _imageEdgeInsets.right += extraImageEdgeInsets.right
            
            _titleEdgeInsets.top += extraTitleEdgeInsets.top
            _titleEdgeInsets.bottom += extraTitleEdgeInsets.bottom
            _titleEdgeInsets.left += extraTitleEdgeInsets.left
            _titleEdgeInsets.right += extraTitleEdgeInsets.right
            
            super.imageEdgeInsets = _imageEdgeInsets
            super.titleEdgeInsets = _titleEdgeInsets
            super.contentEdgeInsets = _contentEdgeInsets
            
        } else {
            super.imageEdgeInsets = extraImageEdgeInsets
            super.titleEdgeInsets = extraTitleEdgeInsets
            super.contentEdgeInsets = extraContentEdgeInsets
        }
        
        super.layoutSubviews()
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.cornerRadius = 8
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = CGColor(red: 213.0 / 255.0, green: 214.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: -3, height: 3)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
    }

}


extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect?) {
        addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension TimeZone {
    func offsetInHours() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes)
        return tz_hr
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension UIView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}

extension UIButton {
    /// Add image on left view
    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

extension UITextView: @retroactive UIScrollViewDelegate {}
extension UITextView: @retroactive UITextViewDelegate {
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
        func setPlaceholder(_ placeholder: String) {
            let placeholderLabel = UILabel()
            placeholderLabel.text = placeholder
            placeholderLabel.font = UIFont.systemFont(ofSize: 14)
            placeholderLabel.textColor = .lightGray
            placeholderLabel.numberOfLines = 0
            placeholderLabel.tag = 100 // Optional tag to reference the placeholder

            // Add the placeholder label as a subview
            self.addSubview(placeholderLabel)
            
            // Constraints for placeholder positioning
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
            placeholderLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            placeholderLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        }
        
        func removePlaceholder() {
            if let placeholderLabel = self.viewWithTag(100) {
                placeholderLabel.removeFromSuperview()
            }
        }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding + 15
            let labelY = self.textContainerInset.top + 5
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 150
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor("#E6E6E6")
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

@IBDesignable
class PaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    @IBInspectable
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
}

extension UIView {
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1.0
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: CGFloat
        
        switch hexSanitized.count {
        case 3: // RGB
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
            alpha = 1.0
        case 6: // RRGGBB
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
            alpha = 1.0
        case 8: // RRGGBBAA
            red = CGFloat((rgb >> 24) & 0xFF) / 255.0
            green = CGFloat((rgb >> 16) & 0xFF) / 255.0
            blue = CGFloat((rgb >> 8) & 0xFF) / 255.0
            alpha = CGFloat(rgb & 0xFF) / 255.0
        default:
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func cgColor(from hex: String) -> CGColor? {
        guard let color = UIColor(hex: hex) else { return nil }
        return color.cgColor
    }
}


