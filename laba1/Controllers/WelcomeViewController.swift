//
//  WelcomeViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/9/21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
 
    @IBOutlet weak var loginWithoutAccButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.styleHollowButton(signUpButton)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(loginWithoutAccButton)
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginWithoutAccTapped(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.LoginWithoutAccSeg, sender: nil)
    }
    
   

}
