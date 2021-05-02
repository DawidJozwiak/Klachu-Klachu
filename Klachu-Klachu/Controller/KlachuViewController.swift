//
//  KlachuViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/2/21.
//

import UIKit
import Firebase

class KlachuViewController: UIViewController {
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var messageView: UITableView!
    
    let db = Firestore.firestore()
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let text = userInput.text, let sender = Auth.auth().currentUser?.email{
            db.collection("message").addDocument(data: ["sender" : sender, "body" : text, "date": Date().timeIntervalSince1970]) { (error) in
                if let err = error{
                    let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("work")
                }
            }
            
        }
        
    }
    var message: [MessageData] = [
        MessageData(senderEmail: "dawidjoz@wp.pl", message: "Hi!"),
        MessageData(senderEmail: "dawidjoz@wp.pl", message: "Hey!"),
        MessageData(senderEmail: "dawidjoz@wp.pl", message: "Hello!"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        messageView.dataSource = self
        messageView.register(UINib(nibName: "CustomisedCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        
        showPreviousMessages()
    }
    
    func showPreviousMessages(){
        
        db.collection("message")
            .order(by: "date")
            .addSnapshotListener {
            (querySnapshot, error) in
           
            self.message = []
            
            if let err = error{
                let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else{
                //Contains objects and is able to access documents
                if let docs = querySnapshot?.documents{
                    for doc in docs {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let messageBody = data["body"] as? String{
                            let newMessage = MessageData(senderEmail: sender, message: messageBody)
                            self.message.append(newMessage)
                            DispatchQueue.main.async {
                                self.messageView.reloadData()
                            }
                            
                        }
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
            self.navigationController?.isNavigationBarHidden = true
            
            let controllers = self.navigationController?.viewControllers
                          for vc in controllers! {
                            if vc is FirstViewController {
                              _ = self.navigationController?.popToViewController(vc as! FirstViewController, animated: true)
                            }
                         }
            
        } catch let signOutError as NSError{
            let alert = UIAlertController(title: "Log out error!", message: signOutError as? String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}

extension KlachuViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! CustomisedCell
        cell.message.text = message[indexPath.row].message
        return cell
    }
    
    
}

