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
    @IBOutlet weak var blockButton: UIBarButtonItem!
    @IBOutlet weak var blockedButton: UIButton!
    
    //alert variable set to animate "please wait"
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    //Reciever email delegate taken from previous viewcontroller
    var reciever: String?
    //Boolean variable to check if user is blocked
    var isBlocked: Bool = false
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
    
    
    @IBAction func blockUser(_ senderr: UIButton) {
        if let rec = reciever, let sender = Auth.auth().currentUser?.email{
            if isBlocked{
                db.collection("blocked").getDocuments{ (querySnapshot, error) in
                    if let err = error{
                        let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else{
                        if let docs = querySnapshot?.documents{
                            for doc in docs {
                                let data = doc.data()
                                if let whoBlocked = data["sender"] as? String, let whoIsBlocked = data["reciever"] as? String{
                                    if(whoBlocked == sender && whoIsBlocked == rec){
                                        print("Uhm2")
                                        doc.reference.delete()
                                    }
                                }
                            }
                            self.blockedButton.setTitle("Block", for: .normal)
                            self.isBlocked = false
                        }
                    }
                }
            }
            else{
                self.db.collection("blocked").addDocument(data: ["sender" : sender, "reciever" : rec]){ (error) in
                    if let err = error{
                        let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "User has been blocked", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        senderr.setTitle("Unblock", for: .normal)
                        self.isBlocked = true
                    }
                }
            }
        }
    }
    
    func loading(){
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        self.alert.view.addSubview(loadingIndicator)
        self.present(self.alert, animated: true, completion: nil)
    }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfBlockedByReciever()
        checkIfBlockedBySender()
        showPreviousMessages(){}
    }
    
    func checkIfBlockedByReciever(){
        if let rec = reciever, let sender = Auth.auth().currentUser?.email{
            db.collection("blocked").getDocuments { (querySnapshot, error) in
                if let err = error{
                    let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else{
                    //Contains objects and is able to access documents
                    if let docs = querySnapshot?.documents{
                        for doc in docs {
                            let data = doc.data()
                            if let whoBlocked = data["sender"] as? String, let whoIsBlocked = data["reciever"] as? String{
                                if(whoBlocked == rec && whoIsBlocked == sender){
                                    let alert = UIAlertController(title: "User has blocked you!", message: "You have been blocked by this user and cannot text him!", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  _ in
                                        _ = self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func checkIfBlockedBySender(){
        if let rec = reciever, let sender = Auth.auth().currentUser?.email{
            db.collection("blocked").getDocuments { (querySnapshot, error) in
                if let err = error{
                    let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else{
                    //Contains objects and is able to access documents
                    if let docs = querySnapshot?.documents{
                        for doc in docs {
                            let data = doc.data()
                            if let whoBlocked = data["sender"] as? String, let whoIsBlocked = data["reciever"] as? String{
                                if(whoBlocked == sender && whoIsBlocked == rec){
                                    self.blockedButton.setTitle("Unblock", for: .normal)
                                    self.isBlocked = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //show previous messages from database
    func showPreviousMessages(completion: () -> Void){
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
        completion()
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
            //Set colors/bubble/text color and message according to which user is speaking
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

