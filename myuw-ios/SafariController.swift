//
//  SafariController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SafariController: UIViewController, SFSafariViewControllerDelegate {
    
    var isLogged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("safari control: viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("safari control: viewDidAppear")
        print("isLogged", isLogged)
        
        if isLogged {
            // tabController (main) and appDelegate instance
            let tabController = TabViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // set tabControlleer as rootViewController after login
            appDelegate.window!.rootViewController = tabController
        } else {
            let url = URL(string: "https://my-test.s.uw.edu/")!
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            present(svc, animated: false)
        }
        
    }
    
    // Called on "Done" button
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("done clicked")
        dismiss(animated: false, completion: nil)
        isLogged = true
    }
    

    
}
