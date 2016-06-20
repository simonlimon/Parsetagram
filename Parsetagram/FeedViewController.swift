//
//  FeedViewController.swift
//  Parsetagram
//
//  Created by Simon Posada Fishman on 6/20/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User logged out succesfully")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
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
