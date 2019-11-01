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
        
        // Create Tab one
        let tabOne = UINavigationController(rootViewController: HomeViewController())
        let tabOneBarItem = UITabBarItem(title: "Home", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabOne.tabBarItem = tabOneBarItem

        // Create Tab two
        let tabTwo = UINavigationController(rootViewController: AcademicsViewController())
        let tabTwoBarItem2 = UITabBarItem(title: "Academics", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabTwo.tabBarItem = tabTwoBarItem2
        
        // Create Tab three
        let tabThree = UINavigationController(rootViewController: TeachingViewController())
        let tabThreeBarItem2 = UITabBarItem(title: "Teaching", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabThree.tabBarItem = tabThreeBarItem2
        
        // Create Tab four
        let tabFour = UINavigationController(rootViewController: ProfileViewController())
        let tabFourBarItem2 = UITabBarItem(title: "Profile", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabFour.tabBarItem = tabFourBarItem2
        
        // Create Tab five
        let tabFive = UINavigationController(rootViewController: AccountsViewController())
        let tabFiveBarItem2 = UITabBarItem(title: "Accounts", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabFive.tabBarItem = tabFiveBarItem2
        
        // Create Tab six
        let tabSix = UINavigationController(rootViewController: CalendarViewController())
        let tabSixBarItem2 = UITabBarItem(title: "Calendar", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabSix.tabBarItem = tabSixBarItem2
        
        // Create Tab seven
        let tabSeven = UINavigationController(rootViewController: ResourcesViewController())
        let tabSevenBarItem2 = UITabBarItem(title: "Resources", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabSeven.tabBarItem = tabSevenBarItem2
        
        self.viewControllers = [tabOne, tabTwo, tabThree, tabFour, tabFive, tabSix, tabSeven]
   
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        print(viewController)
        
        if (viewController.isKind(of: ProfileViewController.self)) {
            self.title = "MYUW"
        }
        
        if (viewController.isKind(of: ProfileViewController.self)) {
            self.title = "PROFILE"
        }
        
  
    }
}
