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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // MARK: - WKWebView setup and configuration
        let configuration = WKWebViewConfiguration()
        let wkDataStore = WKWebsiteDataStore.default()
                
        // MARK: JS bridge message handler
        configuration.userContentController.add(self, name: "myuwBridge")
        
        // MARK: global data store and process pool
        configuration.websiteDataStore = wkDataStore
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
        
        // MARK: - fixes the large title/webview shrink issue
        // https://stackoverflow.com/questions/51686968/preferslargettitles-collapses-automatically-after-loading-wkwebview-webpage
        // set webview scrollview to never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
    }
    
    // signout
    @objc func signOut() {
        
        os_log("Perform webview sign out", log: .webview, type: .info)
        
        // dismiss the profile webview in case it is trying to load in the background
        self.dismiss(animated: true, completion: nil)
        
        os_log("Signing user out of webview", log: .webview, type: .info)
        
        // visit /logout to perform webview signout
        webView.load("\(appHost)/logout/")
    
    }
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        
        os_log("refreshWebView", log: .webview, type: .info)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // check if connected to network on refresh
        if (appDelegate.isConnectedToNetwork()) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            // set webview scrollview to never
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            
            webView.reload()
            sender.endRefreshing()
        }
        else {
            // show error controller
            UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: ErrorController())
        }
    }
    
    // webview navigation handlers
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        os_log("didStartProvisionalNavigation", log: .webview, type: .info)
    }
    
    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError)
    {
        if(error.code == NSURLErrorNotConnectedToInternet) {
            os_log("HTTP request failed: %@", log: .webview, type: .error, error.localizedDescription)
                        
            // show error controller
            UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: ErrorController())
            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        os_log("didFinish", log: .webview, type: .info)
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
                
        let url = webView.url?.absoluteURL
        
        os_log("webview url: %@", log: .webview, type: .info, url!.absoluteString)
        
        // if user signed out... then clear authstate
        if url!.absoluteString.contains("/logout/") {
                        
            // call the appAuth signout method
            let appAuthController = AppAuthController()
            appAuthController.signOut()
    
            // show the appAuth controller
            UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: appAuthController)
            
        }
        
        // display all cookies in WKWebsiteDataStore
        webView.getCookies() { data in
            os_log("webview cookies: %@", log: .webview, type: .info, data)
        }
    }
    
    // webview policy response handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            
            //let statusMessage: String = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            //let statusMessage: String = response.description
            
            os_log("HTTP response: %@", log: .webview, type: .error, response.statusCode.description)
            
            // handle 500 and 503
            if (response.statusCode == 500 || response.statusCode == 503) {
                //os_log("HTTP response message: %@", log: .webview, type: .error, statusMessage)
              
                // show error controller
                UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: ErrorController())
                
            }
            
            if response.statusCode == 401 {
                //os_log("HTTP response message: %@", log: .webview, type: .error, statusMessage)
                
                //MARK: option #1 clear authState and sign user out
                //PROBLEM: signout makes a visit to /logout - this will cause a 401 loop since /logout will reject invalid tokens with a 401
                // signOut()
                
                // stop the webview reqeust
                webView.stopLoading()
                
                //MARK: option #2 refresh tokens by going through appAuthController
                UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: AppAuthController())
                
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
            
            // load the request
            os_log("loading request: %@", log: .webview, type: .info, url.absoluteString)
            os_log("loading headers: %@", log: .webview, type: .info, request.allHTTPHeaderFields!)
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

