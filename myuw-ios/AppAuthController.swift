//
//  AppAuthController.swift
//  myuw-ios
//
//  Created by University of Washington on 1/7/20.
//  Copyright © 2020 University of Washington. All rights reserved.
//

import AppAuth
import UIKit
import WebKit
import os

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

let kIssuer: String = clientIssuer
let kClientID: String? = clientID
// can also use reverse DNS notion of the client ID for kRedirectURI
let kRedirectURI: String = "myuwapp://oauth2redirect";
let kAppAuthExampleAuthStateKey: String = "authState";

var signingOut = false
public var signingIn = false

class AppAuthController: UIViewController, UIWebViewDelegate {
    
    // property of the containing class
    private var authState: OIDAuthState?
        
    var activityIndicator: UIActivityIndicatorView!
    var tabBarCont: UITabBarController?
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("viewDidLoad", log: .appAuth, type: .info)
        
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .white
        
        // App title
        self.title = "MyUW"
        
        // create empty tabbar controller as a visual placeholder
        //tabBarCont = UITabBarController()
        //view.addSubview((tabBarCont?.view)!)
                
        setupScrollView()
        setupViews()
        
        // get authstate
        self.loadState()
   
        os_log("signingOut: %@", log: .appAuth, type: .info, signingOut.description)
        
    
        if (signingOut) {
            // set auto sign-out messaging
            headerText.text = "Signed out"
            
            // hide ciso intro
            introText.isHidden = true
            bulletText.isHidden = true
            
            // update continue text and reposition below signed out header
            continueText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 30).isActive = true
            continueText.text = "You have been signed out successfully. In some cases, you may be signed out because of an application error or prolonged inactivity. Sign in to continue."
        }
        
    }
    
    func setupScrollView(){
        
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func setupViews(){
        
        contentView.addSubview(headerText)
        headerText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        headerText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        // anchor first element to top of contentView
        headerText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        
        contentView.addSubview(introText)
        introText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        introText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        introText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(bulletText)
        bulletText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        bulletText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        bulletText.topAnchor.constraint(equalTo: introText.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(continueText)
        continueText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        continueText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        continueText.topAnchor.constraint(equalTo: bulletText.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(signInButton)
        signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        signInButton.topAnchor.constraint(equalTo: continueText.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(disclosureText)
        disclosureText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        disclosureText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        disclosureText.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(eulaButton)
        eulaButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        eulaButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        eulaButton.topAnchor.constraint(equalTo: disclosureText.bottomAnchor, constant: 30).isActive = true
        
        contentView.addSubview(privacyButton)
        privacyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        privacyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        privacyButton.topAnchor.constraint(equalTo: eulaButton.bottomAnchor, constant: 3).isActive = true
        
        contentView.addSubview(termsButton)
        termsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        termsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        termsButton.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 3).isActive = true
        
        contentView.addSubview(problemButton)
        problemButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        problemButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        problemButton.topAnchor.constraint(equalTo: termsButton.bottomAnchor, constant: 30).isActive = true
        // // anchor last element to bottom of contentView, add 100 pixels to preserve scrolling bounce
        problemButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100).isActive = true
        
    }
    
    let headerText: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let introText: UILabel = {
        let label = UILabel()
        label.text = "The MyUW app is designed to keep you signed in to MyUW for convenience. Here are some tips to keep your UW NetID and personal information safe:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.frame.size.height = 200.0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bulletText: UILabel = {
        let label = UILabel()
        let bulletArray = [
            "Configure your device to require a passcode, biometric factor, or other security measure to unlock it",
            "Make sure your device is locked when not in use",
            "Report a lost or stolen device"
        ]
        label.attributedText = NSAttributedStringHelper.createBulletedList(fromStringArray: bulletArray, font: UIFont.systemFont(ofSize: 16))
        label.textAlignment = .left
        label.numberOfLines = 0
        if (label.isHidden) {
            label.frame.size.height = 0
        } else {
            label.frame.size.height = 200.0
        }
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let continueText: UILabel = {
        let label = UILabel()
        label.text = "Please sign in to continue."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.frame.size.height = 200.0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign in", for: .normal)
        button.backgroundColor = uwPurple
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 13,left: 5,bottom: 13,right: 5)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let disclosureText: UILabel = {
        let label = UILabel()
        label.text = "Please read the End-User License Agreement (the \"EULA\" or \"Agreement\") carefully before signing in. The Agreement governs Your download and use of the MyUW application (\"Software\") provided by the University of Washington (the \"University\"). Your use of the Software constitutes Your acceptance of the terms of the Agreement and is also subject to the Privacy Policy and Terms of Service of University."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.frame.size.height = 200.0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var eulaButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(uwPurple, for: .normal)
        button.setTitle("End-User License Agreement (EULA)", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(showEULA), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(uwPurple, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(showPrivacy), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(uwPurple, for: .normal)
        button.setTitle("Terms of Service", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(showTerms), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var problemButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(uwPurple, for: .normal)
        button.setTitle("Report a problem: help@uw.edu", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(reportProblem), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func loginUser() {
        os_log("Sign in button tapped", log: .appAuth, type: .info)
        
        // set signing in flag true
        signingIn = true
        
        // authorize oidc with auto code exchange
        authWithAutoCodeExchange()
    }
    
    @objc private func showEULA(sender: AnyObject) {
        os_log("EULA button tapped", log: .appAuth, type: .info)        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: linkEULA)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: linkEULA)!)
        }
    }
    
    @objc private func showPrivacy(sender: AnyObject) {
        os_log("Privacy button tapped", log: .appAuth, type: .info)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: linkPrivacy)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: linkPrivacy)!)
        }
    }
    
    @objc private func showTerms(sender: AnyObject) {
        os_log("ToS button tapped", log: .appAuth, type: .info)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: linkTerms)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: linkTerms)!)
        }
    }
    
    @objc private func reportProblem(sender: AnyObject) {
        os_log("Report problem button tapped", log: .appAuth, type: .info)

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: linkHelp)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: linkHelp)!)
        }
    }
    
    @objc func signOut() {
        
        os_log("Signing user out of native", log: .appAuth, type: .info)
        
        // set signed out to true
        signingOut = true
        
        // clear authstate to signout user
        setAuthState(nil)
        
        // clear UserDefaults
        UserDefaults.standard.removeObject(forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.removeObject(forKey: "lastTabIndex")
        
        // remove all existing affiliations and start with fresh array
        User.userAffiliations.removeAll()
        
        // show the sign-in content
        headerText.isHidden = false
        introText.isHidden = false
        bulletText.isHidden = false
        continueText.isHidden = false
        signInButton.isHidden = false
        disclosureText.isHidden = false
        eulaButton.isHidden = false
        privacyButton.isHidden = false
        termsButton.isHidden = false
        problemButton.isHidden = false
        
    }
    
    func authWithAutoCodeExchange() {
        
        os_log("authWithAutoCodeExchange", log: .appAuth, type: .info)
        
        guard let issuer = URL(string: kIssuer) else {
            os_log("Error creating URL for: %@", log: .appAuth, type: .error, kIssuer)
            return
        }
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            guard let config = configuration else {
                os_log("Error retrieving discovery document: %@", log: .appAuth, type: .error, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
                return
            }
            
            os_log("Got configuration: %@", log: .appAuth, type: .info, config)
            
            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                
                self.doClientRegistration(configuration: config) { configuration, response in
                    
                    guard let configuration = configuration, let clientID = response?.clientID else {
                        os_log("Error retrieving configuration OR clientID", log: .appAuth, type: .error)
                        return
                    }
                    
                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
                
            }
        }
    }
    
    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        
        os_log("doClientRegistration", log: .appAuth, type: .info)
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            os_log("Error creating URL for: %@", log: .appAuth, type: .error, kRedirectURI)
            return
        }
        
        let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                     redirectURIs: [redirectURI],
                                                                     responseTypes: nil,
                                                                     grantTypes: nil,
                                                                     subjectType: nil,
                                                                     tokenEndpointAuthMethod: "client_secret_post",
                                                                     additionalParameters: nil)
        
        // performs registration request
        os_log("Initiating registration request", log: .appAuth, type: .info)
        
        OIDAuthorizationService.perform(request) { response, error in
            
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                os_log("Got registration response: %@", log: .appAuth, type: .info, regResponse)
                callback(configuration, regResponse)
            } else {
                os_log("Registration error: %@", log: .appAuth, type: .error, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
            }
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        os_log("doAuthWithAutoCodeExchange", log: .appAuth, type: .info)
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            os_log("Error creating URL for: %@", log: .appAuth, type: .info, kRedirectURI)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Error accessing AppDelegate", log: .appAuth, type: .error)
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: ["openid profile offline_access"],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["prompt":"login"])
        
        // performs authentication request
        os_log("Initiating authorization request with scope: %@", log: .appAuth, type: .info, request.scope ?? "DEFAULT_SCOPE")
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            if let authState = authState {
                self.setAuthState(authState)
                os_log("Got authorization tokens. Access token: %@", log: .appAuth, type: .info, authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")
            } else {
                os_log("Authorization error: %@", log: .appAuth, type: .info, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
            }
        }
        
    }
    
}


