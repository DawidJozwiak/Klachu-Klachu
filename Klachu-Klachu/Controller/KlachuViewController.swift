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
                    DispatchQueue.main.async{
                       self.userInput.text = ""
                    }
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
        self.navigationController?.isNavigationBarHidden = false
        messageView.dataSource = self
        messageView.register(UINib(nibName: "CustomisedCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        title = "Klachu - Klachu"
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
                                let indexPath1 = IndexPath(row: self.message.count - 1, section: 0)
                                self.messageView.scrollToRow(at: indexPath1, at: .top, animated: false)
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
        let msg = message[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! CustomisedCell
        cell.message.text = msg.message
        
        
        if msg.senderEmail == Auth.auth().currentUser?.email{
            cell.bubble1.isHidden = true
            cell.bubble.isHidden = false
            cell.messageCell.backgroundColor = UIColor(named: "MyTeal")
            cell.message.textColor = .white
        }
        else{
            cell.bubble1.isHidden = false
            cell.bubble.isHidden = true
            cell.messageCell.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
            cell.message.textColor = .black
        }
       
        return cell
    }
    
    
}

