//
//  AvatarViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/20/21.
//

import UIKit
import Firebase

class AvatarViewController: UIViewController {
    
    let db = Firestore.firestore()
    var userEmail: String?
    var userNickname: String?
    
    var chosenImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    @IBAction func mainButton(sender: UIButton) {
        let arr = [""]
        chosenImage = sender.tag
        //if user signed up correctly add his nickname to the database
        if let mail = userEmail, let nick = userNickname{
            self.db.collection("users").document(nick).setData(["email" : mail, "nickname" : nick, "image" : chosenImage]){ (error) in
                if let err = error{
                    let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    self.db.collection("friends").document(nick).setData(["user": mail, "friendsList" : arr]){
                        (error) in
                            if let err = error{
                                let alert = UIAlertController(title: "Incorrect data!", message: err.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            else{
                                self.performSegue(withIdentifier: "avatarSegue", sender: self)
                            }
                    }
                   
                }
            }
            
        }
    }
}