//MARK: OIDAuthState Delegate
extension AppAuthController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        os_log("didChange", log: .appAuth, type: .info)
        self.stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        os_log("Received authorization error: %@", log: .appAuth, type: .info, error.localizedDescription)
    }
}


//MARK: Helper Methods
extension AppAuthController {
    
    func saveState() {
        
        os_log("saveState", log: .appAuth, type: .info)
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        
        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.synchronize()
        
        // show state
        self.showState()
    }
    
    func loadState() {
        
        os_log("loadState", log: .appAuth, type: .info)
        
        guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            os_log("no authorization state", log: .appAuth, type: .info)
            os_log("ID token: %@", log: .appAuth, type: .error, authState?.lastTokenResponse?.idToken ?? "NONE")
            return
        }
        
        // fixes with: data deprecation warning
        if let authState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
        
            os_log("authorization state has been loaded", log: .appAuth, type: .info)
            
            // set signed out to true
            signingOut = true
            self.setAuthState(authState)
        }
        
    }
    
    func showState() {
        os_log("showState", log: .appAuth, type: .info)
        //os_log("Access token: %@", log: .appAuth, type: .error, authState?.lastTokenResponse?.accessToken ?? "NONE")
        os_log("ID token: %@", log: .appAuth, type: .error, authState?.lastTokenResponse?.idToken ?? "NONE")
        os_log("Refresh token: %@", log: .appAuth, type: .error, authState?.lastTokenResponse?.refreshToken ?? "NONE")
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        
        os_log("setAuthState", log: .appAuth, type: .info)
        
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }
    
    func updateUI() {
        
        os_log("updateUI", log: .appAuth, type: .info)
        
        // if user is signed-in...
        if self.authState != nil {
            
            // hide the sign-in content
            headerText.isHidden = true
            introText.isHidden = true
            bulletText.isHidden = true
            continueText.isHidden = true
            signInButton.isHidden = true
            disclosureText.isHidden = true
            eulaButton.isHidden = true
            privacyButton.isHidden = true
            termsButton.isHidden = true
            problemButton.isHidden = true
            
            // setup application data to build main app controller
            self.setupApplication()
        }
    }
    
    func stateChanged() {
        os_log("stateChanged", log: .appAuth, type: .info)
        self.saveState()
        self.updateUI()
    }
    
}

