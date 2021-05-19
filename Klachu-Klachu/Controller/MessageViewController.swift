//
//  MessageViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/14/21.
//

import UIKit
import Firebase

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    
    var users: [UsersData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        presentUsers()
        // performSegue(withIdentifier: "messageSegue", sender: self)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func logOutPressed(_ sender: UIButton) {
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
    
    
    func presentUsers(){
        let sender = Auth.auth().currentUser?.email
        db.collection("users")
            .addSnapshotListener {
                (querySnapshot, error) in
                if let err = error{
                    let alert = UIAlertController(title: "There is some problem!", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    if let docs = querySnapshot?.documents{
                        for doc in docs {
                            let data = doc.data()
                            if let email = data["email"] as? String{
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? KlachuViewController, let selectedUser = sender as? String {
            vc.reciever = selectedUser
        }
    }
    
}
extension MessageViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let usr = users[indexPath.row]
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = usr.email
        return cell
    }
    //method that triggers when user press on the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row].email
        performSegue(withIdentifier: "messageSegue", sender: selectedUser)
        
    }
}
