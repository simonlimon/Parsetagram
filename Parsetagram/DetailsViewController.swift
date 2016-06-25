//
//  DetailsViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/21/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import ElasticTransition

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ElasticMenuTransitionDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentField: UITextView!
    
    var post: Post? = nil
    
    var contentLength:CGFloat = 300
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
//    var dismissByForegroundDrag = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commentField.layer.cornerRadius = 5
        commentField.layer.borderColor = UIColor.lightGrayColor().CGColor
        commentField.layer.borderWidth = 1
        
        let tm = self.transitioningDelegate as! ElasticTransition
        tm.transformType = ElasticTransitionBackgroundTransform.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        captionLabel.text = post?.caption!
        tableView.reloadData()
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        
        let comment = NSAttributedString(string:post!.comments![indexPath.row].text)

        var username = post!.comments![indexPath.row].author!
        username += ": "
        let attr = [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)]
        let author = NSMutableAttributedString(string: username, attributes: attr)
        author.appendAttributedString(comment)
        
        cell.commentLabel.attributedText = author
        
        return cell
    }
    
    @IBAction func onComment(sender: AnyObject) {
        if let comment = commentField.text {
            if comment != "" {
                post?.addComment(comment)
            }
        }
        tableView.reloadData()
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
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
    

}
