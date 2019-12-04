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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self        
        
        let notificationCenter = NotificationCenter.default
        
        // observe various phone state changes and re-auth if needed
        //notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        //notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        //notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set tabbar icon and title color
        UITabBar.appearance().tintColor = UIColor(hex: "#4b2e83")
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: "#4b2e83")], for: .selected)
        
        // icon color for "more" menu table
        self.moreNavigationController.view.tintColor = UIColor(hex: "#4b2e83")
        
        // Home tab
        let tabHome = UINavigationController(rootViewController: HomeViewController())
        let tabHomeBarItem = UITabBarItem(title: "Home", image: UIImage(named: "ic_home"), selectedImage: UIImage(named: "selectedImage.png"))
        tabHome.tabBarItem = tabHomeBarItem

        // Academics tab
        let tabAcademics = UINavigationController(rootViewController: AcademicsViewController())
        let tabAcademicsBarItem = UITabBarItem(title: "Academics", image: UIImage(named: "ic_academics"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAcademics.tabBarItem = tabAcademicsBarItem
        
        // Husky Experience tab
        let tabHuskyExp = UINavigationController(rootViewController: HuskyExpViewController())
        let tabHuskyExpBarItem = UITabBarItem(title: "Husky Exp", image: UIImage(named: "ic_paw"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabHuskyExp.tabBarItem = tabHuskyExpBarItem
        
        // Teaching tab
        let tabTeaching = UINavigationController(rootViewController: TeachingViewController())
        let tabTeachingBarItem = UITabBarItem(title: "Teaching", image: UIImage(named: "ic_teaching"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabTeaching.tabBarItem = tabTeachingBarItem
        
        // Accounts tab
        let tabAccounts = UINavigationController(rootViewController: AccountsViewController())
        let tabAccountsBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "ic_accounts"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAccounts.tabBarItem = tabAccountsBarItem
        
        // Notices tab
        let tabNotices = UINavigationController(rootViewController: NoticesViewController())
        let tabNoticesBarItem = UITabBarItem(title: "Notices", image: UIImage(named: "ic_warning"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabNotices.tabBarItem = tabNoticesBarItem
        
        // Calendar tab
        let tabCalendar = UINavigationController(rootViewController: CalendarViewController())
        let tabCalendarBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "ic_calendar"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabCalendar.tabBarItem = tabCalendarBarItem
        
        // Resources tab
        let tabResources = UINavigationController(rootViewController: ResourcesViewController())
        let tabResourcesBarItem = UITabBarItem(title: "Resources", image: UIImage(named: "ic_resources"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabResources.tabBarItem = tabResourcesBarItem
        
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
        let authController = AuthenticationController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // re-set authController as rootViewController
        appDelegate.window!.rootViewController = authController
        
    }
            
}
