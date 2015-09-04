//
//  ViewController.swift
//  DropdownMenuDemo
//
//  Created by Lasha Efremidze on 9/2/15.
//  Copyright (c) 2015 Lasha Efremidze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .redColor()
        
        let button = UIButton.buttonWithType(.System) as! UIButton
        button.setTitle("Toggle Menu", forState: .Normal)
        button.addTarget(self, action: "didTouchOnButton:", forControlEvents: .TouchUpInside)
        self.navigationItem.titleView = button
        
        let dropdownMenu = DropdownMenu(items: ["1", "2"])
        dropdownMenu.didSelectItemAtIndexPath = { item, _ in
            println(item)
        }
        self.navigationController?.dropdownMenu = dropdownMenu
    }

    @IBAction func didTouchOnButton(sender: UIButton) {
        self.navigationController?.dropdownMenu?.toggleMenu()
    }
    
}

