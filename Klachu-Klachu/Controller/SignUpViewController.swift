//
//  SignUpViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/1/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    //Create firestore database object
    let db = Firestore.firestore()
    
    //Sign up button
    @IBAction func signUpPressed(_ sender: Any) {
        //check if both email and user are not nil
        if let userEmail = email.text, let userPassword = password.text{
            //Call authentication
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
                //if there was an error display information about it
                if let err = error{
                    let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //if user signed up correctly add his nickname to the database
                    self.db.collection("users").addDocument(data: ["email" : userEmail]){ (error) in
                        if let err = error{
                            let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    //go to the messageviewcontroller if successful
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
