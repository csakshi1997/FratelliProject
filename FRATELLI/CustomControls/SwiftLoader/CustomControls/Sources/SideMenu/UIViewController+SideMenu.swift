//
//  UIViewController+Extension.swift
//  SideMenu
//
//  Created by chaman
//  Copyright © 2021 chaman. All rights reserved.
//

import UIKit

// Provides access to the side menu controller
public extension UIViewController {

    /// Access the nearest ancestor view controller hierarchy that is a side menu controller.
    var sideMenuController: SideMenuController? {
        return findSideMenuController(from: self)
    }

    fileprivate func findSideMenuController(from viewController: UIViewController) -> SideMenuController? {
        var sourceViewController: UIViewController? = viewController
        repeat {
            sourceViewController = sourceViewController?.parent
            if let sideMenuController = sourceViewController as? SideMenuController {
                return sideMenuController
            }
        } while (sourceViewController != nil)
        return nil
    }
}
