//
//  CustomWebViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/15/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit
import AppAuth // import just to test if framework is installed

class CustomWebViewController: UIViewController, WKNavigationDelegate {
    
    var deepAction = ""
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    //Set true when we have to update navigationBar height in viewLayoutMarginsDidChange()
    var didChange = false
    
    // TODO: - this is the stackoverflow fix for the large title/webview issues
    // FYI: - this seems to work on all views EXCEPT teaching and academics tabs
    override func viewLayoutMarginsDidChange() {
        //print("viewLayoutMarginsDidChange: ", didChange)
        if didChange {
            //print("old Height : - \(String(describing: self.navigationController?.navigationBar.frame.size.height))")
            // set NavigationBar Height here
            self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 96.0)
            //print("new Height : - \(String(describing: self.navigationController?.navigationBar.frame.size.height))")
            didChange = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // MARK: - WKWebView setup and configuration
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        configuration.applicationNameForUserAgent = "MyUW_Hybrid/1.0 (iPhone)"
       
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
                
        webView.isUserInteractionEnabled = true
        webView.allowsLinkPreview = false
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
                
        // loading observer
        //webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
                
        view.addSubview(webView)
        
        // MARK: - Add activity indicator to indicate webview initial load
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = webView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        webView.addSubview(activityIndicator)
    
        // MARK:- Pull to refresh setup
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        // assign refreshControl for the webview
        webView.scrollView.refreshControl = refreshControl
      
    }
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            if webView.isLoading {
                print("isLoading")
                
                
            } else {
                print("done Loading")
                didChange = true
            }
        }
    }
    */
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        print("refreshWebView")
        webView.reload()
        sender.endRefreshing()
    }
    
    // webview navigation handlers
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("didStartProvisionalNavigation")
        didChange = true
        
        // MARK: - Webview activity indicator
        /*
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        webView.addSubview(activityIndicator)
        */
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // TODO: handle when website fails to load
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        didChange = true
        
        let url = webView.url?.absoluteURL
        print("navi webview url: ", url as Any)
        
        // handle deep actions
        if (deepAction.count > 0) {
            print(deepAction)
            webView.evaluateJavaScript(deepAction)
            deepAction = ""
        }
    
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
            print("navi url: ", url as Any)
                            
            // check to see if the url is NOT my-test.s.uw.edu (myuw)
            if !url!.absoluteString.contains("\(appHost)"), UIApplication.shared.canOpenURL(url!) {
                
                // open outbound url in safari
                UIApplication.shared.open(url!)
                print("navi: redirect to safari")
                decisionHandler(.cancel)
                
            }
            // check to see if the url is a "special" myuw outbound link
            else if (url?.absoluteString.contains("out?u="))! {
                // get the outbound url from the u param
                let uParam = getQueryStringParameter(url: url!.absoluteString, param: "u")
                // convert string back to url type
                let outbound = URL(string: uParam!)
                
                // open outbound url in safari
                UIApplication.shared.open(outbound!)
                print("navi: redirect to safari")
                decisionHandler(.cancel)
                
            } else {
                        
                // open links by pushing a new view controller
                print("navi: push view controller")
    
                let newVisit = CustomVisitController()
                newVisit.visitUrl = navigationAction.request.url!.absoluteString
                
                print(newVisit.visitUrl)
                
                self.navigationController?.pushViewController(newVisit, animated: true)
                decisionHandler(.cancel)
               
            }
           
        }
        else {
           decisionHandler(.allow)
        }
    }
    
    // function to get params from a url string
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
}

// extensions
extension WKWebView {
    
    // custom load extension that sets custom header
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
