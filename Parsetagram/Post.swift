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
    private var object: PFObject?
    let author: User!
    let caption: String!
    let dateCreated: NSDate!
    var comments: [Comment]!
    
    private(set) var likesCount: Int!
    
    var commentsCount: Int!
    
    init(image: UIImage, withCaption caption: String?) {
        media = image
        author = User(user: PFUser.currentUser()!)
        dateCreated = NSDate()
        self.caption = caption
        likesCount = 0
        commentsCount = 0
        comments = []
    }
    
    init(object: PFObject, with progressBlock: PFProgressBlock?) {
        self.object = object
        author =  User(user: object["author"] as! PFUser)
        caption =  object["caption"] as! String
        likesCount =  object["likesCount"] as! Int
        commentsCount = object["commentsCount"] as! Int
        dateCreated = object.createdAt
        comments = []
        
        super.init()
        fetchComments()
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
    
    func fetchComments() -> Void {
        // construct PFQuery
        let query = PFQuery(className: "Comment")
        query.whereKey("postID", equalTo: object!.objectId!)
        query.orderByAscending("createdAt")
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    self.comments.append(Comment(object: object))
                }
            } else {
                print("Error fetching comments")
            }
        }
    }
    
    
    func increaseLikeCount() {
        likesCount! += 1
        object!["likesCount"] = likesCount
        object!.saveEventually()
    }
    
    func addComment(comment: String) {
        commentsCount! += 1
        object!.saveEventually()
        comments.append(Comment(text: comment, author: author.username!, postID: object!.objectId!))
        comments.last!.getPFObject().saveInBackground()
    }
    
    /**
     Method to add a user post to Parse (uploading image file)
     */
    func upload(completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        object = PFObject(className: "Post")
        
        // Add relevant fields to the object
        object!["media"] = Post.getPFFileFromImage(media)
        object!["author"] = author.user // Pointer column type that points to PFUser
        object!["caption"] = caption
        object!["likesCount"] = likesCount
        object!["commentsCount"] = commentsCount
        // Save object (following function will save the object in Parse asynchronously)
        object!.saveInBackgroundWithBlock(completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
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

