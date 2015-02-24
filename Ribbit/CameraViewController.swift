//
//  CameraViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/20/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class CameraViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var presentCamera = true
    var imagePicker: UIImagePickerController?
    var image: UIImage?
    var videoFilePath: String = ""
    var friendsRelation: PFRelation?
    var friends: [PFUser] = []
    var recipients: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendsRelation = (PFUser.currentUser().objectForKey("friendsRelation") as PFRelation) // get our friends list
        self.imagePicker = UIImagePickerController() //set up the camera
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
//                self.imagePicker!.delegate = self
//                self.imagePicker!.allowsEditing = false
//                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
//                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
//                } else {
//                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//                }
//                self.imagePicker!.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(self.imagePicker!.sourceType)!
        
        if let relation = self.friendsRelation {//wrap in an if-let so we don't get optional-creep
            var query = relation.query()
            query.orderByAscending("username")
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
                if (error != nil) {
                    //failed
                    println("\(error.userInfo!)")
                    
                } else {
                    //succeeded
                    self.friends = objects as [PFUser]
                    self.tableView.reloadData()
                }
            })
        }
        
        //potentially wrap the camera view creation in an if (self.image == nil && self.videoFilePath == "")
        if let camera = imagePicker { //doing it this way handles the optional better
            camera.delegate = self
            camera.allowsEditing = false
            camera.videoMaximumDuration = 10
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                camera.sourceType = UIImagePickerControllerSourceType.Camera
            } else {
                camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            camera.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(camera.sourceType)!
        }
        
        if (self.presentCamera) {
            self.presentViewController(self.imagePicker!, animated: false, completion: nil)// present the camera
        } else {
            
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        self.presentCamera = true //once the view has loaded make sure the next time it is opened we see the camera view
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let user = self.friends[indexPath.row] as PFUser
        cell.textLabel?.text = user.username
        
        if let index = find(self.recipients, user.objectId) {// if the user exists within the list then their cell should have a checkmark when it is recycled
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else { //otherwise it should not have a checkmark
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let user = self.friends[indexPath.row]
        
        if (cell?.accessoryType == UITableViewCellAccessoryType.None) {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.recipients.append(user.objectId)
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            if let index = find(self.recipients, user.objectId) {
                self.recipients.removeAtIndex(index)
            }
        }
        
        
    }
    
    
    //MARK: - Image Picker Controller Delegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
        
        self.tabBarController?.selectedIndex = 0
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var mediaType: String = info[UIImagePickerControllerMediaType] as String
        
        if (mediaType == kUTTypeImage) {
            //a photo was taken or selected
            self.image = (info[UIImagePickerControllerOriginalImage] as UIImage)
            if (self.imagePicker?.sourceType == UIImagePickerControllerSourceType.Camera) {
                //save the image
                UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
            }
        } else {
            //a video was taken or selected
            self.videoFilePath = info[UIImagePickerControllerMediaURL]!.path as String!!
            if (self.imagePicker?.sourceType == UIImagePickerControllerSourceType.Camera) {
                //save the video
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil)
                }
            }
        }
        self.presentCamera = false //make sure the camera view does not pop up as soon as it is dismissed
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: - IBActions
    
    @IBAction func cancel(sender: AnyObject) {
        self.reset()
        self.tabBarController?.selectedIndex = 0 //send the user back to the inbox
    }
    
    @IBAction func send(sender: AnyObject) {
        if (self.image == nil && videoFilePath == "") {
            let networkIssueController = UIAlertController(title: "Try again!", message: "Please capture or select a photo or video to share!" , preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                self.presentViewController(self.imagePicker!, animated: false, completion: nil)
            })
            networkIssueController.addAction(okButton)
            self.presentCamera = true
            self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
            //self.presentViewController(self.imagePicker!, animated: false, completion: nil)
        } else {
            self.uploadMessage()
            self.tabBarController?.selectedIndex = 0
        }
        
    }
    
    
    //MARK: - Helper methods
    
    func uploadMessage() {
        
        var fileData: NSData?
        var fileName = ""
        var fileType = ""
        
        //check if image or video
        if (self.image != nil)
        {   //if image, shrink it
            var newImage = self.resizeImage(self.image!, toWidth: 320.0, andHeight: 480.0)
            fileData = UIImagePNGRepresentation(newImage)
            fileName = "image.png"
            fileType = "image"
        } else {
            fileData = (NSData.dataWithContentsOfMappedFile(self.videoFilePath) as NSData)
            fileName = "video.mov"
            fileType = "video"
        }
         //upload the file itself
        let file = PFFile(name: fileName, data: fileData)
        file.saveInBackgroundWithBlock { (succeeded:Bool, error: NSError!) -> Void in
            if (error != nil) {//something went wrong
                let networkIssueController = UIAlertController(title: "An error occured!", message: "Please try sending your message again." , preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it

            } else {//upload succeeded
                var message = PFObject(className: "Messages")
                message["file"] = file
                message["fileType"] = fileType
                message["recipientIds"] = self.recipients
                message["senderId"] = PFUser.currentUser().objectId
                message["senderName"] = PFUser.currentUser().username
                 //upload the message details
                message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if (error != nil) {
                        let networkIssueController = UIAlertController(title: "An error occured!", message: "Please try sending your message again." , preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        networkIssueController.addAction(okButton)
                        
                        self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
                    } else {//everything was successful
                        self.reset()
                    }
                })
            }
        }
        
        
       
       
        
    }
    
    func reset() {
        self.presentCamera = true
        self.image = nil
        self.videoFilePath = ""
        self.recipients.removeAll()
    }
    
    func resizeImage(image: UIImage, toWidth width: CGFloat, andHeight height: CGFloat) -> UIImage {
        var newSize = CGSizeMake(width, height)
        var newRectangle = CGRectMake(0, 0, width, height)
        UIGraphicsBeginImageContext(newSize)//begin the context
        image.drawInRect(newRectangle)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()//end the context
        
        return resizedImage
    }

}
