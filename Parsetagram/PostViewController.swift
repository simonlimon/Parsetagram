//
//  PostViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/21/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import LiquidLoader
import ElasticTransition

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takeLabel: UILabel!
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    let lgr = UIScreenEdgePanGestureRecognizer()
    let rgr = UIScreenEdgePanGestureRecognizer()
    var transition = ElasticTransition()

    var loader: LiquidLoader?
    let loaderSize: CGFloat = 80
    @IBInspectable let loaderColor: UIColor = UIColor.darkGrayColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        loader = LiquidLoader(frame: CGRectMake(postImageView.frame.midX - loaderSize/2, postImageView.frame.midY - loaderSize/2, loaderSize, loaderSize), effect: .Circle(UIColor.darkGrayColor()))
        view.addSubview(loader!)
        loader!.hide()
        
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        
        lgr.addTarget(self, action: #selector(PostViewController.handlePan(_:)))
        rgr.addTarget(self, action: #selector(PostViewController.handleRightPan(_:)))
        lgr.edges = .Left
        rgr.edges = .Right
        view.addGestureRecognizer(lgr)
        view.addGestureRecognizer(rgr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTakePicture(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onSelectImage(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onUpload(sender: AnyObject) {
        
        if let image = postImageView.image {
            let post = Post(image: image, withCaption: captionField.text)
            
            self.postImageView.alpha = 0.5
            loader!.show()
            selectLabel.hidden = true
            takeLabel.hidden = true
            post.upload() {(success: Bool, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Image uploaded successfully")
                }
                self.postImageView.image = nil
                self.captionField.text = ""
                self.postImageView.alpha = 1
                self.selectLabel.hidden = false
                self.takeLabel.hidden = false
                self.loader!.hide()
            }
        } else {
            let alertController = UIAlertController(title: "An image is required", message: nil, preferredStyle: .Alert)
            
            // create an OK action
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            
            presentViewController(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
        }
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        postImageView.image = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Left
            transition.startInteractiveTransition(self, segueIdentifier: "feedSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    func handleRightPan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Right
            transition.startInteractiveTransition(self, segueIdentifier: "userSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destinationViewController
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .Custom
    }
 

}
