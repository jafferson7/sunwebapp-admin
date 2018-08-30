//
//  AccountViewController.swift
//  SunWebApp
//
//  Created by Usmaan Jaffer on 8/30/18.
//  Copyright © 2018 Usmaan Jaffer. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userName = UserDefaults.standard.string(forKey: "name")
        
        nameLabel.text = "Hello \(userName!)"
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

