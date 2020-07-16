//
//  ApplicationController.swift
//  myuw-ios
//
//  Created by University of Washington on 10/29/19.
//  Copyright © 2019 University of Washington. All rights reserved.
//

import Foundation
import UIKit
import os

class ApplicationController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    // global tab setup
    let tabHome = UINavigationController(rootViewController: HomeWebView())
    let tabAcademics = UINavigationController(rootViewController: AcademicsWebView())
    let tabHuskyExp = UINavigationController(rootViewController: HuskyExpWebView())
    let tabTeaching = UINavigationController(rootViewController: TeachingWebView())
    let tabAccounts = UINavigationController(rootViewController: AccountsWebView())
    let tabProfile = UINavigationController(rootViewController: ProfileWebView())
    let tabNotices = UINavigationController(rootViewController: NoticesWebView())
    let tabCalendar = UINavigationController(rootViewController: CalendarWebView())
    let tabResources = UINavigationController(rootViewController: ResourcesWebView())

    // get lastTabIndex from UserDefaults... sets initial value to 0 of none is stored
    var lastTabIndex = UserDefaults.standard.value(forKey: "lastTabIndex") ?? 0
    var prevIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        self.tabBarController?.delegate = self
        self.navigationController?.delegate = self
        self.moreNavigationController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                        
        // MARK: - Tab Bar Setup
        
        // set tabbar icon and title color
        UITabBar.appearance().tintColor = uwPurple
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: uwPurple as Any], for: .selected)
        
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
        
        // Profile tab
        let tabProfileBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "ic_person"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabProfile.tabBarItem = tabProfileBarItem
        
        // Notices tab
        let tabNoticesBarItem = UITabBarItem(title: "Notices", image: UIImage(named: "ic_warning"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabNotices.tabBarItem = tabNoticesBarItem
        
        // Calendar tab
        let tabCalendarBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "ic_calendar"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabCalendar.tabBarItem = tabCalendarBarItem
        
        // Resources tab
        let tabResourcesBarItem = UITabBarItem(title: "UW Resources", image: UIImage(named: "ic_resources"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabResources.tabBarItem = tabResourcesBarItem
        
        // More tab
        // configure large title for more tab
        self.moreNavigationController.navigationBar.prefersLargeTitles = true
        // icon color for "more" menu table
        self.moreNavigationController.view.tintColor = uwPurple
        
        // remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        // MARK: - Tab View Controllers
        
        // build bottom tab navigation based on user affiliations
        var controllers = [tabHome, tabAccounts, tabProfile, tabCalendar, tabResources]
        
        // insert academics tab for students or applicant
        if User.userAffiliations.contains("student") || User.userAffiliations.contains("applicant") {
            controllers.insert(tabAcademics, at: 1)
        }
        
        // insert husky exp tab for seattle undergrad
        if (User.userAffiliations.contains("undergrad") && User.userAffiliations.contains("seattle")) || User.userAffiliations.contains("hxt_viewer") {
            controllers.insert(tabHuskyExp, at: 1)
        }
        
        // insert teaching tab for instructor
        if User.userAffiliations.contains("instructor") {
            controllers.insert(tabTeaching, at: 2)
        }
        
        // insert notices tab for student
        if User.userAffiliations.contains("student") {
            controllers.insert(tabNotices, at: 4)
        }
        
        self.viewControllers = controllers
                    
        // set tabHome active
        if lastTabIndex as! Int == 10 {
            self.selectedViewController = moreNavigationController
        } else {
            self.selectedIndex = lastTabIndex as! Int
        }
        
        // handle if landed on more tab
        if self.selectedViewController == moreNavigationController {
            // remove the more "edit" button
            self.moreNavigationController.tabBarController?.customizableViewControllers = []
            self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        }
        
    }
        
    // override the "more" menu edit screen
    /*
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        for (index, subView) in view.subviews.enumerated() {
            if index == 1 {
                // icon color
                subView.tintColor = uwPurple
            }
        }
    }
    */
    

    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        let selectedVC = self.selectedViewController
        
        switch (selectedVC) {
        case tabHome:
            os_log("Clicked tabHome, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabAcademics:
            os_log("Clicked tabAcademics, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabTeaching:
            os_log("Clicked tabTeaching, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabHuskyExp:
            os_log("Clicked tabHuskyExp, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabAccounts:
            os_log("Clicked tabAccounts, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabProfile:
            os_log("Clicked tabProfile, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabNotices:
            os_log("Clicked tabNotices, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabCalendar:
            os_log("Clicked tabCalendar, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        case tabResources:
            os_log("Clicked tabResources, index: %d", log: .app, type: .info, selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        default:
            os_log("Clicked moreNavigationController, index: %d", log: .app, type: .info, 10)
            UserDefaults.standard.set(10, forKey: "lastTabIndex")
        }
     
    }

    // UINavigationControllerDelegate (moreNavigationController)
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        // remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        let selectedVC = self.selectedViewController
                
        // track more controller clicks to avoid back2back event calls
        if prevIndex != selectedIndex {
            switch (selectedVC) {
            case tabNotices:
                os_log("Clicked tabNotices, index: %d", log: .app, type: .info, selectedIndex)
                UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
                prevIndex = selectedIndex
            case tabProfile:
                os_log("Clicked tabProfile, index: %d", log: .app, type: .info, selectedIndex)
                UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
                prevIndex = selectedIndex
            case tabCalendar:
                os_log("Clicked tabCalendar, index: %d", log: .app, type: .info, selectedIndex)
                UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
                prevIndex = selectedIndex
            case tabResources:
                os_log("Clicked tabResources, index: %d", log: .app, type: .info, selectedIndex)
                UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
                prevIndex = selectedIndex
            default:
                break
            }
        } else {
            os_log("Clicked moreNavigationController Back, index: %d", log: .app, type: .info, 10)
            UserDefaults.standard.set(10, forKey: "lastTabIndex")
            prevIndex = 0
        }
                        
    }
        
}

extension OSLog {
    // log setup
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let app = OSLog(subsystem: subsystem, category: "Application")
}
