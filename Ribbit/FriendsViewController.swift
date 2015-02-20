//
//  FriendsViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/20/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class FriendsViewController: UITableViewController {

    var friendsRelation: PFRelation?
    var friends: [PFUser] = []//I think this should actually be a list of PFUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsRelation = (PFUser.currentUser().objectForKey("friendsRelation") as PFRelation)
        
        if let relation = self.friendsRelation {//wrap in an if-let so we don't get optional-creep
            var query = relation.query()
            query.orderByAscending("username")
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
                if (error != nil) {
                    //failed
                    println("\(error.userInfo!)")
                    
                } else {
                    //succeeded
                    self.friends += objects as [PFUser]
                    self.tableView.reloadData()
                    
                    println("FriendsViewController is calling ViewDidLoad and the friends list has \(self.friends.count) entries")
                }
            })
        }
        
        
        
        
//        self.friendsRelation!.query().findObjectsInBackgroundWithBlock {// this is how parse.com does it
//            (objects: [AnyObject]!, error: NSError!) -> Void in
//            if error != nil {
//                // There was an error
//            } else {
//                // objects has all the Posts the current user liked.
//            }
//        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // #warning Potentially incomplete method implementation.
        //call some code to reload the list of friends
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showEditFriends") {
            let editFriendsScreen = segue.destinationViewController as EditFriendsTableViewController
            
            editFriendsScreen.friends += self.friends
            
        }
    }

   

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell


        let user = self.friends[indexPath.row] as PFUser
        cell.textLabel?.text = user.username
        
        return cell
    }
    
}
