//
//  FirstViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/1/21.
//

import UIKit

class FirstViewController: UIViewController {

    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 245, height: 106))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        label.frame.origin = CGPoint(x: 85, y: 377)
        label.textAlignment = .center
        
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 25)
        label.text = "Klachu - Klachu"
        self.view.addSubview(label)
        
    }

}
