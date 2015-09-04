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
    
    // handlers
    var didSelectItemAtIndexPath: ((String, NSIndexPath) -> ())?
    
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
    
    private var tableViewTopConstraint = NSLayoutConstraint()
    
    private let tableHeaderViewHeight = CGFloat(300)
    
    private var tableViewHeight: CGFloat {
        return tableHeaderViewHeight + self.frame.height
    }
    
    convenience init(items: [String]) {
        self.init(frame: CGRect())
        
        self.items = items
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let navigationController = navigationController {
            var frame = navigationController.view.bounds
            frame.origin.y = navigationController.navigationBar.frame.maxY
            frame.size.height -= frame.origin.y
            self.frame = frame
        }
        self.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.clipsToBounds = true
        self.hidden = true
        
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(backgroundView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: tableHeaderViewHeight))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clearColor()
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(tableView)
        
        separatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(separatorView)
        
        let views = ["backgroundView": backgroundView, "tableView": tableView, "separatorView": separatorView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[separatorView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[separatorView(==0.5)]", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView]|", options: nil, metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: tableViewHeight))
        tableViewTopConstraint = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: -tableViewHeight)
        self.addConstraint(tableViewTopConstraint)
    }
    
    func showMenu() {
        backgroundView.backgroundColor = maskBackgroundColor
        tableView.tableHeaderView?.backgroundColor = cellBackgroundColor
        separatorView.backgroundColor = cellSeparatorColor
        tableView.frame.origin.y = -self.frame.height
        backgroundView.alpha = 0
        self.hidden = false
        tableViewTopConstraint.constant = -tableHeaderViewHeight
        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self.layoutIfNeeded()
            self.backgroundView.alpha = self.maskBackgroundOpacity
        }, completion: nil)
    }
    
    func hideMenu() {
        tableViewTopConstraint.constant = -tableViewHeight
        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration, animations: {
            self.layoutIfNeeded()
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.hidden = true
        })
    }
    
    func toggleMenu() {
        if self.hidden {
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
        let item = items[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DropdownMenu: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = items[indexPath.row]
        didSelectItemAtIndexPath?(item, indexPath)
        hideMenu()
    }
    
}
