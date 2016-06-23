//
//  User.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/22/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse

class User: NSObject {
    
    let user: PFUser!
    var profilePic: UIImage? = nil
    var profilePicFile: PFFile? = nil
    
//    let bio: String? = nil
    
    var username: String? {
        get {
            return user.username
        }
    }
    
    init (user: PFUser) {
        self.user = user
        
        super.init()
        
        if let pictureFile = user["profilePic"] as! PFFile? {
            profilePicFile = pictureFile
            pictureFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
                if (error == nil) {
                    self.profilePic = UIImage(data:imageData!)
                } else {
                    self.profilePic = nil
                    print("Error creating image")
                }
            }
        } else {
            print ("no image")
        }
    }
    
    func updateProfilePic (picture: UIImage?) {
        profilePic = picture
        if let profilePic = Post.getPFFileFromImage(profilePic) {
            user["profilePic"] = profilePic
            profilePicFile = profilePic
        } else {
            print("invalid")
        }
        user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Profile picture updated succesfully")
            }
        })
    }
    
    func fetchUserPosts (completion: PFQueryArrayResultBlock?) -> Void {
        // construct PFQuery
        let query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: user!)
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock(completion)
    }

    
}
