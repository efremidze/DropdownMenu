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
    var filteredItems = [String]()
    
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
    
    static let operationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    private var tableViewTopConstraint = NSLayoutConstraint()
    
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
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clearColor()
        tableView.clipsToBounds = false
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(tableView)
        
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
//        view.backgroundColor = .whiteColor()
//        view.autoresizingMask = .FlexibleWidth
//        let textField = UITextField(frame: view.bounds)
//        textField.placeholder = "Search"
//        textField.autoresizingMask = .FlexibleWidth
//        view.addSubview(textField)
//        tableView.addSubview(view)
//        tableView.tableHeaderView = view

        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        
        separatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(separatorView)
        
        let views = ["backgroundView": backgroundView, "tableView": tableView, "separatorView": separatorView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[separatorView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[separatorView(==0.5)]", options: nil, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView]|", options: nil, metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.frame.height))
        tableViewTopConstraint = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: -self.frame.height)
        self.addConstraint(tableViewTopConstraint)
    }
    
    func showMenu() {
        filteredItems = items
        tableView.reloadData()
        tableView.contentOffset.y = 44
        backgroundView.backgroundColor = maskBackgroundColor
        separatorView.backgroundColor = cellSeparatorColor
        tableView.frame.origin.y = -self.frame.height
        backgroundView.alpha = 0
        self.hidden = false
        tableViewTopConstraint.constant = 0
        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self.layoutIfNeeded()
            self.backgroundView.alpha = self.maskBackgroundOpacity
        }, completion: nil)
    }
    
    func hideMenu() {
        tableViewTopConstraint.constant = -self.frame.height
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
        return filteredItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: UITableViewCell.nameOfClass)
        if let item = filteredItems[safe: indexPath.row] {
            cell.textLabel?.text = item
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DropdownMenu: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let item = filteredItems[safe: indexPath.row] {
            didSelectItemAtIndexPath?(item, indexPath)
        }
        hideMenu()
    }
    
}

// MARK: - UIScrollViewDelegate
extension DropdownMenu: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 44 {
            var point = scrollView.contentOffset
            if (scrollView.contentOffset.y < 22) {
                point.y = 0
            } else {
                point.y = 44
            }
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension DropdownMenu: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        DropdownMenu.operationQueue.cancelAllOperations()
        DropdownMenu.operationQueue.addOperationWithBlock {
            if count(searchText) > 0 {
                var matches = [String]()
                var leftovers = Set(self.items)
                matches += leftovers.filter({ $0.lowercaseString.hasPrefix(searchText) })
                leftovers.subtractInPlace(matches)
                matches += leftovers.filter({ $0.lowercaseString.contains(searchText) })
                self.filteredItems = matches
            } else {
                self.filteredItems = self.items
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension NSObject {
    
    public class var nameOfClass: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
    
}

extension Array {
    
    subscript (safe index: Int) -> T? {
        return indices(self) ~= index ? self[index] : nil
    }
    
}

extension Set {
    
    func filter(includeElement: (T) -> Bool) -> Set<T> {
        return Set(Array(self).filter(includeElement))
    }
    
}

extension String {
    
    func contains(find: String) -> Bool {
        return self.rangeOfString(find) != nil
    }
    
}
