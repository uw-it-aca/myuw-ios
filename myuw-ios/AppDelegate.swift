//
//  AppDelegate.swift
//  myuw-test
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import AppAuth
import SystemConfiguration
import os

// From system
let deviceID = UIDevice.current.identifierForVendor?.uuidString

// From myuw.plist
var appHost = ""
var appAffiliationEndpoint = ""
var clientID = ""
var clientIssuer = ""

struct User {
    // From Shibboleth iDP via OIDC
    static var userAffiliations: [String] = []
    static var userNetID = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // property of the app's AppDelegate (appAuth)
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // read in config
        if let path = Bundle.main.path(forResource: "myuw", ofType: "plist"), let config = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            appHost = config["myuw_host"] as! String
            appAffiliationEndpoint = config["myuw_affiliation"] as! String
            clientIssuer = config["oidc_issuer"] as! String
            clientID = config["oidc_clientid"] as! String
        }
        
        // setup navbar appearance globally
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(hex: "#4b2e83")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().barTintColor = UIColor(hex: "#4b2e83")
            UINavigationBar.appearance().isTranslucent = false
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    
        if isConnectedToNetwork() {
            // force use go through appAuth flow when foregrounding the app
            let appAuthController = AppAuthController()
            let navController = UINavigationController(rootViewController: appAuthController)
            // set appAuth controller as rootViewController
            window!.rootViewController = navController
        } else {            
            let errorController = ErrorController()
            let navController = UINavigationController(rootViewController: errorController)
            // set appAuth controller as rootViewController
            window!.rootViewController = navController
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
            
        os_log("applicationWillEnterForeground", log: .ui, type: .info)
        
        // force use go through appAuth flow when foregrounding the app
        let appAuthController = AppAuthController()
        let navController = UINavigationController(rootViewController: appAuthController)
        // set appAuth controller as rootViewController
        window!.rootViewController = navController
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

public extension UIColor {
    
    //https:\//theswiftdev.com/2018/05/03/uicolor-best-practices-in-swift/
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(hex string: String, alpha: CGFloat = 1.0) {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        
        if hex.count < 3 {
            hex = "\(hex)\(hex)\(hex)"
        }
        
        if hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) != nil {
            if hex.count == 3 {
                
                let startIndex = hex.index(hex.startIndex, offsetBy: 1)
                let endIndex = hex.index(hex.startIndex, offsetBy: 2)
                
                let redHex = String(hex[..<startIndex])
                let greenHex = String(hex[startIndex..<endIndex])
                let blueHex = String(hex[endIndex...])
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            
            let startIndex = hex.index(hex.startIndex, offsetBy: 2)
            let endIndex = hex.index(hex.startIndex, offsetBy: 4)
            let redHex = String(hex[..<startIndex])
            let greenHex = String(hex[startIndex..<endIndex])
            let blueHex = String(hex[endIndex...])
            
            var redInt: CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt: CUnsignedInt = 0
            
            Scanner(string: redHex).scanHexInt32(&redInt)
            Scanner(string: greenHex).scanHexInt32(&greenInt)
            Scanner(string: blueHex).scanHexInt32(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0,
                      green: CGFloat(greenInt) / 255.0,
                      blue: CGFloat(blueInt) / 255.0,
                      alpha: CGFloat(alpha))
        }
        else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }

    var hexValue: String {
        var color = self
        
        if color.cgColor.numberOfComponents < 4 {
            let c = color.cgColor.components!
            color = UIColor(red: c[0], green: c[0], blue: c[0], alpha: c[1])
        }
        if color.cgColor.colorSpace!.model != .rgb {
            return "#FFFFFF"
        }
        let c = color.cgColor.components!
        return String(format: "#%02X%02X%02X", Int(c[0]*255.0), Int(c[1]*255.0), Int(c[2]*255.0))
    }
}

