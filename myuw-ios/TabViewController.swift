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
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set tabbar icon and title color
        UITabBar.appearance().tintColor = UIColor.systemPink
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemPink], for: .selected)

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
        
        // Calendar tab
        let tabCalendar = UINavigationController(rootViewController: CalendarViewController())
        let tabCalendarBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "ic_calendar"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabCalendar.tabBarItem = tabCalendarBarItem
        
        // Resources tab
        let tabResources = UINavigationController(rootViewController: ResourcesViewController())
        let tabResourcesBarItem = UITabBarItem(title: "Resources", image: UIImage(named: "ic_resources"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabResources.tabBarItem = tabResourcesBarItem
        
        var controllers: NSArray = []
        
        if userAffiliation == "student" {
            controllers = [tabHome, tabAcademics, tabHuskyExp, tabAccounts, tabCalendar, tabResources]
        }
        else {
            controllers = [tabHome, tabTeaching, tabAccounts, tabCalendar, tabResources]
        }
                
        self.viewControllers = controllers as? [UIViewController]

    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
          
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        
        // force auth workflow if app is coming back to the foreground
        // this should handle the case if session timeouts after 8hrs
        let authController = AuthenticationController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // re-set authController as rootViewController
        appDelegate.window!.rootViewController = authController
        
    }
        
}
