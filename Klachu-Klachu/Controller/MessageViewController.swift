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
        presentUsers()
        
    }
        
    @IBAction func textButton(_ sender: UIButton) {
        //Create the alert controller..
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)

        //Add the text field.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
        }))

        //Present the alert.
        self.present(alert, animated: true, completion: nil)
        
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
    
    //Present users in a table view
    func presentUsers(){
        //take sender's email from firebase
        let sender = Auth.auth().currentUser?.email
        //enter users collection
        db.collection("users")
            .addSnapshotListener {
                (querySnapshot, error) in
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
                            if let email = data["email"] as? String, let nick = data["nickname"] as? String, let img = data["image"] as? Int{
                                //if email is not related to sender's email show users
                                if email != sender{
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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
        cell.detailTextLabel?.text = ">"
        cell.imageView?.image = image
        return cell
    }
    //method that triggers whenever user press on the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row].email
        performSegue(withIdentifier: "messageSegue", sender: selectedUser)
    }
}
