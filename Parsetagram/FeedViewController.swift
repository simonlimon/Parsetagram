//
//  FeedViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/20/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ElasticTransition

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts: [Post] = []
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var skip = 0
    
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    let rgr = UIScreenEdgePanGestureRecognizer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        
        lgr.addTarget(self, action: #selector(FeedViewController.handlePan(_:)))
        rgr.addTarget(self, action: #selector(FeedViewController.handleRightPan(_:)))
        lgr.edges = .Left
        rgr.edges = .Right
        view.addGestureRecognizer(lgr)
        view.addGestureRecognizer(rgr)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = UIColor(red:43/255, green:158/255, blue:179/255, alpha:1.0)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
//        loadingMoreView!.backgroundColor = UIColor(red:0.35, green:0.80, blue:0.56, alpha:1.0)
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        fetchPosts(false)
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController?.navigationBar.barTintColor = UIColor(red:0.35, green:0.80, blue:0.56, alpha:1.0)
//        tabBarController!.tabBar.barTintColor = UIColor(red:0.35, green:0.80, blue:0.56, alpha:1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPosts(append: Bool) -> Void {
        // construct PFQuery
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 5

        if !append {
            self.posts = []
            skip = 0
        } else {
            skip += 5
            query.skip = skip
        }
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                
                for object in objects {
                    self.posts.append(Post(object: object){ (progress: Int32) in
                        if (progress == 100) {
                            self.tableView.reloadData()
                        }
                        
                    })
                }
                
                self.isMoreDataLoading = false
                self.refreshControl.endRefreshing()
                self.loadingMoreView!.stopAnimating()
                self.tableView.reloadData()
            } else {
                print("Error fetching posts")
            }
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchPosts(false)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    internal func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostHeader
        header.authorLabel.text = posts[section].author.username
        header.dateLabel.text = posts[section].dateCreated.description
        header.author = posts[section].author
        
        if let profilePic = posts[section].author.profilePic {
            header.profilePic.image = profilePic
        } else {
            header.profilePic.file = posts[section].author.profilePicFile
            header.profilePic.loadInBackground()
        }
        
        return header
    }

    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        cell.postImageView.image = posts[indexPath.section].media
        cell.captionView.text = posts[indexPath.section].caption
        cell.captionView.textColor = UIColor.whiteColor()
        cell.captionView.textAlignment = .Center
        cell.likesLabel.text = String(posts[indexPath.section].likesCount!)
        cell.post = posts[indexPath.section]
        return cell
    }
    
    internal func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
        
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                isMoreDataLoading = true
                
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                fetchPosts(true)
            }
        }
    }
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Left
            transition.startInteractiveTransition(self, segueIdentifier: "userSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    func handleRightPan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Right
            transition.startInteractiveTransition(self, segueIdentifier: "postSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    @IBAction func onImageTap(sender: AnyObject) {
        transition.edge = .Bottom
        transition.startingPoint = sender.center
        performSegueWithIdentifier("detailsSegue", sender: sender)
    }
    
    @IBAction func onUserTap(sender: AnyObject) {
        transition.edge = .Right
        transition.startingPoint = sender.center
        performSegueWithIdentifier("otherUserSegue", sender: sender)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destinationViewController
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .Custom
        
        if let button = sender as? UIButton {
            print(button.restorationIdentifier!)

            if (button.restorationIdentifier! == "userButton") {
                if let userView = segue.destinationViewController as? OtherUserViewController {
                    let postHeader = button.superview?.superview as! PostHeader
                    userView.user = postHeader.author
                }
            } else if (button.restorationIdentifier! == "detailsButton") {
                if let detailsView = segue.destinationViewController as? DetailsViewController {
                    let postCell = button.superview?.superview as! PostCell
                    detailsView.post = postCell.post
                }
            } 
        }
    }
    

}
