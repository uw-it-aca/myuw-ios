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
let kClientID: String? = clientID
// can also use reverse DNS notion of the client ID for kRedirectURI
let kRedirectURI: String = "edu.uw.myuw-ios:/";
let kAppAuthExampleAuthStateKey: String = "authState";

class AppAuthTest: UIViewController {
    
    // property of the containing class
    private var authState: OIDAuthState?
    
    var label = UILabel()
    var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Large title display mode and preference
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .white
        
        self.title = "MyUW"
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "You are NOT authenticated!"

        view.addSubview(label)

        button = UIButton(frame: CGRect(x: 100, y: 100, width: 180, height: 50))
        button.backgroundColor = .purple
        button.setTitle("Login to MyUW", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)
    
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
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
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
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
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
    
        // TODO: pass a idToken in the webview request header, from the myuw code... validate the idToken and set
        // the Django remote_user based on the validated user. Since the idToken is short-lived, the validation and setting
        // of remote_user will need to happen continuously, otherwise, the idToken will become invalid, and the user will
        // have to reauthenticate the app once again.
                
        if self.authState != nil {
            
            label.text = "You are authenticated! Redirecting"
            button.setTitle("Re-Login", for: .normal)
                        
            // save the accessToken in the singleton process pool
            ProcessPool.idToken = (self.authState?.lastTokenResponse?.idToken)!
            
            // delay for 2 secs
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               
                //TODO: get user info from token and redirect
                self.getUserInfo()
            }
            
        } else {
            
            authWithAutoCodeExchange()
            //authNoCodeExchange()
        }
        
        
                
    }

    func stateChanged() {
        print("stateChanged")
        self.saveState()
        self.updateUI()
    }
    
}

// MARK: User Info and app redirect
extension AppAuthTest {
   
    func getUserInfo() {
                
        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            print("Userinfo endpoint not declared in discovery document")
            return
        }

        print("Performing userinfo request")

        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken

        self.authState?.performAction() { (accessToken, idToken, error) in

            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")")
                return
            }

            guard let accessToken = accessToken else {
                print("Error getting accessToken")
                return
            }

            if currentAccessToken != accessToken {
                print("Access token was refreshed automatically (\(currentAccessToken ?? "CURRENT_ACCESS_TOKEN") to \(accessToken))")
            } else {
                print("Access token was fresh and not updated \(accessToken)")
            }

            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        print("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        print("Non-HTTP response")
                        return
                    }

                    guard let data = data else {
                        print("HTTP response data is empty")
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        print("JSON Serialization Error")
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
                            print("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")")
                        } else {
                            print("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                        }

                        return
                    }

                    if let json = json {
                        
                        print("Success: \(json)")
                        
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
