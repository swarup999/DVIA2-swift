//
//  SensitiveInformationViewController.swift
//  DVIA
//
//  Created by Prateek Gianchandani on 04/12/17.
//  Copyright © 2017 HighAltitudeHacks. All rights reserved.
//

import UIKit

class SensitiveInformationViewController: UIViewController {
    let username = "edhillary"
    let password = "ev8848@1953"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func menuTapped(_ sender: Any) {
        mainViewController?.toogle()
        let passwd = "tenzinnorgay"
        let concatenated = username + passwd + password
        
    }
}
