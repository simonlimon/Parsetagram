//
//  Post.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/20/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse

class Post: NSObject {
    
    private(set) var media: UIImage!
    let author: PFUser!
    let caption: String!
    var likesCount: Int!
    var commentsCount: Int!
    
    
    init(image: UIImage?, withCaption caption: String?) {
        media = image
        author = PFUser.currentUser()
        self.caption = caption
        likesCount = 0
        commentsCount = 0
    }
    
    init(object: PFObject, with progressBlock: PFProgressBlock?) {
        author =  object["author"] as! PFUser
        caption =  object["caption"] as! String
        likesCount =  object["likesCount"] as! Int
        commentsCount = object["commentsCount"] as! Int
        
        super.init()
        
        let mediaFile = object["media"] as! PFFile
        
        mediaFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
            if (error == nil) {
                self.media = UIImage(data:imageData!)
            } else {
                self.media = nil
                print("Error creating image")
            }
        }, progressBlock: progressBlock)
    }
    
    /**
     Method to add a user post to Parse (uploading image file)
     */
    func upload(completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let post = PFObject(className: "Post")
        
        // Add relevant fields to the object
        post["media"] = getPFFileFromImage(media) // PFFile column type
        post["author"] = author // Pointer column type that points to PFUser
        post["caption"] = caption
        post["likesCount"] = likesCount
        post["commentsCount"] = commentsCount
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackgroundWithBlock(completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
}

