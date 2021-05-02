//
//  CustomisedCell.swift
//  Klachu-Klachu
//
//  Created by Dawid Jóźwiak on 5/2/21.
//

import UIKit

class CustomisedCell: UITableViewCell {

    @IBOutlet weak var messageCell: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var bubble: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageCell.layer.cornerRadius = messageCell.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
