//
//  SignInViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 3/25/21.
//

import UIKit

import Firebase
import GoogleSignIn

@objc(SignInViewController)
class SignInViewController: UIViewController {
    @IBOutlet weak var signInButton: GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
                MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
            }
        }
    }
    
    @IBAction func performSignOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }
    deinit {
      if let handle = handle {
          Auth.auth().removeStateDidChangeListener(handle)
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
//            _ = self.navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
      }
    }
}



