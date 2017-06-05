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
        
        view.backgroundColor = .gray
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            guard let currentUser = auth.currentUser else {
                return
            }
            
            print("User record state change:")
            print("currentUser.uid \(String(describing: currentUser.uid))")
            print("currentUser.displayName \(String(describing: currentUser.displayName))")
            print("currentUser.phoneNumber \(String(describing: currentUser.phoneNumber))")
            print("currentUser.photoURL \(String(describing: currentUser.photoURL))")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = Auth.auth().currentUser else {
            self.presentLoginVC()
            return
        }
        
        showLoggedInState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoggedInState() {
        
        let authenticatedVC = Authenticated()
        authenticatedVC.modalTransitionStyle = .flipHorizontal
        self.present(authenticatedVC, animated: true) {
            print("Did present Authenticated VC")
        }
        
    }
    
    // How we customize a FirebaseUI VC, Temp we will roll our own
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthViewController(nibName: nil, bundle: nil, authUI: authUI)
    }
    
    func presentLoginVC() {
        let authUI = FUIAuth.defaultAuthUI()
        
        authUI?.isSignInWithEmailHidden = true
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)]
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()
        authViewController.isNavigationBarHidden = true
        authViewController.modalTransitionStyle = .flipHorizontal
        
        self.present(authViewController, animated: true, completion: {
            print("authViewController present completion")
        })
    }
    
}

