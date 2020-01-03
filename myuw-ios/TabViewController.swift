//
//  TabViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    
    // global tab setup
    let tabHome = UINavigationController(rootViewController: HomeViewController())
    let tabAcademics = UINavigationController(rootViewController: AcademicsViewController())
    let tabHuskyExp = UINavigationController(rootViewController: HuskyExpViewController())
    let tabTeaching = UINavigationController(rootViewController: TeachingViewController())
    let tabAccounts = UINavigationController(rootViewController: AccountsViewController())
    let tabNotices = UINavigationController(rootViewController: NoticesViewController())
    let tabCalendar = UINavigationController(rootViewController: CalendarViewController())
    let tabResources = UINavigationController(rootViewController: ResourcesViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self        
        
        // MARK: - Notification Center
        
        let notificationCenter = NotificationCenter.default
        
        // TODO: observe various phone state changes and re-auth if needed
        
        // app foregrounded
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // app backgrounded
        //notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // app became active (called every time)
        //notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil )
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: - Tab Bar Setup
        
        // set tabbar icon and title color
        UITabBar.appearance().tintColor = UIColor(hex: "#4b2e83")
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: "#4b2e83")], for: .selected)
        
        // Home tab
        let tabHomeBarItem = UITabBarItem(title: "Home", image: UIImage(named: "ic_home"), selectedImage: UIImage(named: "selectedImage.png"))
        tabHome.tabBarItem = tabHomeBarItem

        // Academics tab
        let tabAcademicsBarItem = UITabBarItem(title: "Academics", image: UIImage(named: "ic_academics"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAcademics.tabBarItem = tabAcademicsBarItem
        
        // Husky Experience tab
        let tabHuskyExpBarItem = UITabBarItem(title: "Husky Exp", image: UIImage(named: "ic_paw"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabHuskyExp.tabBarItem = tabHuskyExpBarItem
        
        // Teaching tab
        let tabTeachingBarItem = UITabBarItem(title: "Teaching", image: UIImage(named: "ic_teaching"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabTeaching.tabBarItem = tabTeachingBarItem
        
        // Accounts tab
        let tabAccountsBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "ic_accounts"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAccounts.tabBarItem = tabAccountsBarItem
        
        // Notices tab
        let tabNoticesBarItem = UITabBarItem(title: "Notices", image: UIImage(named: "ic_warning"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabNotices.tabBarItem = tabNoticesBarItem
        
        // Calendar tab
        let tabCalendarBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "ic_calendar"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabCalendar.tabBarItem = tabCalendarBarItem
        
        // Resources tab
        let tabResourcesBarItem = UITabBarItem(title: "Resources", image: UIImage(named: "ic_resources"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabResources.tabBarItem = tabResourcesBarItem
        
        // More tab
        // configure large title for more tab
        self.moreNavigationController.navigationBar.prefersLargeTitles = true
        // icon color for "more" menu table
        self.moreNavigationController.view.tintColor = UIColor(hex: "#4b2e83")
        
        // MARK: - Tab View Controllers
        
        // build bottom tab navigation based on user affiliations
        var controllers = [tabHome, tabAccounts, tabCalendar, tabResources]
        
        // insert academics tab for students or applicant
        if userAffiliations.contains("student") || userAffiliations.contains("applicant") {
            controllers.insert(tabAcademics, at: 1)
        }
        
        // insert teaching tab for instructor
        if userAffiliations.contains("instructor") {
            controllers.insert(tabTeaching, at: 1)
        }
        
        // insert husky exp tab for seattle undergrad
        if userAffiliations.contains("undergrad") && userAffiliations.contains("seattle") {
            controllers.insert(tabHuskyExp, at: 2)
        }
        
        // insert notices tab for student
        if userAffiliations.contains("student") {
            controllers.insert(tabNotices, at: 4)
        }
        
        self.viewControllers = controllers
        
    }
    
    // override the "more" menu edit screen
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        for (index, subView) in view.subviews.enumerated() {
            if index == 1 {
                // icon color
                subView.tintColor = UIColor(hex: "#4b2e83")
            }
        }
    }
    
    @objc func appBecameActive() {
        print("App became active!")
    
        // force auth workflow if app is coming back to the foreground
        // this should handle the case if session timeouts after 8hrs
        //let authController = AuthenticationController()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // re-set authController as rootViewController
        //appDelegate.window!.rootViewController = authController
                        
    }
    
    // MARK: - Handle deep links
    
    func openDeepLink(url: URL) {
    
        // make sure correct scheme is being used
        if let scheme = url.scheme, scheme.localizedCaseInsensitiveCompare("myuwapp") == .orderedSame, let tab = url.host {
            
            print(tab)
            
            // grab any query params
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print(parameters)
                     
            // match the page param to its corresponding tabController
            switch tab {
            case "academics":
                self.selectedViewController = self.tabAcademics
            case "huskyexp":
                self.selectedViewController = self.tabHuskyExp
            case "teaching":
                self.selectedViewController = self.tabTeaching
            case "accounts":
                self.selectedViewController = self.tabAccounts
            case "notices":
                self.selectedViewController = self.tabNotices
            case "calendar":
                self.selectedViewController = self.tabCalendar
            case "resources":
                self.selectedViewController = self.tabResources
            default:
                self.selectedViewController = self.tabHome
            }
            
        }
        
        
    }
    
                
}
