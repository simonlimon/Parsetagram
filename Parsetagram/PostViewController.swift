//
//  PostViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/21/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import LiquidLoader

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var postImageView: UIImageView!
    
    var loader: LiquidLoader?
    let loaderSize: CGFloat = 80
    @IBInspectable let loaderColor: UIColor = UIColor.darkGrayColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader = LiquidLoader(frame: CGRectMake(view.frame.midX - loaderSize/2, view.frame.midY - loaderSize/2, loaderSize, loaderSize), effect: .Circle(UIColor.darkGrayColor()))
        view.addSubview(loader!)
        loader!.hide()
        
        captionField.layer.cornerRadius = 5
        captionField.layer.borderColor = UIColor.lightGrayColor().CGColor
        captionField.layer.borderWidth = 1
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSelectImage(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onUpload(sender: AnyObject) {
        
        let post = Post(image: postImageView.image, withCaption: captionField.text)
        
        self.postImageView.alpha = 0.5
        loader!.show()
        post.upload() {(success: Bool, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Image uploaded successfully")
            }
            self.postImageView.image = nil
            self.captionField.text = ""
            self.postImageView.alpha = 1
            self.loader!.hide()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
