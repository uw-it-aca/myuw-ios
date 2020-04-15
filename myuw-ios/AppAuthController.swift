//
//  AppAuthController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 1/7/20.
//  Copyright © 2020 Charlon Palacay. All rights reserved.
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

class AppAuthController: UIViewController {
    
    // property of the containing class
    private var authState: OIDAuthState?
    
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
        bodyText.frame.size.height = 200.0
        bodyText.sizeToFit()
        view.addSubview(bodyText)
        // autolayout contraints
        bodyText.translatesAutoresizingMaskIntoConstraints = false
        bodyText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bodyText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bodyText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 15).isActive = true
        
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.contentEdgeInsets = UIEdgeInsets(top: 13,left: 5,bottom: 13,right: 5)
        signInButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        signInButton.sizeToFit()
        view.addSubview(signInButton)
        // autolayout contraints
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        // set topanchor of label equal to bottomanchor of textview
        signInButton.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 50).isActive = true
        signInButton.backgroundColor = UIColor(hex: "#4b2e83")
        signInButton.layer.cornerRadius = 10
        
        // set initial text for sign-in messaging
        headerText.text = "Welcome"
        bodyText.text = "Please sign in to continue."
        
        // get authstate
        self.loadState()
        self.showState()
        
    }
    
    @objc private func loginUser(){
        os_log("Sign in Button tapped", log: .ui, type: .info)
        authWithAutoCodeExchange()
    }
    
    @objc func autoSignOut() {
        
        os_log("Automatically signing user out", log: .auth, type: .info)
        
        // clear authstate to signout user
        setAuthState(nil)
        // clear state storage
        UserDefaults.standard.removeObject(forKey: kAppAuthExampleAuthStateKey)
        // clear userAffiliations
        User.userAffiliations = []
        
        // show hidden messaging
        self.headerText.isHidden = false
        self.bodyText.isHidden = false
        self.signInButton.isHidden = false
        
        // set auto sign-out messaging
        self.headerText.text = "Signed Out"
        self.bodyText.text = "You have been signed out, likely due to an application error or prolonged inactivity. Sign in to continue."
        
        /*
         let navController = UINavigationController(rootViewController: self)
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         // set appAuth controller as rootViewController
         appDelegate.window!.rootViewController = navController
         */
    }
    
    func authWithAutoCodeExchange() {
        
        os_log("authWithAutoCodeExchange", log: .ui, type: .info)
        
        guard let issuer = URL(string: kIssuer) else {
            os_log("Error creating URL for: %@", log: .auth, type: .error, kIssuer)
            return
        }
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            guard let config = configuration else {
                os_log("Error retrieving discovery document: %@", log: .auth, type: .error, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
                return
            }
            
            os_log("Got configuration: %@", log: .ui, type: .info, config)
            
            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                
                self.doClientRegistration(configuration: config) { configuration, response in
                    
                    guard let configuration = configuration, let clientID = response?.clientID else {
                        os_log("Error retrieving configuration OR clientID", log: .auth, type: .error)
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
        
        os_log("doClientRegistration", log: .auth, type: .info)
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            os_log("Error creating URL for: %@", log: .auth, type: .error, kRedirectURI)
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
        os_log("Initiating registration request", log: .auth, type: .info)
        
        OIDAuthorizationService.perform(request) { response, error in
            
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                os_log("Got registration response: %@", log: .auth, type: .info, regResponse)
                callback(configuration, regResponse)
            } else {
                os_log("Registration error: %@", log: .auth, type: .error, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
            }
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        os_log("doAuthWithAutoCodeExchange", log: .auth, type: .info)
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            os_log("Error creating URL for: %@", log: .auth, type: .info, kRedirectURI)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Error accessing AppDelegate", log: .auth, type: .error)
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              //scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
            scopes: ["openid profile email offline_access"],
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil)
        
        // performs authentication request
        os_log("Initiating authorization request with scope: %@", log: .auth, type: .info, request.scope ?? "DEFAULT_SCOPE")
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            if let authState = authState {
                self.setAuthState(authState)
                os_log("Got authorization tokens. Access token: %@", log: .auth, type: .info, authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")
            } else {
                os_log("Authorization error: %@", log: .auth, type: .info, error?.localizedDescription ?? "DEFAULT_ERROR")
                self.setAuthState(nil)
            }
        }
        
    }
    
}


//MARK: OIDAuthState Delegate
extension AppAuthController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        os_log("didChange", log: .auth, type: .info)
        self.stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        os_log("Received authorization error: %@", log: .auth, type: .info, error.localizedDescription)
    }
}


