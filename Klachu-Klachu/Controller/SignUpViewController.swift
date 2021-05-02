//
//  SignUpViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/1/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    
    @IBAction func signUpPressed(_ sender: Any) {
        if let userEmail = email.text, let userPassword = password.text{
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
                if let err = error{
                    let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    self.performSegue(withIdentifier: "signUpSegue", sender: self)
                }
            }
        }
        
    }
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
}
