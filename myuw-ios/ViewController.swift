//
//  ViewController.swift
//  myuw-test
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UINavigationController {
    
    override func viewDidLoad() {

        // Do any additional setup after loading the view.
         
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemPink
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().barTintColor = .systemPink
            UINavigationBar.appearance().isTranslucent = false
        }
        
        
        //let url = URL(string: "https://my-test.s.uw.edu/")!
        //webView.load(URLRequest(url: url))
        
        // add a right button in navbar programatically
        let testUIBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(showProfile))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
        
        self.title = "Login"
    }
    
    /*
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           
        // set the title using the webpage title
        //title = webView.title
        // set the title manually
        title = "MyUW"
        print("webview didFinish")
        //webView.evaluateJavaScript("alert('hello');")
                
    }
    */
    
    @objc func showProfile() {
        
        // instantiate instance of ProfileViewController
        let profileViewController = ProfileViewController()
                
        // set style of how view controller is to be presented
        if #available(iOS 13.0, *) {
            profileViewController.modalPresentationStyle = .automatic
        } else {
            // fallback on earlier versions
            profileViewController.modalPresentationStyle = .formSheet
        }
        
        // present the profile view controller
        present(profileViewController, animated: true, completion: nil)

    }

}
