//
//  HomeViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class HomeViewController: CustomWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let url = URL(string: "https://my-test.s.uw.edu/#uwalert-red")!
        let url = URL(string: "https://my-test.s.uw.edu/")!
        webView.load(URLRequest(url: url))
        
        // define custom user button
        let userButton = UIButton(type: .system)
        userButton.setImage(UIImage(named: "ic_user_18"), for: .normal)
        userButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        userButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5);
        userButton.setTitle(userNetID, for: .normal)
        userButton.sizeToFit()
        userButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
        // define custom search button
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage(named: "ic_search_18"), for: .normal)
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        searchButton.setTitle("Search", for: .normal)
        searchButton.sizeToFit()
        searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
        
        // define custom email button
        let emailButton = UIButton(type: .system)
        emailButton.setImage(UIImage(named: "ic_email_18"), for: .normal)
        emailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0);
        emailButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0);
        emailButton.setTitle("Email", for: .normal)
        emailButton.sizeToFit()
        emailButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
                        
        // add a user button in navbar programatically
        //let userBarButtonItem = UIBarButtonItem(title: userNetID, style: .plain,  target: self, action: #selector(showProfile))
        let userBarButtonItem = UIBarButtonItem(customView: userButton)
        
        //let emailBarButtonItem = UIBarButtonItem(title: "Email", style: .plain, target: self, action: #selector(showProfile))
        let emailBarButtonItem = UIBarButtonItem(customView: emailButton)
        
        //let searchBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(showSearch))
        let searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.navigationItem.leftBarButtonItem = userBarButtonItem
            
        self.navigationItem.rightBarButtonItems = [searchBarButtonItem, emailBarButtonItem]
        
        // pull to refresh setup
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
        webView.scrollView.refreshControl = refreshControl

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // override navigation title
        self.navigationItem.title = "MyUW"
    }
   
    
    // webview response handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    
    // webview action handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // handle links and navigation
        if navigationAction.navigationType == .linkActivated  {
            // check to see if the URL prefix is still myuw
            if let url = navigationAction.request.url, let host = url.host, !host.hasPrefix("my-test.s.uw.edu"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("navi: redirect to safari")
                decisionHandler(.cancel)
                
            } else {
                
                // open links by pushing a new view controller
                print("navi: push view controller: ", navigationAction.request.url!)
                
                let newViewController = NaviController()
                newViewController.visitUrl = navigationAction.request.url!.absoluteString
                                
                self.navigationController?.pushViewController(newViewController, animated: true)
                decisionHandler(.cancel)
                
                //decisionHandler(.allow)
                
            }
            
        } else {
            print("navi: not a user click, stay in webview")
            decisionHandler(.allow)
        }
    }
    

    @objc func showProfile() {
        
        // instantiate instance of ProfileViewController
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
                        
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
    
    @objc func showSearch() {
        // instantiate instance of SearchViewController
        let searchViewController = SearchViewController()
        // push view controller onto the stack
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }

}
