//
//  ViewController.swift
//  Weego 2
//
//  Created by Nicholas Velloff on 6/1/17.
//  Copyright © 2017 UnitedWeGo LLC. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // User is signed in.
            } else {
                // No User is signed in.
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = Auth.auth().currentUser else {
//            self.presentLoginVC()
            self.showFacebookLogin()
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
    
    func showFacebookLogin() {
        // https://weego-id.firebaseapp.com/__/auth/handler
        
        let loginButton = FBSDKLoginButton()
        loginButton.defaultAudience = .friends
        loginButton.delegate = self
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)

    }
    
    // FBSDKLoginButtonDelegate methods
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
    }
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("loginButton delegate method error: \(error.localizedDescription)")
            return
        } else if result.isCancelled {
            print("Facebook login cancelled")
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Auth.auth().signIn error: \(error.localizedDescription)")
                    return
                }
                self.showLoggedInState()
            }
        }
    }
    
}

