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
import ElasticTransition
import Hexacon

class OtherUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ElasticMenuTransitionDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicView: PFImageView!
    
    var user: User? = nil
    var userPosts: [Post] = []
    
    var contentLength:CGFloat = 280
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if (user == nil) {
            user = User(user: PFUser.currentUser()!)
        }
        
        let tm = self.transitioningDelegate as! ElasticTransition
        tm.transformType = ElasticTransitionBackgroundTransform.Rotate
        
        profilePicView.layer.cornerRadius = profilePicView.frame.width/2
        profilePicView.layer.borderWidth = 1
        profilePicView.layer.borderColor = UIColor.lightGrayColor().CGColor
        profilePicView.clipsToBounds = true
        
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    
}