//MARK: Helper Methods
extension AppAuthController {
    
    func saveState() {
        
        os_log("saveState", log: .auth, type: .info)
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        
        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.synchronize()
    }
    
    func loadState() {
        
        os_log("loadState", log: .auth, type: .info)
        
        /*
        guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }
        
        if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState {
            self.setAuthState(authState)
        }
        */
        
        guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }
 
        var authState: OIDAuthState? = nil

        if #available(iOS 12.0, *) {
            authState = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState
        } else {
            authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState
        }

        if let authState = authState {
            print("Authorization state has been loaded.")

            self.setAuthState(authState)
        }
        
    }
    
    func showState() {
        print("Current authorization state: ")

        print("Access token: \(authState?.lastTokenResponse?.accessToken ?? "none")")

        print("ID token: \(authState?.lastTokenResponse?.idToken ?? "none")")

        print("Expiration date: \(String(describing: authState?.lastTokenResponse?.accessTokenExpirationDate))")
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        
        os_log("setAuthState", log: .auth, type: .info)
        
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }
    
    func updateUI() {
        
        os_log("updateUI", log: .ui, type: .info)
        
        /*
        if (self.authState != nil ) {
            os_log("Has authstate", log: .ui, type: .info)
            headerText.isHidden = true
            bodyText.isHidden = true
            signInButton.isHidden = true
            
            if User.userAffiliations.isEmpty {
                // get user netid and affiliations
                self.getUserAffiliations()
            } else {
                // transition to the main application controller
                showApplication()
            }
            
        } else {
            os_log("NO authstate", log: .ui, type: .info)
            // sign user out automatically
            self.autoSignOut()
        }
         */
   
        // if logged in... hide the sign-in content
        if self.authState != nil {
            
            headerText.isHidden = true
            bodyText.isHidden = true
            signInButton.isHidden = true
            
            print(User.userAffiliations)
            
            if User.userAffiliations.isEmpty {
                // get user netid and affiliations
                self.getUserAffiliations()
            } else {
                // transition to the main application controller
                showApplication()
            }
            
        }
    
        
    }
    
    func stateChanged() {
        os_log("stateChanged", log: .auth, type: .info)
        self.saveState()
        self.updateUI()
        self.showState()
    }
    
}

// MARK: User Info and app redirect
extension AppAuthController {
    
    func showError() {
        
        os_log("showError", log: .ui, type: .info)
        
        // show the error controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let errorController = ErrorController()
        let navController = UINavigationController(rootViewController: errorController)
        appDelegate.window!.rootViewController = navController
    }
    
    func showApplication() {
        
        os_log("showApplication", log: .ui, type: .info)
        
        // MARK: transition to appController (tabs)
        let appController = ApplicationController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set the main controller as the root controller on app load
        appDelegate.window!.rootViewController = appController
    }
    
    func getUserAffiliations() {
        
        os_log("getUserAffiliations", log: .ui, type: .info)
        
        // MARK: refresh access token before sending to myuw as authentication header
        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken
        
        self.authState?.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                os_log("Error fetching fresh tokens: %@", log: .auth, type: .error, error?.localizedDescription ?? "ERROR")
                
                // sign user out if unable to get fresh tokens (refresh token expired)
                self.autoSignOut()
                return
            }
            
            guard let accessToken = accessToken else {
                os_log("Error getting accessToken", log: .auth, type: .error)
                
                // sign user out if unable to get access token
                self.autoSignOut()
                return
            }
            
            // log accessToken freshness
            if currentAccessToken != accessToken {
                os_log("Access token was refreshed automatically: %@ to %@", log: .auth, type: .info, currentAccessToken ?? "CURRENT_ACCESS_TOKEN", accessToken)
            } else {
                os_log("Access token was fresh and not updated: %@", log: .auth, type: .info, accessToken)
            }
            
