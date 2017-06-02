//
//  ViewController.swift
//  Weego 2
//
//  Created by Nicholas Velloff on 6/1/17.
//  Copyright © 2017 UnitedWeGo LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebasePhoneAuthUI

class ViewController: UIViewController, FUIAuthDelegate {
    
    /** @fn authUI:didSignInWithUser:error:
     @brief Message sent after the sign in process has completed to report the signed in user or
     error encountered.
     @param authUI The @c FUIAuth instance sending the message.
     @param user The signed in user if the sign in attempt was successful.
     @param error The error that occurred during sign in, if any.
     */
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        if let error = error {
            print("login error: \(error.localizedDescription)")
        }
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            
            guard let currentUser = auth.currentUser else {
                
                print("currentUser nil, showLogin()")
                
                self?.showLogin()
                return
            }
            
            
            // Shows how we would update a users name
            self?.updateDisplayName(displayName: "Nick \(arc4random_uniform(150))")
            
            
            print("currentUser.uid \(String(describing: currentUser.uid))")
            print("currentUser.displayName \(String(describing: currentUser.displayName))")
            print("currentUser.phoneNumber \(String(describing: currentUser.phoneNumber))")
            print("currentUser.email \(String(describing: currentUser.email))")
            print("currentUser.photoURL \(String(describing: currentUser.photoURL))")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = Auth.auth().currentUser else {
            return
        }
        
        showLoggedInState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoggedInState() {
        
        let logout = UIButton(type: .system)
        logout.setTitle("Logout", for: .normal)
        logout.addTarget(self, action: #selector(doLogout), for: .touchDown)
        self.view.addSubview(logout)
        
        let margins = view.layoutMarginsGuide
        logout.translatesAutoresizingMaskIntoConstraints = false
        logout.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16).isActive = true
        logout.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logout.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        let invite = UIButton(type: .system)
        invite.setTitle("Invite", for: .normal)
        invite.addTarget(self, action: #selector(doInvite), for: .touchDown)
        self.view.addSubview(invite)
        
        invite.translatesAutoresizingMaskIntoConstraints = false
        invite.topAnchor.constraint(equalTo: logout.bottomAnchor, constant: 16).isActive = true
        invite.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        invite.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthViewController(nibName: nil, bundle: nil, authUI: authUI)
    }
    
    func showLogin() {
        let authUI = FUIAuth.defaultAuthUI()
        
        authUI?.isSignInWithEmailHidden = true
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)]
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()
        authViewController.isNavigationBarHidden = true
        
        self.present(authViewController, animated: true, completion: {
            print("authViewController present completion")
        })
    }

    func doLogout() {
        print("doLogout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func doInvite() {
        print("doInvite")
        
        let user = Auth.auth().currentUser
        guard let displayName = user?.displayName else {
            fatalError("displayName empty")
        }
        
        guard let escapedDisplayName = displayName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            fatalError("displayName failed to escape")
        }
        
        let dynamicLinkDomain = "e398h.app.goo.gl"
        let deepLinkString = "https://weego.live/invite?displayName=\(escapedDisplayName)&eventId=someEventId"
        
        
        guard let deepLink = URL(string: deepLinkString) else {
            fatalError("deepLink failed to construct")
        }
        
        let components = DynamicLinkComponents(link: deepLink, domain: dynamicLinkDomain)

        let iOSParameters = DynamicLinkIOSParameters(bundleID: "unitedwego.Weego-2")
        iOSParameters.minimumAppVersion = "2.0.0"
        iOSParameters.appStoreID = "1243780258"
        
        components.iOSParameters = iOSParameters
        
        print("long url generated: \(String(describing: components.url))")
        
        
        
//        FirebaseOptions.default().deepLinkURLScheme ????
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        components.options = options
        
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print(shortURL?.absoluteString ?? "")
            // send over SMS dude!
        }
        
    }
    
    func updateDisplayName(displayName: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges() { [weak self] error in
            
            if let error = error {
                print("changeRequest?.commitChanges error \(error.localizedDescription)")
                print("logging out, account issue.")
                self?.doLogout()
                return
            } else if let name = Auth.auth().currentUser?.displayName {
                print("Updated user name: \(name)")
            }
        }
    }
    
}

