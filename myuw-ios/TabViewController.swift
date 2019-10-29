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
        
        self.title = "MYUW"
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        let tabOne = HomeViewController()
        let tabOneBarItem = UITabBarItem(title: "Home", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabOne.tabBarItem = tabOneBarItem
        
        // Create Tab two
        let tabTwo = AcademicsViewController()
        let tabTwoBarItem2 = UITabBarItem(title: "Academics", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabTwo.tabBarItem = tabTwoBarItem2
        
        // Create Tab three
        let tabThree = TeachingViewController()
        let tabThreeBarItem2 = UITabBarItem(title: "Teaching", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabThree.tabBarItem = tabThreeBarItem2
        
        // Create Tab four
        let tabFour = ProfileViewController()
        let tabFourBarItem2 = UITabBarItem(title: "Profile", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabFour.tabBarItem = tabFourBarItem2
        
        // Create Tab five
        let tabFive = AccountsViewController()
        let tabFiveBarItem2 = UITabBarItem(title: "Accounts", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabFive.tabBarItem = tabFiveBarItem2
        
        // Create Tab six
        let tabSix = CalendarViewController()
        let tabSixBarItem2 = UITabBarItem(title: "Calendar", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        tabSix.tabBarItem = tabSixBarItem2
        
        // Create Tab seven
        let tabSeven = ResourcesViewController()
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
