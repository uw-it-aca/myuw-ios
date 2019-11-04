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
                
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Home tab
        let tabHome = UINavigationController(rootViewController: HomeViewController())
        let tabHomeBarItem = UITabBarItem(title: "Home", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabHome.tabBarItem = tabHomeBarItem

        // Academics tab
        let tabAcademics = UINavigationController(rootViewController: AcademicsViewController())
        let tabAcademicsBarItem = UITabBarItem(title: "Academics", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAcademics.tabBarItem = tabAcademicsBarItem
        
        // Teaching tab
        let tabTeaching = UINavigationController(rootViewController: TeachingViewController())
        let tabTeachingBarItem = UITabBarItem(title: "Teaching", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabTeaching.tabBarItem = tabTeachingBarItem
        
        // Accounts tab
        let tabAccounts = UINavigationController(rootViewController: AccountsViewController())
        let tabAccountsBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabAccounts.tabBarItem = tabAccountsBarItem
        
        // Calendar tab
        let tabCalendar = UINavigationController(rootViewController: CalendarViewController())
        let tabCalendarBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabCalendar.tabBarItem = tabCalendarBarItem
        
        // Resources tab
        let tabResources = UINavigationController(rootViewController: ResourcesViewController())
        let tabResourcesBarItem = UITabBarItem(title: "Resources", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabResources.tabBarItem = tabResourcesBarItem
        
        var controllers: NSArray = []
        
        if userAffiliation == "student" {
            controllers = [tabHome, tabAcademics, tabAccounts, tabCalendar, tabResources]
        }
        else {
            controllers = [tabHome, tabTeaching, tabAccounts, tabCalendar, tabResources]
        }
        
        self.viewControllers = controllers as? [UIViewController]
   
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
          
    }
}
