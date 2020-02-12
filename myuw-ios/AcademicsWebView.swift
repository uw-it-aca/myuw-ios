//
//  AcademicsWebView.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class AcademicsWebView: WebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/academics/")
        
        // override navigation title
        self.navigationItem.title = "Academics"
    }
    
}
