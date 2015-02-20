//
//  CameraViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/20/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class CameraViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController?
    var image: UIImage?
    var videoFilePath: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imagePicker = UIImagePickerController()
        //        self.imagePicker!.delegate = self
        //        self.imagePicker!.allowsEditing = false
        //        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
        //            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
        //        } else {
        //            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //        }
        //        self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
        //        self.imagePicker!.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(self.imagePicker!.sourceType)!
        
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
        
        
        self.presentViewController(self.imagePicker!, animated: false, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
        self.dismissViewControllerAnimated(true, completion: nil)

    }

}
