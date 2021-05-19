//
//  SignInViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/1/21.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        //Check if both email and password are not nil
        if let email = userEmail.text, let password = userPassword.text{
            //Call firestore authentication
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                if let err = error{
                    //print error if any was found
                    let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //Show messageview
                    self.performSegue(withIdentifier: "signInSegue", sender: self)
                }
            }
            
        }
    }
}
