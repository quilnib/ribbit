//
//  EditFriendsTableViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/20/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class EditFriendsTableViewController: UITableViewController {
    
    var allUsers:[AnyObject] = []
    var currentUser:PFUser?
    var friends: [PFUser] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFUser.query()
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                //query did not error out
                self.allUsers += objects

                self.tableView.reloadData()
                
            } else {
                //there was an error, so present a message to the user
                let networkIssueController = UIAlertController(title: "Sorry!", message: "\(error.userInfo!)" , preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
            }
        }
        
        self.currentUser = PFUser.currentUser()

        
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.allUsers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        var user: PFUser = self.allUsers[indexPath.row] as PFUser
        cell.textLabel?.text = user.username
        
        if (isFriend(user)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)//remove the highlighting of a cell when it is selected
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        let user = self.allUsers[indexPath.row] as PFUser
        var friendsRelation: PFRelation = self.currentUser!.relationForKey("friendsRelation")!//create a relationship type

        
        if (isFriend(user)) {// if they are already a friend, then unfriend them
            //1.remove checkmark
            cell?.accessoryType = UITableViewCellAccessoryType.None

            //2.remove from array of friends
            if let index = find(self.friends, user) {
                self.friends.removeAtIndex(index)
            }
            
            //3.remove from backend
            friendsRelation.removeObject(user)
            
        } else {// if they are not already a friend, then add them as a friend
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.friends.append(user)
            friendsRelation.addObject(user)
        }
        
        self.currentUser?.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
            if (error == nil) {
                
            }else {
                println("\(error.userInfo!)")
            }
        })
        
    }
    
    
    // MARK: - Helper methods
    
    func isFriend(user: PFUser) -> Bool {
        var result = false
        
        for friend in self.friends {
            if (friend.objectId == user.objectId) {
                result = true
            }
        }
        
        return result
    }

    
}
