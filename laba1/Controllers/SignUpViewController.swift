//
//  SignUpViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/9/21.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFIeld: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpNavBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        errorLabel.alpha = 0
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = view.backgroundColor
        self.navigationController?.navigationBar.tintColor = .black
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextFIeld)
        Utilities.styleFilledButton(signUpButton)
//        self.navigationController?.navigationBar.backgroundColor = view.backgroundColor
        // Do any additional setup after loading the view.
    }
    
    //Check the fields and validate that data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextFIeld.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextFIeld.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure that your password is at least 8 characters, contains a special character and a number."
        }
        
        
        return nil
    }
    

    @IBAction func signUpTapped(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            
            showError(error!)
        }
        
        else {
            
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextFIeld.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                if err != nil {
                    self.showError("Error creating user")
                } else {
                    
                    self.showSuccsesMessage()
                    
                }
            }
            
        }
        
    }
    
    
    func showSuccsesMessage () {
        let alert = UIAlertController(title: "Sign Up successfull", message: "", preferredStyle: .alert)
        
        

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
        
        
    }
    
    func showError(_ message: String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }

}
