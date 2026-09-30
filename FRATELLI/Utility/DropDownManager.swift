//
//  DropDownManager.swift
//  FRATELLI
//
//  Created by Sakshi on 17/01/25.
//

import Foundation
import DropDown
import UIKit

class DropdownManager {
    private var dropdown: DropDown
    private var onSelect: ((String, String) -> Void)?
    private var dataMap: [String: String] = [:]
    
    init() {
        dropdown = DropDown()
        configureDropdown()
    }
    
    private func configureDropdown() {
        dropdown.direction = .bottom
        dropdown.dismissMode = .automatic
    }
    
    func setupDropdown(for textField: UITextField, with data: [String: String], selectionHandler: @escaping (String, String) -> Void) {
            dataMap = data
            onSelect = selectionHandler

            dropdown.anchorView = textField
            dropdown.dataSource = Array(data.keys)
            dropdown.bottomOffset = CGPoint(x: 0, y: textField.frame.height)

            dropdown.selectionAction = { [weak self] index, item in
                guard let self = self else { return }
                textField.text = item
                if let id = self.dataMap[item] {
                    self.onSelect?(item, id)
                }
            }
        }

    
    func filterDropdown(with query: String) {
        print("Filtering dropdown with query: \(query)")
        print(dataMap)
        if query.isEmpty {
            dropdown.dataSource = Array(dataMap.keys)
        } else {
            dropdown.dataSource = dataMap.keys.filter { $0.lowercased().contains(query.lowercased()) }
        }
        dropdown.reloadAllComponents()
    }
    
    func showDropdown() {
        dropdown.show()
    }
    
    func hideDropdown() {
        dropdown.hide()
    }
}
