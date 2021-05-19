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
    
    var reciever: String?
    
    let db = Firestore.firestore()
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let text = userInput.text, let sender = Auth.auth().currentUser?.email{
            db.collection("messages").addDocument(data: ["sender" : sender, "body" : text, "reciever": reciever ?? "", "date": Date().timeIntervalSince1970]) { (error) in
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
    var message: [MessageData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false
        self.navigationController?.isNavigationBarHidden = false
        messageView.dataSource = self
        messageView.register(UINib(nibName: "CustomisedCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        title = "Klachu - Klachu"
        showPreviousMessages()
    }
    
    func showPreviousMessages(){
        
        db.collection("messages")
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
                            if let sender = data["sender"] as? String, let messageBody = data["body"] as? String, let rec = data["reciever"] as? String{
                                if((sender == Auth.auth().currentUser?.email && self.reciever! == rec) || (sender == self.reciever! && Auth.auth().currentUser?.email == rec)) {
                                    let newMessage = MessageData(senderEmail: sender, message: messageBody, reciever: rec)
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
        
        
    }
}

extension KlachuViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = message[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! CustomisedCell
        
        
        print(msg.reciever)
        if let rec = reciever{
            print(rec)
            if msg.senderEmail == Auth.auth().currentUser?.email{
                cell.message.text = msg.message
                cell.bubble1.isHidden = true
                cell.bubble.isHidden = false
                cell.messageCell.backgroundColor = UIColor(named: "MyTeal")
                cell.message.textColor = .white
            }
            else if msg.senderEmail == rec{
                cell.message.text = msg.message
                cell.bubble1.isHidden = false
                cell.bubble.isHidden = true
                cell.messageCell.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
                cell.message.textColor = .black
            }
        }
        
        
        
        return cell
    }
    
    
}

