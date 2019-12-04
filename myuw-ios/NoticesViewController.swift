//
//  NoticesViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/13/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class NoticesViewController: CustomWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://my-dev-gcp.axdd.s.uw.edu/notices/")!
        webView.load(URLRequest(url: url))
        
        // override navigation title
        self.navigationItem.title = "Notices"
    }
    
}
