//
//  AppAuthTest.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 1/7/20.
//  Copyright © 2020 Charlon Palacay. All rights reserved.
//

import AppAuth
import UIKit

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

let kIssuer: String = "https://accounts.google.com";
let kClientID: String? = ""
// can also use reverse DNS notion of the client ID for kRedirectURI
let kRedirectURI: String = "edu.uw.myuw-ios:/";
let kAppAuthExampleAuthStateKey: String = "authState";

class AppAuthTest: UIViewController {
    
    // property of the containing class
    private var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadState()
        self.updateUI()

    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        authWithAutoCodeExchange()
        //authNoCodeExchange()
    }
    
    func authWithAutoCodeExchange() {
        
        print("authWithAutoCodeExchange")
        
        guard let issuer = URL(string: kIssuer) else {
            print("Error creating URL for : \(kIssuer)")
            return
        }

        print("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
                return
            }

            print("Got configuration: \(config)")
            
            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        print("Error retrieving configuration OR clientID")
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
            
            }
        }
    }
    
    func authNoCodeExchange() {
        
        print("authNoCodeExchange")
        
        guard let issuer = URL(string: kIssuer) else {
            print("Error creating URL for : \(kIssuer)")
            return
        }

        print("Fetching configuration for issuer: \(issuer)")

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            if let error = error  {
                print("Error retrieving discovery document: \(error.localizedDescription)")
                return
            }

            guard let configuration = configuration else {
                print("Error retrieving discovery document. Error & Configuration both are NIL!")
                return
            }

            print("Got configuration: \(configuration)")

            if let clientId = kClientID {

                self.doAuthWithoutCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil)

            } else {

                self.doClientRegistration(configuration: configuration) { configuration, response in

                    guard let configuration = configuration, let response = response else {
                        return
                    }

                    self.doAuthWithoutCodeExchange(configuration: configuration,
                                                   clientID: response.clientID,
                                                   clientSecret: response.clientSecret)
                }
            }
        }
    }
    
    
    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        
        print("doClientRegistration")
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            print("Error creating URL for : \(kRedirectURI)")
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
        print("Initiating registration request")

        OIDAuthorizationService.perform(request) { response, error in

            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                print("Got registration response: \(regResponse)")
                callback(configuration, regResponse)
            } else {
                print("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        print("doAuthWithAutoCodeExchange")
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            print("Error creating URL for : \(kRedirectURI)")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            if let authState = authState {
                self.setAuthState(authState)
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
        
    }
    
    func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        print("doAuthWithoutCodeExchange")
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            print("Error creating URL for : \(kRedirectURI)")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: self) { (response, error) in

            if let response = response {
                let authState = OIDAuthState(authorizationResponse: response)
                self.setAuthState(authState)
                print("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
                // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            }
        }
    }
    
    
}


//MARK: OIDAuthState Delegate
extension AppAuthTest: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        print("didChange")
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
}


//MARK: Helper Methods
extension AppAuthTest {

    func saveState() {
        
        print("saveState")
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        
        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.synchronize()
    }
    
    func loadState() {
        
        print("loadState")
        
        guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }

        if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState {
            self.setAuthState(authState)
        }
         
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        
        print("setAuthState")
        
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }

    func updateUI() {
    
        print("updateUI")
        
        view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "You are NOT authenticated!"
    
        view.addSubview(label)
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 180, height: 50))
        button.backgroundColor = .purple
        button.setTitle("Login to MyUW", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)
        
        print("authState?.isAuthorized...", self.authState?.isAuthorized as Any)
        print("authState?.lastTokenResponse.idToken...", self.authState?.lastTokenResponse?.idToken as Any)
        print("authState?.lastTokenResponse.accessToken...", self.authState?.lastTokenResponse?.accessToken as Any)
        
        // TODO: pass a token in the webview request header, from the myuw code... validate the idToken and set
        // the Django remote_user based on the validated user. Since the accessToken is short-lived, the validation and setting
        // of remote_user will need to happen continuously, otherwise, the accessToken will become invalid, and the user will
        // have to reauthenticate the app once again.
        
        if (self.authState?.isAuthorized ?? false) {
            label.text = "You are authenticated! Redirecting"
            button.setTitle("Re-Login", for: .normal)
                        
            // save the accessToken in the singleton process pool
            ProcessPool.myToken = (self.authState?.lastTokenResponse?.accessToken)!
            
            // delay for 2 secs
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                // set global user attributes from the oidc response here...
                userAffiliations = ["student", "seattle", "undergrad"]
                userNetID = "getauthusername"
                
                // Code you want to be delayed
                let tabController = TabViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                // set tabControlleer as rootViewController after simulating the user logged in
                appDelegate.window!.rootViewController = tabController
            }
            
            
        } else {
            authWithAutoCodeExchange()
            //authNoCodeExchange()
        }
        
        
                
    }

    func stateChanged() {
        print("stateChanged")
        self.saveState()
        //self.updateUI()
    }
    
}
