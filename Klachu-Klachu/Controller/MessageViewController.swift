//
//  MessageViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/14/21.
//

import UIKit
import Firebase

//Present possible messages reciever
class MessageViewController: UIViewController {
    
    //tableview with presented users
    @IBOutlet weak var tableView: UITableView!
    //Create firestore database object
    let db = Firestore.firestore()
    //empty users structure
    var users: [UsersData] = []
    var nickname: String?
    //var friends: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Setting both data source and table view delegates from table view class
        tableView.dataSource = self
        tableView.delegate = self
        //register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //hide back button and show navigation bar
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        //present users
        getUserNickname()
        friendsArray(){
            
        }
    }
    
    
    func getUserNickname(){
        let sender = Auth.auth().currentUser?.email
        self.db.collection("users").getDocuments { (querySnapshot, error) in
            if let err = error{
                print(err)
            }
            else{
                //take documents from querysnapshots
                if let docs = querySnapshot?.documents{
                    for doc in docs {
                        //take data from doc
                        let data = doc.data()
                        //check if there is email
                        if let email = data["email"] as? String, let nick = data["nickname"] as? String{
                            if email == sender{
                                self.nickname = nick
                                self.title = "Hi, \(nick)"
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func textButton(_ sender: UIButton) {
        //  let sender = Auth.auth().currentUser?.email
        //Create the alert controller..
        let alert = UIAlertController(title: "Text a friend", message: "Enter valid nickname", preferredStyle: .alert)
        
        //Add the text field.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Find", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if let unwrapped = textField.text, let nick = self.nickname{
                guard !unwrapped.isEmpty else { return }
                guard self.nickname != unwrapped
                else{
                    let alert = UIAlertController(title: "You cannot text yourself!", message: "Maybe find some friends?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.db.collection("users")
                    .document(unwrapped).getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.db.collection("friends").document(nick).updateData(["friendsList": FieldValue.arrayUnion([unwrapped])])
                            self.db.collection("friends").document(unwrapped).updateData(["friendsList": FieldValue.arrayUnion([nick])])
                        }
                        else{
                            let alert = UIAlertController(title: "There is no such user!", message: "Are you sure you wrote it down correctly?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
            }
        }))
        //Present the alert.
        self.present(alert, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    //Log out button pressed event
    @IBAction func logOutPressed(_ sender: UIButton) {
        //declare firebase authentication
        let firebaseAuth = Auth.auth()
        do{
            //signout
            try firebaseAuth.signOut()
            //hide navigation bar
            self.navigationController?.isNavigationBarHidden = true
            //pop previous view
            let controllers = self.navigationController?.viewControllers
            for vc in controllers! {
                if vc is FirstViewController {
                    _ = self.navigationController?.popToViewController(vc as! FirstViewController, animated: true)
                }
            }
            //catch exception of signing out
        } catch let signOutError as NSError{
            let alert = UIAlertController(title: "Log out error!", message: signOutError as? String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func friendsArray(completion: ()->Void){
        let sender = Auth.auth().currentUser?.email
        db.collection("friends")
            .addSnapshotListener { (querySnapshot, error) in
                if let err = error{
                    print(err)
                }
                else{
                    //take documents from querysnapshots
                    if let docs = querySnapshot?.documents{
                        for doc in docs {
                            //take data from doc
                            let data = doc.data()
                            //check if there is email
                            if let list = data["friendsList"] as? [String], let user = data["user"] as? String{
                                if sender == user{
                                    self.presentUsers(list)
                                }
                                
                            }
                        }
                    }
                }
                
            }
        completion()
    }
    
    //Present users in a table view
    func presentUsers(_ list: [String]){
        //take sender's email from firebase
        let sender = Auth.auth().currentUser?.email
        //enter users collection
        print(":)")
        print(list)
        self.users = []
        db.collection("users")
            .getDocuments() { (querySnapshot, error) in
                if let err = error{
                    print(err)
                }
                else{
                    self.users = []
                    //take documents from querysnapshots
                    if let docs = querySnapshot?.documents{
                        for doc in docs {
                            //take data from doc
                            let data = doc.data()
                            //check if there is email
                            if let email = data["email"] as? String, let nick = data["nickname"] as? String, let img = data["image"] as? Int{
                                //if email is not related to sender's email show users
                                if email != sender && (list.contains(nick)){
                                    let newUser = UsersData(email: email, nickname: nick, imageNumber: img)
                                    self.users.append(newUser)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        let indexPath1 = IndexPath(row: self.users.count - 1, section: 0)
                                        self.tableView.scrollToRow(at: indexPath1, at: .top, animated: false)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
    }
    //Prepare for segue method override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? KlachuViewController, let selectedUser = sender as? String {
            vc.reciever = selectedUser
        }
    }
    
}

//MARK: -UITableView methods
extension MessageViewController: UITableViewDataSource, UITableViewDelegate{
    //return number of rows (users ammount)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    //setting cell informations
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let usr = users[indexPath.row]
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = usr.nickname
        var image: UIImage
        //switch image according to user's choice
        switch usr.imageNumber {
        case 1:
            image = #imageLiteral(resourceName: "img_avatar")
        case 2:
            image = #imageLiteral(resourceName: "avatar6")
        case 3:
            image = #imageLiteral(resourceName: "avatar2")
        case 4:
            image = #imageLiteral(resourceName: "avatar5")
        case 5:
            image = #imageLiteral(resourceName: "img_avatar2")
        default:
            image = UIImage(systemName: "person.fill")!
        }
        
        cell.imageView?.makeRounded()
        cell.imageView?.image = image
        
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:15,height:20))
        label.text = "＞"
        label.textColor = UIColor(red:0/255, green:122/255, blue:255/255, alpha: 1)
        cell.accessoryView = label
        return cell
    }
    //method that triggers whenever user press on the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row].email
        performSegue(withIdentifier: "messageSegue", sender: selectedUser)
    }
}


extension UIImageView {
    
    func makeRounded() {
        
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
