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

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HexagonalViewDataSource {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicView: PFImageView!
    
    var user: User? = nil
    var userPosts: [Post] = []
    
    private lazy var hexagonalView: HexagonalView = { [unowned self] in
        var frame = self.view.frame.insetBy(dx: 20, dy: 40)
        frame.offsetInPlace(dx: 0, dy: 60)
        let view = HexagonalView(frame: frame)
        view.hexagonalDataSource = self
//        view.hexagonalDelegate = self
        
        view.itemAppearance = HexagonalItemViewAppearance(needToConfigureItem: true,
                                                          itemSize: 80,
                                                          itemSpacing: 10,
                                                          itemBorderWidth: 0,
                                                          itemBorderColor: UIColor.grayColor(),
                                                          animationType: .Circle,
                                                          animationDuration: 0.05)
        return view
    }()
    
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    let rgr = UIScreenEdgePanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        
        profilePicView.layer.cornerRadius = 50
        profilePicView.layer.borderWidth = 1
        profilePicView.layer.borderColor = UIColor.lightGrayColor().CGColor
        profilePicView.clipsToBounds = true
        
        lgr.addTarget(self, action: #selector(UserViewController.handlePan(_:)))
        rgr.addTarget(self, action: #selector(UserViewController.handleRightPan(_:)))
        lgr.edges = .Left
        rgr.edges = .Right
        view.addGestureRecognizer(lgr)
        view.addGestureRecognizer(rgr)
        
        user = User(user: PFUser.currentUser()!)
        fetchPosts()

        hexagonalView.hexagonalDataSource = self
        
        view.addSubview(hexagonalView)

        view.sendSubviewToBack(hexagonalView)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        usernameLabel.text = user?.username
        profilePicView.file = user?.profilePicFile
        profilePicView.loadInBackground()
//        fetchPosts()

    }
    
    func fetchPosts() {
        user!.fetchUserPosts() { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.userPosts = []
                for object in objects {
                    self.userPosts.append(Post(object: object){ (progress: Int32) in
                        if (progress == 100) {
                            self.hexagonalView.reloadData()
                            self.hexagonalView.reloadInputViews()
                        }
                        })
                }
                self.hexagonalView.reloadData()

            } else {
                print("Error fetching posts")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfItemInHexagonalView(hexagonalView: HexagonalView) -> Int {
        return userPosts.count - 1
    }
    
    func hexagonalView(hexagonalView: HexagonalView, imageForIndex index: Int) -> UIImage? {
        return userPosts[index].media ?? UIImage.init()
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User logged out succesfully")
                self.transition.edge = .Top
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
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Left
            transition.startInteractiveTransition(self, segueIdentifier: "postSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    func handleRightPan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Right
            transition.startInteractiveTransition(self, segueIdentifier: "feedSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .Custom
    }
    

}
