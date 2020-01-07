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
let kClientID: String? = "xxxxxx"
let kRedirectURI: String = "xxxxx:/";
let kAppAuthExampleAuthStateKey: String = "authState";

class AppAuthTest: UIViewController {
    
    // property of the containing class
    private var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadState()
        self.updateUI()
        
        //self.authWithAutoCodeExchange()

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
                /*
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        print("Error retrieving configuration OR clientID")
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
                */
            }
        }
    }
    
    /*
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
    }*/
    
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
    
    
}


//MARK: OIDAuthState Delegate
extension AppAuthTest: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
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
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        /*
        if let authState = self.authState {
            data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }*/
        
        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.synchronize()
        print(UserDefaults.standard)
    }
    
    func loadState() {
        
        print("loadState")
        
           guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
               return
           }

           if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
               self.setAuthState(authState)
           }
           
        /*
           if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState {
               self.setAuthState(authState)
           }
         */
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
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
    
        view.addSubview(label)

        //var isAuthorized = self.authState?.lastAuthorizationResponse.authorizationCode != nil && !((self.authState?.lastTokenResponse) != nil)

        print("isAuthorized...", self.authState?.isAuthorized)
        
        if (self.authState?.isAuthorized ?? false) {
            label.text = "You are authenticated!"
        } else {
            label.text = "You are NOT authenticated!"
            self.authWithAutoCodeExchange()
        }
                
    }

    func stateChanged() {
        self.saveState()
        self.updateUI()
    }
    
}
