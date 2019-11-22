//
//  NaviController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/5/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class NaviController: UIViewController, WKNavigationDelegate {
    
    var visitUrl:String = ""
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self
        
        //self.view = webView
        view.addSubview(webView)
        
        let url = URL(string: visitUrl)!
        webView.load(URLRequest(url: url))
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = true

        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
        
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        showActivityIndicator(show: false)
        
        // override navigation title
        self.navigationItem.title = webView.title
        
        // mocking this for now
        //self.navigationItem.title = "Page Title"
        //self.navigationController?.navigationBar.backItem?.title = "Back"
        
        // dynamically inject css file into webview
        guard let path = Bundle.main.path(forResource: "myuw", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
    }
    
    // webview policy response handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
       decisionHandler(.allow)
    }
   
    // webview policty action handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
        // handle links and navigation
        if navigationAction.navigationType == .linkActivated  {
            
            let url = navigationAction.request.url
            let host = url?.host
            
            print("navi url: ", url as Any)
            print("navi host: ", host as Any)
            
            // check to see if the URL prefix is still myuw
            if !host!.hasPrefix("my-test.s.uw.edu"), UIApplication.shared.canOpenURL(url!) {
                
                UIApplication.shared.open(url!)
                print("navi: redirect to safari")
                decisionHandler(.cancel)
                
            } else if (url?.absoluteString.contains("out?u="))! {
                
                // check for outbound myuw links
                UIApplication.shared.open(url!)
                print("navi: redirect to safari")
                decisionHandler(.cancel)
                
            } else {
                        
                // open links by pushing a new view controller
                print("navi: push view controller")
    
                let newViewController = NaviController()
                newViewController.visitUrl = navigationAction.request.url!.absoluteString
                               
                self.navigationController?.pushViewController(newViewController, animated: true)
                decisionHandler(.cancel)
               
            }
           
        }
        else {
           decisionHandler(.allow)
        }
    }
    
    
}

