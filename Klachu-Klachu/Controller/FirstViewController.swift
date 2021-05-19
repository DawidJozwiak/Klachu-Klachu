//
//  FirstViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/1/21.
//

import UIKit

class FirstViewController: UIViewController {

    //Create label with applications name
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 245, height: 106))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        //center label in the middle
        label.frame.origin = CGPoint(x: 85, y: 377)
        label.textAlignment = .center
        //set label font and text
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 25)
        label.text = "Klachu - Klachu"
        //add label to view
        self.view.addSubview(label)
        
        //after 1 second present tutorial to user
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute:{
            self.performSegue(withIdentifier: "tutorialSegue", sender: self)
        })
    }

    //set navigation bar to hidden whenever view is about to appear on the screen again
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