// MARK: User Info and app redirect
extension AppAuthController {
    
    func showError() {
        
        os_log("showError", log: .appAuth, type: .info)
        
        // show the error controller
        UIApplication.shared.delegate?.window!?.rootViewController = UINavigationController(rootViewController: ErrorController())
    }
    
    func showApplication() {
        
        // set signingIn back to false before showing the application
        os_log("signingIn: %@", log: .appAuth, type: .info, signingIn.description)
        signingIn = false
        
        os_log("showApplication", log: .appAuth, type: .info)
        
        // MARK: transition to appController (tabs)
        UIApplication.shared.delegate?.window!?.rootViewController = ApplicationController()
    }
    
    func setupApplication() {
        
        os_log("setupApplication", log: .appAuth, type: .info)
        
        // MARK: refresh access token before sending to myuw as authentication header
        //let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken
        let currentIdToken: String? = self.authState?.lastTokenResponse?.idToken
        
        self.authState?.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                os_log("Error fetching fresh tokens: %@", log: .appAuth, type: .error, error?.localizedDescription ?? "ERROR")
                
                // sign user out if unable to get fresh tokens (refresh token expired)
                self.signOut()
                return
            }
            
            guard let accessToken = accessToken else {
                os_log("Error getting accessToken", log: .appAuth, type: .error)
                
                // sign user out if unable to get access token
                self.signOut()
                return
            }
            
            // log accessToken freshness
            /*
             if currentAccessToken != accessToken {
             os_log("Access token was refreshed automatically: %@ to %@", log: .auth, type: .info, currentAccessToken ?? "CURRENT_ACCESS_TOKEN", accessToken)
             } else {
             os_log("Access token was fresh and not updated: %@", log: .auth, type: .info, accessToken)
             }
             */
            
