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
        
        let dropdownMenu = DropdownMenu(items: ["1", "2"])
        self.navigationController?.dropdownMenu = dropdownMenu
    }

}

