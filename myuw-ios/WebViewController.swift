//
//  WebViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/15/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit
import os

// singleton class for a shared WKProcessPool
class ProcessPool {
    static var accessToken = String()
    static var idToken = String()
    static var sharedPool = WKProcessPool()
}

class WebViewController: UIViewController, WKNavigationDelegate {
    
    let headerText = UILabel()
    let bodyText = UILabel()
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    //Set true when we have to update navigationBar height in viewLayoutMarginsDidChange()
    var didChange = false
    
    // TODO: - this is the stackoverflow fix for the large title/webview issues
    // FYI: - this seems to work on all views EXCEPT teaching and academics tabs
    override func viewLayoutMarginsDidChange() {
        if didChange {
            // set NavigationBar Height here
            self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 96.0)
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
        
        // MARK: JS bridge message handler
        configuration.userContentController.add(self, name: "myuwBridge")
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        
        // set the custom user agent
        configuration.applicationNameForUserAgent = "MyUW_Hybrid/1.0 (iPhone)"
        
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.isUserInteractionEnabled = true
        webView.allowsLinkPreview = false
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
        
        // test getting all cookies

        // get all cookies
        webView.getCookies() { data in
              print("=========================================")
              print(data)
        }
                
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
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        
        os_log("refreshWebView", log: .webview, type: .info)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // check if connected to network on refresh
        if (appDelegate.isConnectedToNetwork()) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            webView.reload()
            sender.endRefreshing()
        }
        else {
            let errorController = ErrorController()
            let navController = UINavigationController(rootViewController: errorController)
            appDelegate.window!.rootViewController = navController
        }
    }
    
    // webview navigation handlers
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        os_log("didStartProvisionalNavigation", log: .webview, type: .info)
        didChange = true
    }
    
    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError)
    {
        if(error.code == NSURLErrorNotConnectedToInternet) {
            os_log("HTTP request failed: %@", log: .webview, type: .error, error.localizedDescription)
            
            // show error controller
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let errorController = ErrorController()
            let navController = UINavigationController(rootViewController: errorController)
            appDelegate.window!.rootViewController = navController
            
            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        didChange = true
        
        let url = webView.url?.absoluteURL
        
        os_log("webview url: %@", log: .webview, type: .info, url!.absoluteString)
        
    }
    
    // webview policy response handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            
            if response.statusCode == 500 {
                os_log("HTTP response was 500!", log: .webview, type: .error)
                // show error controller
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let errorController = ErrorController()
                let navController = UINavigationController(rootViewController: errorController)
                appDelegate.window!.rootViewController = navController
            }
        }
        
        decisionHandler(.allow)
    }
    
    // webview policty action handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // handle links and navigation
        if navigationAction.navigationType == .linkActivated  {
            
            let url = navigationAction.request.url
            os_log("navi url: %@", log: .webview, type: .info, url!.absoluteString)
            
            // check to see if the url is NOT my-test.s.uw.edu (myuw)
            if !url!.absoluteString.contains("\(appHost)"), UIApplication.shared.canOpenURL(url!) {
                
                // open outbound url in safari
                UIApplication.shared.open(url!)
                os_log("navi: redirect to safari", log: .webview, type: .info)
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
                os_log("navi: redirect to safari", log: .webview, type: .info)
                decisionHandler(.cancel)
                
            } else {
                
                // open links by pushing a new view controller
                os_log("navi: push view controller", log: .webview, type: .info)
                
                let newVisit = VisitController()
                newVisit.visitUrl = navigationAction.request.url!.absoluteString
                
                os_log("navi new visit: %@", log: .webview, type: .info, newVisit.visitUrl)
                
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
            
            // pass the idToken via authorization header
            os_log("loading idToken: %@", log: .webview, type: .info, ProcessPool.idToken)
            
            // pass the authorization bearer token in request header
            request.setValue("Bearer \(ProcessPool.idToken)", forHTTPHeaderField: "Authorization")
            request.setValue("\(deviceID ?? "DEVICE_ID")", forHTTPHeaderField: "UW-Device-ID")
            
            // load the request
            os_log("loading request: %@", log: .webview, type: .info, url.absoluteString)
            load(request)
        }
    }
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    
    // listen for messages coming from myuw via the jsbridge
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "myuwBridge" {
            
            // get the message received from myuw web
            os_log("bridge message: %@", log: .jsbridge, type: .info, (message.body as? String)!)
            
        }
    }
}

extension OSLog {
    // subsystem
    private static var subsystem = Bundle.main.bundleIdentifier!
    // log categories
    static let webview = OSLog(subsystem: subsystem, category: "WebView")
    static let jsbridge = OSLog(subsystem: subsystem, category: "JSBridge")
}

