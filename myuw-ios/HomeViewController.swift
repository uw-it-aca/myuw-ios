//
//  HomeViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import WebKit

class HomeViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        let url = URL(string: "https://my-test.s.uw.edu/")!
        webView.load(URLRequest(url: url))
        
        // override navigation title
        self.navigationItem.title = "MyUW"
                
        // add a right button in navbar programatically
        let testUIBarButtonItem = UIBarButtonItem(title: userNetID, style: .plain, target: self, action: #selector(showProfile))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
    
        
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
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
                
        self.view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    // webview response handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        // get the cookies
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            //debugPrint(cookies.debugDescription)
            print("** home view **********")
            for cookie in cookies {
                print("name: \(cookie.name) value: \(cookie.value)")
            }
        }

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
                print("redirect to safari")
                decisionHandler(.cancel)
                
            } else {
                print("open it locall in webview")
                decisionHandler(.allow)
            }
            
        } else {
            print("not a user click, stay in webview")
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
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }

}
