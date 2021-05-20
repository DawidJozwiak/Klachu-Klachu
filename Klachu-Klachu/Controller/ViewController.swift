//
//  ViewController.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 4/15/21.
//

import UIKit

class ViewController: UIViewController {

    //Create label with applications name
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 245, height: 106))
    
    //set image to Klachu
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 350))
        imageView.image = UIImage(named: "Klachu")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show nagiation bar
        self.navigationController?.isNavigationBarHidden = true
        //set background color to teal
        view.backgroundColor = UIColor(red: 0.4, green: 0.7215, blue: 1, alpha: 1)
        view.addSubview(imageView)
        
        //center label
        label.frame.origin = CGPoint(x: 85, y: 377)
        label.textAlignment = .center
        //set label font and text
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 25)
        label.text = ""
        
        self.view.addSubview(label)
        let title = "Klachu - Klachu"
        var interval = 0.0
        //add letters in the center as animation
        for letter in title{
            Timer.scheduledTimer(withTimeInterval: 0.2 * interval, repeats: false) { (timer) in
                self.label.text?.append(letter)
            }
            interval += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3.5, execute:{
           self.performSegue(withIdentifier: "first", sender: self)
            
        })
        
    }
    //adding layout subview with image in center
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.contentMode = .scaleAspectFit
        imageView.center = view.center
        //creating delay before animation
    }

}

