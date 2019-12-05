//
//  HuskyExpViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/13/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class HuskyExpViewController: CustomWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "\(appHost)/husky_experience/")!
        webView.load(URLRequest(url: url))
        
        // override navigation title
        self.navigationItem.title = "Husky Experience Toolkit"
    }
    
}
