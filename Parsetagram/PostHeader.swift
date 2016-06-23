//
//  PostHeader.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/21/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import ParseUI

class PostHeader: UITableViewCell {

    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profilePic: PFImageView!
    
    var author: User? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.layer.cornerRadius = 13
        profilePic.layer.borderWidth = 1
        profilePic.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profilePic.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
