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
                            if let email = data["email"] as? String{
                                //if email is not related to sender's email show users
                                if email != sender{
                                    let newUser = UsersData(email: email)
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
        cell.textLabel?.text = usr.email
        return cell
    }
    //method that triggers whenever user press on the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row].email
        performSegue(withIdentifier: "messageSegue", sender: selectedUser)
        
    }
}
