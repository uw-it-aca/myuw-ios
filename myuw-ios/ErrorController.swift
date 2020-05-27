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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("viewDidLoad", log: .ui, type: .info)
        
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .white
        
        self.title = "MyUW"
        
        headerText.font = UIFont.boldSystemFont(ofSize: 18)
        headerText.textAlignment = .left
        headerText.sizeToFit()
        view.addSubview(headerText)
        // autolayout contraints
        headerText.translatesAutoresizingMaskIntoConstraints = false
        headerText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        headerText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        headerText.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        
        bodyText.font = UIFont.systemFont(ofSize: 14)
        bodyText.textAlignment = .left
        bodyText.numberOfLines = 0
        bodyText.sizeToFit()
        view.addSubview(bodyText)
        // autolayout contraints
        bodyText.translatesAutoresizingMaskIntoConstraints = false
        bodyText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bodyText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bodyText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 15).isActive = true
        
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.setTitle("Retry", for: .normal)
        signInButton.contentEdgeInsets = UIEdgeInsets(top: 13,left: 5,bottom: 13,right: 5)
        signInButton.addTarget(self, action: #selector(retryNetwork), for: .touchUpInside)
        signInButton.sizeToFit()
        view.addSubview(signInButton)
        // autolayout contraints
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        // set topanchor of label equal to bottomanchor of textview
        signInButton.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 50).isActive = true
        signInButton.backgroundColor = uwPurple
        signInButton.layer.cornerRadius = 10
        
        if (appDelegate.isConnectedToNetwork()) {
            headerText.text = "Unable to load page"
            bodyText.text = "A server error has occurred. We are aware of the issue and are working to resolve it. Please try again in a few minutes."
        } else {
            headerText.text = "No internet connection"
            bodyText.text = "It looks like you're offline. Connect to the internet and retry to access MyUW."
        }
        
    }
    
    @objc private func retryNetwork() {
        os_log("Retry Button tapped", log: .ui, type: .info)
        
        // force use go through appAuth flow when foregrounding the app
        /*
        let appAuthController = AppAuthController()
        let navController = UINavigationController(rootViewController: appAuthController)
        
        // set appAuth controller as rootViewController
        appDelegate.window!.rootViewController = navController
        */
        
        UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: AppAuthController())
    }
    
}
