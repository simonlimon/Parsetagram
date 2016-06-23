//
//  Comment.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/22/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse

class Comment: NSObject {
    let text: String!
    let author: String!
    let postID: String!
    
    init(object: PFObject) {
        text = object["text"] as! String
        author = object["author"] as! String
        postID = object["postID"] as! String
    }
    
    init(text: String, author: String, postID: String) {
        self.text = text
        self.author = author
        self.postID = postID
    }
    
    func getPFObject() -> PFObject {
        let object = PFObject(className: "Comment")
        object["text"] = text
        object["author"] = author
        object["postID"] = postID
        return object
    }
}
