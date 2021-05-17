//
//  MessageViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/14/21.
//

import UIKit
import Firebase

class MessageViewController: UIViewController {

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "messageSegue", sender: self)
        
        // Do any additional setup after loading the view.
    }

}

extension MessageViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
