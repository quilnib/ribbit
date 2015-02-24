//
//  InboxViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/19/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit
import MediaPlayer

class InboxViewController: UITableViewController {
    
    var messages: [AnyObject] = []
    var selectedMessage: PFObject?
    var moviePlayer: MPMoviePlayerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        var testObject = PFObject(className: "TestObject") //test code for parse
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock(nil)
        
        self.moviePlayer = MPMoviePlayerController()
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            println("Current user: \(currentUser!.username)")
            

        } else {
            // Show the signup or login screen
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var query = PFQuery(className: "Messages")
        query.whereKey("recipientIds", equalTo: PFUser.currentUser().objectId)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {//something went wrong
                println("\(error.userInfo!)")
            } else { //successful query
                // we foiund messages
                self.messages = objects
                self.tableView.reloadData()
                println("Retreived \(self.messages.count) messages")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let message = self.messages[indexPath.row] as PFObject
        cell.textLabel?.text = (message.objectForKey("senderName") as String)
        
        var fileType = message.objectForKey("fileType") as String
        if (fileType == "image") {
            cell.imageView?.image = UIImage(named: "icon_image")
        } else {
            cell.imageView?.image = UIImage(named: "icon_video")
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedMessage = (self.messages[indexPath.row] as PFObject)
        var fileType = self.selectedMessage?.objectForKey("fileType") as String
        if (fileType == "image") {
            self.performSegueWithIdentifier("showImage", sender: self)
        } else {
            //file type is video
            let videoFile = self.selectedMessage?.objectForKey("file") as PFFile
            let fileUrl = NSURL(string: videoFile.url)
            self.moviePlayer?.contentURL = fileUrl
            self.moviePlayer?.prepareToPlay()
            self.moviePlayer!.requestThumbnailImagesAtTimes([0.0], timeOption: MPMovieTimeOption.NearestKeyFrame)
            
            //add it to the view controller so we can see it
            self.view.addSubview(self.moviePlayer!.view)
            self.moviePlayer!.setFullscreen(true, animated: true)
        }
        
        //delete the message
        var recipientIds: [String] = self.selectedMessage!.objectForKey("recipientIds") as [String]
        println("\(recipientIds)")
        
        if (recipientIds.count == 1) {
            //delete
            self.selectedMessage?.deleteInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in})
        } else {
            //remove current recipient from list
            if let index = find(recipientIds, PFUser.currentUser().objectId) {
                recipientIds.removeAtIndex(index)
                self.selectedMessage?.setObject(recipientIds, forKey: "recipientIds")
                self.selectedMessage?.saveInBackgroundWithBlock(nil)
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showLogin"{
            let bottomBar = segue.destinationViewController as LoginViewController
            bottomBar.hidesBottomBarWhenPushed = true
            bottomBar.navigationItem.hidesBackButton = true
        } else if (segue.identifier == "showImage") {
            let imageView = segue.destinationViewController as ImageViewController
            imageView.hidesBottomBarWhenPushed = true
            imageView.message = self.selectedMessage
            
        }
    }
    

    @IBAction func logOut(sender: AnyObject) {
        
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        
        self.performSegueWithIdentifier("showLogin", sender: self)
    }
}
