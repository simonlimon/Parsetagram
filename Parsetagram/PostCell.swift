//
//  PostCell.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/20/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionView: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    var post: Post? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoView.layer.cornerRadius = 7
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onLike(sender: AnyObject) {
        post!.increaseLikeCount()
        likesLabel.text = String(Int(likesLabel.text!)! + 1)
    }
}