            // MARK: get user netid by decoding idtoken
            // TODO: consider creating a Claims struct and mapping everything to it's attributes
            if (self.authState?.isAuthorized ?? false) {
                let idTokenClaims = self.getIdTokenClaims(idToken: idToken ?? "") ?? Data()
                os_log("idTokenClaims: %@", log: .auth, type: .info, (String(describing: String(bytes: idTokenClaims, encoding: .utf8))))
                let claimsDictionary = try! JSONSerialization.jsonObject(with: idTokenClaims, options: .allowFragments) as? [String: Any]
                os_log("claimsDictionary: %@", log: .auth, type: .info, claimsDictionary!)
                User.userNetID = claimsDictionary!["sub"] as! String? ?? ""
            }
        
            // MARK: get user affiliations from myuw endpoint
            let affiliationURL = URL(string: "\(appHost)\(appAffiliationEndpoint)")
            os_log("start affiliation request: %@", log: .affiliations, type: .info, affiliationURL!.absoluteString)
            var urlRequest = URLRequest(url: affiliationURL!)
            
            // send access token in authorization header
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(String(describing: self.authState?.lastTokenResponse?.accessToken)))"]
            
            // create a task to request affiliations from myuw endpoint
            let task = URLSession.shared.dataTask(with: urlRequest) {
                data, response, error in DispatchQueue.main.async {
                    
                    guard error == nil else {
                        os_log("HTTP request failed: %@", log: .affiliations, type: .error, error?.localizedDescription ?? "ERROR")
                        // show the error controller
                        self.showError()
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        os_log("Non-HTTP response", log: .affiliations, type: .info)
                        // show the error controller
                        self.showError()
                        return
                    }
                    
                    guard let data = data else {
                        os_log("HTTP response data is empty", log: .affiliations, type: .info)
                        // show the error controller
                        self.showError()
                        return
                    }
                    
                    //MARK: handle the cookies from api response
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        
                        os_log("Getting cookies from affiliation response...", log: .affiliations, type: .info)
                        
                        // MARK: setup global data store and process pool for cookie handling
                        let wkDataStore = WKWebsiteDataStore.default()
                        let configuration = WKWebViewConfiguration()
                        let webView: WKWebView!
                    
                        configuration.websiteDataStore = wkDataStore
                        configuration.processPool = ProcessPool.sharedPool
                        webView = WKWebView(frame: self.view.frame, configuration: configuration)
                        
                        for cookie in cookies {
                            os_log("Cookie name: %@. Cookie value: %@", log: .affiliations, type: .info, cookie.name, cookie.value)
                            // store cookies in WKWebsiteDataStore to be shared with webviews
                            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                            //HTTPCookieStorage.shared.setCookie(cookie)
                        }
                    }
                    
                    //MARK: handle the json response
                    var json: [AnyHashable: Any]?
                    
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        os_log("JSON Serialization Error", log: .affiliations, type: .error)
                        // show the error controller
                        self.showError()
                    }
                    
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
                            os_log("Authorization Error: %@. Response: %@", log: .affiliations, type: .error, oauthError.localizedDescription, responseText!)
                        } else {
                            os_log("HTTP: %@. Response: %@", log: .affiliations, type: .info, response.statusCode.description, responseText!)
                        }
                        
                        return
                    }
                    
                    if let json = json {
                        
                        os_log("Successfully decoded: %{private}@", log: .affiliations, type: .info, json)
                        
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
                        
                        os_log("userAffiliations: %{private}@", log: .affiliations, type: .info, User.userAffiliations)
                        
                        // update the tokens in the singleton process pool
                        ProcessPool.accessToken = accessToken
                        ProcessPool.idToken = idToken!
                        
                        // transition to the main application controller
                        self.showApplication()
                        
                    }
                    
                }
                
            }
            task.resume()
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
    // subsystem
    private static var subsystem = Bundle.main.bundleIdentifier!
    // log categories
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let auth = OSLog(subsystem: subsystem, category: "Authentication")
    static let affiliations = OSLog(subsystem: subsystem, category: "Affiliations")
}
