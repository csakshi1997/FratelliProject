//
//  UIView+Container.swift
//  SideMenu
//
//  Created by chaman
//  Copyright © 2021 chaman. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            // swiftlint:disable:next force_unwrapping
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    var parentNavigationController: UINavigationController? {
        let currentViewController = parentViewController
        if let navigationController = currentViewController as? UINavigationController {
            return navigationController
        }
        return currentViewController?.navigationController
    }
}
