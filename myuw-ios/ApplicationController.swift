//
//  ApplicationController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import UIKit

class ApplicationController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    // global tab setup
    let tabHome = UINavigationController(rootViewController: HomeWebView())
    let tabAcademics = UINavigationController(rootViewController: AcademicsWebView())
    let tabHuskyExp = UINavigationController(rootViewController: HuskyExpWebView())
    let tabTeaching = UINavigationController(rootViewController: TeachingWebView())
    var tabAccounts = UINavigationController(rootViewController: AccountsWebView())
    let tabNotices = UINavigationController(rootViewController: NoticesWebView())
    let tabCalendar = UINavigationController(rootViewController: CalendarWebView())
    let tabResources = UINavigationController(rootViewController: ResourcesWebView())

    // get lastTabIndex from UserDefaults... sets initial value to 0 of none is stored
    var lastTabIndex = UserDefaults.standard.value(forKey: "lastTabIndex") ?? 0

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
                
        //print("xxxxx appController viewWillAppear")
        
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
        
        // try to remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.navigationBar.topItem?.rightBarButtonItem = nil
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        // MARK: - Tab View Controllers
        
        // build bottom tab navigation based on user affiliations
        var controllers = [tabHome, tabAccounts, tabCalendar, tabResources]
        
        // insert academics tab for students or applicant
        if User.userAffiliations.contains("student") || User.userAffiliations.contains("applicant") {
            controllers.insert(tabAcademics, at: 1)
        }
        
        // insert teaching tab for instructor
        if User.userAffiliations.contains("instructor") {
            controllers.insert(tabTeaching, at: 1)
        }
        
        // insert husky exp tab for seattle undergrad
        if (User.userAffiliations.contains("undergrad") && User.userAffiliations.contains("seattle")) || User.userAffiliations.contains("hxt_viewer") {
            controllers.insert(tabHuskyExp, at: 2)
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
            //print("xxxxx landed on more tab")
            UserDefaults.standard.set(10, forKey: "lastTabIndex")
            
            // try to remove the more "edit" button
            self.moreNavigationController.tabBarController?.customizableViewControllers = []
            self.moreNavigationController.navigationBar.topItem?.rightBarButtonItem = nil
            self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
            
            // set the more navigation controller as the main delegate
            //self.moreNavigationController.delegate = self
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
    
    // UITabBarDelegate
    /*
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("xxxxx Selected item", self.selectedIndex)
    }*/
    
 
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("xxxxx Selected view controller")
        
        // try to remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.navigationBar.topItem?.rightBarButtonItem = nil
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        let selectedVC = self.selectedViewController
        
        //TODO: get switch statement working
        /*
        switch selectedVC {
        case tabHome:
            print("You're heading north!")
        case tabAcademics:
            print("You're heading south!")
        case tabTeaching:
            print("You're heading west!")
        default:
            print("sadflkj")
        }
         */
        
        if selectedVC == tabHome {
            //print("xxxxx clicked on tabHome, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabAcademics {
            //print("xxxxx clicked on tabAcademics, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabTeaching {
            //print("xxxxx clicked on tabTeaching, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabHuskyExp {
            //print("xxxxx clicked on tabHuskyExp, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabAccounts {
            //print("xxxxx clicked on tabAccounts, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        // typically in the More tab
        
        if selectedVC == tabNotices {
            print("xxxxx clicked on tabNotices, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabCalendar {
            print("xxxxx clicked on tabCalendar, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabResources {
            print("xxxxx clicked on tabResources, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        // handle the More tab
        if selectedVC == moreNavigationController {
            print("xxxxx clicked on moreNavigationController, index: ", 10)
            UserDefaults.standard.set(10, forKey: "lastTabIndex")
        }
        
    }

    // handle tab items clicked in the more navigation controller
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //print("xxxxx Clicked in moreNavigationController")
        //print("xxxxx willshow")
        
        // try to remove the more "edit" button
        self.moreNavigationController.tabBarController?.customizableViewControllers = []
        self.moreNavigationController.navigationBar.topItem?.rightBarButtonItem = nil
        self.moreNavigationController.tabBarController?.customizableViewControllers?.removeAll()
        
        let selectedVC = self.selectedViewController
            
        if selectedVC == tabNotices {
            //print("xxxxx clicked on tabNotices, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabCalendar {
            //print("xxxxx clicked on tabCalendar, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
        
        if selectedVC == tabResources {
            //print("xxxxx clicked on tabResources, index: ", selectedIndex)
            UserDefaults.standard.set(selectedIndex, forKey: "lastTabIndex")
        }
                        
    }
    

            
}