            guard let idToken = idToken else {
                os_log("Error getting idToken", log: .appAuth, type: .error)
                
                // sign user out if unable to get id token
                self.signOut()
                return
            }
            
            // log idToken freshness
            if currentIdToken != idToken {
                os_log("ID token was refreshed automatically: %@ to %@", log: .appAuth, type: .info, currentIdToken ?? "CURRENT_ID_TOKEN", idToken)
            } else {
                os_log("ID token was fresh and not updated: %@", log: .appAuth, type: .info, idToken)
            }
            
            os_log("checkTokenFreshness DONE... tokens updated", log: .appAuth, type: .info)
            
            // update the tokens in the singleton process pool
            ProcessPool.accessToken = accessToken
            ProcessPool.idToken = idToken
            
            // do other stuff
            
            if User.userAffiliations.isEmpty {
                
                os_log("user IS empty....", log: .appAuth, type: .info)
                
                // create activity indicator
                //let tabBarHeight = self.tabBarCont!.tabBar.frame.height
                let tabBarHeight = 80 as CGFloat
                let indicatorView = UIActivityIndicatorView(style: .gray)
                indicatorView.isHidden = false
                indicatorView.translatesAutoresizingMaskIntoConstraints = true // default is true
                indicatorView.startAnimating()
                // center the indicator
                indicatorView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - tabBarHeight) // offset height of tabbar 83pt
                indicatorView.autoresizingMask = [
                    .flexibleLeftMargin,
                    .flexibleRightMargin,
                    .flexibleTopMargin,
                    .flexibleBottomMargin
                ]
                // add to subview
                self.view.addSubview(indicatorView)
                
                
                // make sure lastTabIndex is cleared when getting new affiliations
                UserDefaults.standard.removeObject(forKey: "lastTabIndex")
                
                // MARK: get user netid by decoding idtoken
                // TODO: consider creating a Claims struct and mapping everything to it's attributes
                
                let idTokenClaims = self.getIdTokenClaims(idToken: idToken ) ?? Data()
                //os_log("idTokenClaims: %@", log: .auth, type: .info, (String(describing: String(bytes: idTokenClaims, encoding: .utf8))))
                let claimsDictionary = try! JSONSerialization.jsonObject(with: idTokenClaims, options: .allowFragments) as? [String: Any]
                //os_log("claimsDictionary: %@", log: .auth, type: .info, claimsDictionary!)
                
                User.userNetID = claimsDictionary!["sub"] as! String? ?? ""
                os_log("got user netid: %@", log: .appAuth, type: .info, User.userNetID)
                
                
                // MARK: get user affiliations from myuw endpoint
                let affiliationURL = URL(string: "\(appHost)\(appAffiliationEndpoint)")
                os_log("start affiliation request: %@", log: .appAuth, type: .info, affiliationURL!.absoluteString)
                var urlRequest = URLRequest(url: affiliationURL!)
                
                // send id token in authorization header
                os_log("ID token: %@", log: .appAuth, type: .info, self.authState?.lastTokenResponse?.idToken ?? "NONE")
                urlRequest.setValue("Bearer \(self.authState?.lastTokenResponse?.idToken ?? "ID_TOKEN")", forHTTPHeaderField: "Authorization")
                
                // disable cookies for API requests - gets around session cookie issues with middleware
                urlRequest.httpShouldHandleCookies = false
                os_log("affiliation api urlrequest cookies: %@", log: .appAuth, type: .info, urlRequest.httpShouldHandleCookies.description)
                
