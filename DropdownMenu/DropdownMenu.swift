//
//  DropdownMenu.swift
//  DropdownMenu
//
//  Created by Lasha Efremidze on 9/2/15.
//  Copyright (c) 2015 Lasha Efremidze. All rights reserved.
//

import UIKit

private var _dropdownMenu: DropdownMenu?

extension UINavigationController {
    
    var dropdownMenu: DropdownMenu? {
        get {
            return _dropdownMenu
        }
        set {
            _dropdownMenu = newValue
        }
    }
    
}

// MARK: - DropdownMenu
class DropdownMenu: UIView {
    
    var showsSearchBar: Bool = false
    
    // handlers
    var didSelectItemAtIndexHandler: ((Int) -> ())?
    
    // private
    private var navigationController: UINavigationController?
    private let tableView = UITableView()
    private var items = [String]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(items: [String]) {
        super.init(frame: CGRect())
        
        self.items = items
    }
    
}

// MARK: - UITableViewDataSource
extension DropdownMenu: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return showsSearchBar ? 1 : 0
        }
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
            return cell
        }
        
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "UITableViewCell")
        cell.textLabel?.text = items[safe: indexPath.row]
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DropdownMenu: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.didSelectItemAtIndexHandler?(indexPath.row)
        }
    }
    
}

// MARK: - Extensions
extension Array {
    
    subscript (safe index: Int) -> T? {
        return indices(self) ~= index ? self[index] : nil
    }
    
}
