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
        print("")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("user.uid \(String(describing: user?.uid))")
            print("user.displayName \(String(describing: user?.displayName))")
            print("user.phoneNumber \(String(describing: user?.phoneNumber))")
            print("user.email \(String(describing: user?.email))")
            print("user.photoURL \(String(describing: user?.photoURL))")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = Auth.auth().currentUser else {
            showLogin()
            return
        }
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "Nick 1"
        changeRequest?.commitChanges() { error in
            print("changeRequest?.commitChanges error? \(error?.localizedDescription ?? "no")")
            if let user = Auth.auth().currentUser {
                print("Updated user name: \(String(describing: user.displayName))")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showLogin() {
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
        
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()
        
        self.present(authViewController, animated: true, completion: {
            print("authViewController present completion")
        })
    }


}