                // create a task to request affiliations from myuw endpoint
                let task = URLSession.shared.dataTask(with: urlRequest) {
                    data, response, error in DispatchQueue.main.async {
                        
                        guard error == nil else {
                            os_log("HTTP request failed: %@", log: .appAuth, type: .error, error?.localizedDescription ?? "ERROR")
                            // show the error controller
                            self.showError()
                            return
                        }
                        
                        guard let response = response as? HTTPURLResponse else {
                            os_log("Non-HTTP response", log: .appAuth, type: .info)
                            // show the error controller
                            self.showError()
                            return
                        }
                        
                        guard let data = data else {
                            os_log("HTTP response data is empty", log: .appAuth, type: .info)
                            // show the error controller
                            self.showError()
                            return
                        }
                        
                        //MARK: handle the json response
                        var json: [AnyHashable: Any]?
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        } catch {
                            os_log("JSON Serialization Error", log: .appAuth, type: .error)
                            // show the error controller
                            self.showError()
                        }
                        
                        //TODO: this needs a better home!
                        if response.statusCode != 200 {
                            // server replied with an error
                            let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                            
                            if response.statusCode == 401 {
                                // "401 Unauthorized" generally indicates there is an issue with the authorization
                                // grant. Puts OIDAuthState into an error state.
                                let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                                                    errorResponse: json,
                                                                                                    underlyingError: error)
                                self.authState?.update(withAuthorizationError: oauthError)
                                os_log("Authorization Error: %@. Response: %@", log: .appAuth, type: .error, oauthError.localizedDescription, responseText!)
                            } else {
                                os_log("HTTP: %@. Response: %@", log: .appAuth, type: .info, response.statusCode.description, responseText!)
                            }
                            
                            return
                        }
                        
                        
                        if let json = json {
                            
                            //os_log("Successfully decoded: %{private}@", log: .affiliations, type: .info, json)
                            
                            // remove all existing affiliations and start with fresh array
                            User.userAffiliations.removeAll()
                            
                            // add user affiliations to array
                            if json["student"] as! Bool == true {
                                User.userAffiliations.append("student")
                            }
                            
                            if json["applicant"] as! Bool == true {
                                User.userAffiliations.append("applicant")
                            }
                            
                            if json["instructor"] as! Bool == true {
                                User.userAffiliations.append("instructor")
                            }
                            
                            if json["undergrad"] as! Bool == true {
                                User.userAffiliations.append("undergrad")
                            }
                            
                            if json["hxt_viewer"] as! Bool == true {
                                User.userAffiliations.append("hxt_viewer")
                            }
                            
                            if json["seattle"] as! Bool == true {
                                User.userAffiliations.append("seattle")
                            }
                            
                            os_log("userAffiliations: %{private}@", log: .appAuth, type: .info, User.userAffiliations)
                            
                        }
                        
                        // transition to the main application controller
                        self.showApplication()
                        
                    }
                
                }
                task.resume()
                
            } else {
                
                os_log("user is NOT empty....", log: .appAuth, type: .info)
                
                // transition to the main application controller
                self.showApplication()
                
            }
            
        }
    }
    
    func getIdTokenClaims(idToken: String?) -> Data? {
        // Decoding ID token claims.
        var idTokenClaims: Data?
        
        if let jwtParts = idToken?.split(separator: "."), jwtParts.count > 1 {
            let claimsPart = String(jwtParts[1])
            
            let claimsPartPadded = padBase64Encoded(claimsPart)
            
            idTokenClaims = Data(base64Encoded: claimsPartPadded)
        }
        
        return idTokenClaims
    }
    
    // completes base64Encoded string to multiple of 4 to allow for decoding with NSData
    func padBase64Encoded(_ base64Encoded: String) -> String {
        let remainder = base64Encoded.count % 4
        
        if remainder > 0 {
            return base64Encoded.padding(toLength: base64Encoded.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        return base64Encoded
    }
    
}

extension OSLog {
    // log setup
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let appAuth = OSLog(subsystem: subsystem, category: "AppAuth")
}

// class helper for bulleted list
class NSAttributedStringHelper {
    static func createBulletedList(fromStringArray strings: [String], font: UIFont? = nil) -> NSAttributedString {
        
        let fullAttributedString = NSMutableAttributedString()
        let attributesDictionary: [NSAttributedString.Key: Any]
        
        if font != nil {
            attributesDictionary = [NSAttributedString.Key.font: font!]
        } else {
            attributesDictionary = [NSAttributedString.Key: Any]()
        }
        
        for index in 0..<strings.count {
            let bulletPoint: String = "\u{2022}"
            var formattedString: String = "\(bulletPoint) \(strings[index])"
            
            if index < strings.count - 1 {
                formattedString = "\(formattedString)\n"
            }
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString, attributes: attributesDictionary)
            let paragraphStyle = NSAttributedStringHelper.createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            fullAttributedString.append(attributedString)
        }
        
        return fullAttributedString
    }
    
    private static func createParagraphAttribute() -> NSParagraphStyle {
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15, options: NSDictionary() as! [NSTextTab.OptionKey : Any])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 20
        paragraphStyle.headIndent = 31
        return paragraphStyle
    }
}
