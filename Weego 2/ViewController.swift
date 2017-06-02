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
        
        showLogout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLogout() {
        let logout = UIButton(type: .system)
        logout.setTitle("Logout", for: .normal)
        logout.addTarget(self, action: #selector(doLogout), for: .touchDown)
        self.view.addSubview(logout)
        
        let margins = view.layoutMarginsGuide
        logout.translatesAutoresizingMaskIntoConstraints = false
        logout.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16).isActive = true
        logout.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logout.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
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

