//
//  AppDelegate.swift
//  myuw-test
//
//  Created by University of Washington on 7/30/19.
//  Copyright © 2019 University of Washington. All rights reserved.
//

import UIKit
import AppAuth
import SystemConfiguration
import os

// From myuw.plist
var appHost = ""
var appAffiliationEndpoint = ""
var clientID = ""
var clientIssuer = ""
var linkEULA = ""
var linkPrivacy = ""
var linkTerms = ""
var linkHelp = ""

struct User {
    // From Shibboleth iDP via OIDC
    static var userAffiliations: [String] = []
    static var userNetID = ""
}

// base theme color (uw purple)
let uwPurple = UIColor(hex: "#4b2e83")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // property of the app's AppDelegate (appAuth)
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        os_log("didFinishLaunchingWithOptions", log: .appDelegate, type: .info)
        
        // read in config
        if let path = Bundle.main.path(forResource: "myuw", ofType: "plist"), let config = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            appHost = config["myuw_host"] as! String
            appAffiliationEndpoint = config["myuw_affiliation"] as! String
            clientIssuer = config["oidc_issuer"] as! String
            clientID = config["oidc_clientid"] as! String
            linkEULA = config["link_eula"] as! String
            linkPrivacy = config["link_privacy"] as! String
            linkTerms = config["link_terms"] as! String
            linkHelp = config["link_help"] as! String
        }
        
        // setup navbar appearance globally
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = uwPurple
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().barTintColor = uwPurple
            UINavigationBar.appearance().isTranslucent = false
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    
        if isConnectedToNetwork() {
            
            // force use go through appAuth flow when foregrounding the app
            UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: AppAuthController())
            
        } else {
            
            // show the error controller if no network connection
            UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: ErrorController())
        }
        
        return true
    }

    // handle appauth
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

       if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
           self.currentAuthorizationFlow = nil
           return true
       }

       return false
   }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
            
        os_log("applicationWillEnterForeground", log: .appDelegate, type: .info)
        
        // force use go through appAuth flow when foregrounding the app
        UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: AppAuthController())
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate {
    
    //https:\//stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift
    
    func isConnectedToNetwork() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

    func getFlags() -> SCNetworkReachabilityFlags? {
        guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
            return nil
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return nil
        }
        return flags
    }

    func ipv6Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin6_family = sa_family_t(AF_INET6)

        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }

    func ipv4Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }

}

extension UIColor {
    public convenience init?(hex: String) {
        
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
  
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0
                    a = CGFloat(1.0)

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }

        }

        return nil
    }
}

extension OSLog {
    // log setup
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let appDelegate = OSLog(subsystem: subsystem, category: "AppDelegate")
}
