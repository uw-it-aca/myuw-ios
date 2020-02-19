//
//  ErrorController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 2/18/20.
//  Copyright © 2020 Charlon Palacay. All rights reserved.
//

import AppAuth
import UIKit
import os

class ErrorController: UIViewController {
    
    let headerText = UILabel()
    let bodyText = UILabel()
    let signInButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("viewDidLoad", log: .ui, type: .info)
        
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .white
        
        self.title = "MyUW"
        
        headerText.layer.borderWidth = 0.25
        headerText.layer.borderColor = UIColor.red.cgColor
        headerText.font = UIFont.boldSystemFont(ofSize: 18)
        headerText.textAlignment = .left
        headerText.text = "No internet connection"
        headerText.sizeToFit()
        view.addSubview(headerText)
        // autolayout contraints
        headerText.translatesAutoresizingMaskIntoConstraints = false
        headerText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        headerText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        headerText.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        
        bodyText.layer.borderWidth = 0.25
        bodyText.layer.borderColor = UIColor.red.cgColor
        bodyText.font = UIFont.systemFont(ofSize: 14)
        bodyText.textAlignment = .left
        bodyText.numberOfLines = 0
        bodyText.sizeToFit()
        bodyText.text = "You are offline, connect to the internet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut quis nunc nisl. Integer a ligula nec odio efficitur sagittis quis in sapien. Phasellus tempor dui nec pharetra lacinia."
        view.addSubview(bodyText)
        // autolayout contraints
        bodyText.translatesAutoresizingMaskIntoConstraints = false
        bodyText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bodyText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bodyText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 5).isActive = true
        
        signInButton.layer.borderWidth = 0.25
        signInButton.layer.borderColor = UIColor.red.cgColor
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        signInButton.setTitleColor(.blue, for: .normal)
        signInButton.setTitle("Retry", for: .normal)
        signInButton.addTarget(self, action: #selector(retryNetwork), for: .touchUpInside)
        signInButton.sizeToFit()
        view.addSubview(signInButton)
        // autolayout contraints
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        // set topanchor of label equal to bottomanchor of textview
        signInButton.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 10).isActive = true
        
    }
    
    @objc private func retryNetwork() {
        os_log("Retry Button tapped", log: .ui, type: .info)
        
        // force use go through appAuth flow when foregrounding the app
        let appAuthController = AppAuthController()
        let navController = UINavigationController(rootViewController: appAuthController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set appAuth controller as rootViewController
        appDelegate.window!.rootViewController = navController
    }
    
}
