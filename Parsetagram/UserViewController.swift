//
//  UserViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/21/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicView: PFImageView!
    
    var user: User? = nil
    var userPosts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if (user == nil) {
            user = User(user: PFUser.currentUser()!)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        fetchPosts()
        
        usernameLabel.text = user?.username
        profilePicView.file = user?.profilePicFile
        profilePicView.loadInBackground()
    }
    
    func fetchPosts() {
        user!.fetchUserPosts() { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.userPosts = []
                for object in objects {
                    self.userPosts.append(Post(object: object){ (progress: Int32) in
                        if (progress == 100) {
                            self.collectionView.reloadData()
                        }
                        })
                }
                self.collectionView.reloadData()
            } else {
                print("Error fetching posts")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserPostCell", forIndexPath: indexPath) as! UserPostCell
        
        cell.postImageView.image = userPosts[indexPath.row].media
        
        return cell
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User logged out succesfully")
                self.performSegueWithIdentifier("logoutSegue", sender: nil)
            }
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        user?.updateProfilePic(editedImage)
        profilePicView.image = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func onChangeProfilePic(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
