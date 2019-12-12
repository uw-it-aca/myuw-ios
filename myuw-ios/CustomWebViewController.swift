//
//  CustomWebViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/15/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class CustomWebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
       
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        // initially set to .never to prevent webview auto scrolling
        //webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false

        

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = true
        
        //view.addSubview(activityIndicator)
        
        /*
        // pull to refresh setup
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .purple
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
        webView.scrollView.refreshControl = refreshControl
        refreshControl.backgroundColor = .gray
        */
        
        // loading observer
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        
        view.addSubview(activityIndicator)
        
        view.addSubview(webView)
        
                    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            if webView.isLoading {
                print("isLoading")
            } else {
                print("done Loading")
            }
        }
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
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        print("refreshWebView")
        // clear the webview body and then reload
        //webView.evaluateJavaScript("document.body.remove()")
        //webView.scrollView.clearsContextBeforeDrawing = true
                
        webView.reload()
        sender.endRefreshing()
    }
    
    
    // webview navigation handlers
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // on webview start... set to .never to prevent webview auto scrolling
        //webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(activityIndicator)
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // on webview finish... set scroll behavior back to automatic
        //webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // pull to refresh setup
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .purple
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
        webView.scrollView.refreshControl = refreshControl
        refreshControl.backgroundColor = .gray
        
        view.addSubview(webView)
        showActivityIndicator(show: false)
        
        let url = webView.url
        print("navi webview url: ", url as Any)
        
        // dynamically inject myuw.css file into webview
        /*
        guard let path = Bundle.main.path(forResource: "myuw", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        */
        
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
            var request = URLRequest(url: url)
            request.setValue("True", forHTTPHeaderField: "Myuw-Hybrid")
            load(request)
        }
    }
}
