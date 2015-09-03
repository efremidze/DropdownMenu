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
            let oldValue = _dropdownMenu
            _dropdownMenu = newValue
            if let newValue = newValue where oldValue == nil {
                newValue.navigationController = self
                self.view.addSubview(newValue)
            } else if newValue == nil {
                oldValue?.removeFromSuperview()
            }
        }
    }
    
}

// MARK: - DropdownMenu
class DropdownMenu: UIView {
    
    var items = [String]()
    
    var isShown = false
    
    // configuration
    var animationDuration: NSTimeInterval = 0.5
    var maskBackgroundColor: UIColor = .blackColor()
    var maskBackgroundOpacity: CGFloat = 0.3
    var cellBackgroundColor: UIColor = .whiteColor()
    var cellSeparatorColor: UIColor = .blackColor()
    
    // private
    private var navigationController: UINavigationController?
    private let backgroundView = UIView()
    private let tableView = UITableView()
    private let separatorView = UIView()
    
    convenience init(items: [String]) {
        self.init(frame: CGRect())
        
        self.items = items
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let newSuperview = newSuperview {
            self.frame = newSuperview.bounds
        }
        if let navigationController = navigationController {
            self.frame.origin.y = navigationController.navigationBar.frame.maxY
            self.frame.size.height -= self.frame.origin.y
        }
        self.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.clipsToBounds = true
        
        backgroundView.backgroundColor = self.maskBackgroundColor
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 300))
        tableHeaderView.backgroundColor = self.cellBackgroundColor
        tableView.tableHeaderView = tableHeaderView
        
        tableView.frame = self.bounds
        tableView.frame.origin.y = -self.frame.height
        tableView.frame.size.height += tableHeaderView.frame.height
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clearColor()
        
        self.addSubview(backgroundView)
        self.addSubview(tableView)
        
        separatorView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)
        separatorView.autoresizingMask = .FlexibleWidth
        separatorView.backgroundColor = cellSeparatorColor
        self.addSubview(separatorView)
        
        self.hidden = true
    }
    
    func showMenu() {
        tableView.frame.origin.y = -self.frame.height
        backgroundView.alpha = 0
        self.hidden = false
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self.tableView.frame.origin.y = -(self.tableView.tableHeaderView?.frame.size.height ?? 0)
            self.backgroundView.alpha = self.maskBackgroundOpacity
        }, completion: nil)
    }
    
    func hideMenu() {
        self.backgroundView.alpha = self.maskBackgroundOpacity
        UIView.animateWithDuration(animationDuration, animations: {
            self.tableView.frame.origin.y = -self.frame.height
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.hidden = true
        })
    }
    
    func toggleMenu() {
        isShown = !isShown
        if isShown {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
}

// MARK: - UITableViewDataSource
extension DropdownMenu: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "UITableViewCell")
        cell.textLabel?.text = items[safe: indexPath.row]
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DropdownMenu: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

// MARK: - Extensions
extension Array {
    
    subscript (safe index: Int) -> T? {
        return indices(self) ~= index ? self[index] : nil
    }
    
}
