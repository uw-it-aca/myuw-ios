//
//  AppAuthTest.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 1/7/20.
//  Copyright © 2020 Charlon Palacay. All rights reserved.
//

import AppAuth
import UIKit
import os

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

let kIssuer: String = clientIssuer
let kClientID: String? = clientID
// can also use reverse DNS notion of the client ID for kRedirectURI
let kRedirectURI: String = "edu.uw.myuw-ios:/";
let kAppAuthExampleAuthStateKey: String = "authState";

class AppAuthTest: UIViewController {
    
    // property of the containing class
    private var authState: OIDAuthState?
    
    var loginButton = UIBarButtonItem()
    
    let headerText = UILabel()
    let bodyText = UILabel()
    let label = UILabel()
    
    
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
        headerText.text = "You are not signed in!"
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
        bodyText.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut quis nunc nisl. Integer a ligula nec odio efficitur sagittis quis in sapien. Phasellus tempor dui nec pharetra lacinia."
        view.addSubview(bodyText)
        // autolayout contraints
        bodyText.translatesAutoresizingMaskIntoConstraints = false
        bodyText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bodyText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bodyText.topAnchor.constraint(equalTo: headerText.bottomAnchor, constant: 5).isActive = true
        
        
        label.layer.borderWidth = 0.25
        label.layer.borderColor = UIColor.red.cgColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Sign in"
        label.sizeToFit()
        view.addSubview(label)
        // autolayout contraints
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        // set topanchor of label equal to bottomanchor of textview
        label.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 10).isActive = true
        
        // add a right button in navbar programatically
        loginButton = UIBarButtonItem(title: "Sign in", style: .plain, target: self, action: #selector(loginUser))
        self.navigationItem.rightBarButtonItem  = loginButton
        
        // get authstate
        self.loadState()

    }
    
    @objc private func loginUser(){
        os_log("Sign in Button tapped", log: .ui, type: .info)
        authWithAutoCodeExchange()
    }
    
    func authWithAutoCodeExchange() {
        
        os_log("authWithAutoCodeExchange", log: .ui, type: .info)
        
        guard let issuer = URL(string: kIssuer) else {
            os_log("Error creating URL for: %@", log: .auth, type: .error, kIssuer)
            return
        }

        os_log("Error creating URL for: %@", log: .auth, type: .info, kIssuer)

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
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
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
extension AppAuthTest: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        os_log("didChange", log: .auth, type: .info)
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        os_log("Received authorization error: %@", log: .auth, type: .info, error.localizedDescription)
    }
}


//MARK: Helper Methods
extension AppAuthTest {

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
        
        guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }

        if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState {
            self.setAuthState(authState)
        }
         
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
        
        if self.authState != nil {
            
            // blank loading message
            label.text = ""
            
            loginButton.isEnabled = false
                        
            // save & store the accessToken in the singleton process pool
            ProcessPool.idToken = (self.authState?.lastTokenResponse?.idToken)!
            
            // get user info from token... and build UI display
            self.getUserInfo()

        }

    }

    func stateChanged() {
        os_log("stateChanged", log: .auth, type: .info)
        self.saveState()
        self.updateUI()
    }
    
}

// MARK: User Info and app redirect
extension AppAuthTest {
   
    func getUserInfo() {
        
        os_log("getUserInfo", log: .ui, type: .info)
        
        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            os_log("Userinfo endpoint not declared in discovery document", log: .auth, type: .error)
            return
        }

        os_log("Performing userinfo request", log: .auth, type: .info)

        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken

        self.authState?.performAction() { (accessToken, idToken, error) in

            if error != nil  {
                os_log("Error fetching fresh tokens: %@", log: .auth, type: .error, error?.localizedDescription ?? "ERROR")
                return
            }

            guard let accessToken = accessToken else {
                os_log("Error getting accessToken", log: .auth, type: .error)
                return
            }

            if currentAccessToken != accessToken {
                os_log("Access token was refreshed automatically: %@ to %@", log: .auth, type: .info, currentAccessToken ?? "CURRENT_ACCESS_TOKEN", accessToken)
            } else {
                os_log("Access token was fresh and not updated: %@", log: .auth, type: .info, accessToken)
            }

            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        os_log("HTTP request failed: %@", log: .auth, type: .error, error?.localizedDescription ?? "ERROR")
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        os_log("Non-HTTP response", log: .auth, type: .info)
                        return
                    }

                    guard let data = data else {
                        os_log("HTTP response data is empty", log: .auth, type: .info)
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        os_log("JSON Serialization Error", log: .auth, type: .error)
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
                            os_log("Authorization Error: %@. Response: %@", log: .auth, type: .error, oauthError.localizedDescription, responseText ?? "RESPONSE_TEXT" )
                        } else {
                            os_log("HTTP: %@. Response: %@", log: .auth, type: .info, response.statusCode, responseText ?? "RESPONSE_TEXT" )
                        }

                        return
                    }

                    if let json = json {
                        
                        os_log("Successfully decoded: %{private}@", log: .auth, type: .info, json)
                        
                        // set global user attributes from the oidc response here...
                        userAffiliations = ["student", "seattle", "undergrad"]
                        userNetID = (json["email"] as! String).split{$0 == "@"}.map(String.init)[0]
                        
                        // set tabControlleer as rootViewController after getting user info
                        let tabController = TabViewController()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window!.rootViewController = tabController
                    
                    }
                }
            }

            task.resume()
        }
    }
}

extension OSLog {
    // subsystem
    private static var subsystem = Bundle.main.bundleIdentifier!
    // log categories
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let auth = OSLog(subsystem: subsystem, category: "Authentication")
}
