//
//  KlachuViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/2/21.
//

import UIKit
import Firebase

class KlachuViewController: UIViewController {
    
    //Declare buttons and user inputs
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var messageView: UITableView!
    
    //Reciever email taken from previous viewcontroller
    var reciever: String?
    //Create firestore database object
    let db = Firestore.firestore()
    //send button pressed event
    @IBAction func sendPressed(_ sender: UIButton) {
        //if text and email are not nil
        if let text = userInput.text, let sender = Auth.auth().currentUser?.email{
            //ented messages database
            db.collection("messages").addDocument(data: ["sender" : sender, "body" : text, "reciever": reciever ?? "", "date": Date().timeIntervalSince1970]) { (error) in
                //show error alert if it is not nil
                if let err = error{
                    let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //reset textfield
                    DispatchQueue.main.async{
                        self.userInput.text = ""
                    }
                }
            }
        }
        
    }
    //declared messagedata structure
    var message: [MessageData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show navigation bar and back button
        self.navigationItem.hidesBackButton = false
        self.navigationController?.isNavigationBarHidden = false
        //set delegate of messageview to self
        messageView.dataSource = self
        //register cell
        messageView.register(UINib(nibName: "CustomisedCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        //set title of naviagation bar
        title = "Klachu - Klachu"
        //show messages table view
        showPreviousMessages()
    }
    
    //show previous messages from database
    func showPreviousMessages(){
        //enter messages firebase and order by date of sending
        db.collection("messages")
            .order(by: "date")
            .addSnapshotListener {
                (querySnapshot, error) in
                //set messages struct to emtpy
                self.message = []
                //print error if it occured
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
                                //show message if both of it's sender/reciver are current user and current sender
                                if((sender == Auth.auth().currentUser?.email && self.reciever! == rec) || (sender == self.reciever! && Auth.auth().currentUser?.email == rec)) {
                                    let newMessage = MessageData(senderEmail: sender, message: messageBody, reciever: rec)
                                    //add it to struct
                                    self.message.append(newMessage)
                                    DispatchQueue.main.async {
                                        //reload data
                                        self.messageView.reloadData()
                                        let indexPath1 = IndexPath(row: self.message.count - 1, section: 0)
                                        //scroll to newest message
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

//MARK: -UITableView methods
extension KlachuViewController: UITableViewDataSource{
    //return number of rows (users ammount)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    //setting cell informations
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //fill each cell with message structer's data
        let msg = message[indexPath.row]
        //Create custom cell(created in CustomisedCell.xib) constant
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! CustomisedCell
        //Set colors/bubble/text color and message according to which user is speaking
        if let rec = reciever{
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

