//
//  ImageViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/23/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var message: PFObject?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var imageFile: PFFile = self.message!.objectForKey("file") as PFFile
        var imageFileURL = NSURL(string: imageFile.url)
        var imageData = NSData(contentsOfURL: imageFileURL!)
        self.imageView.image = UIImage(data: imageData!)
        
        let senderName = self.message?.objectForKey("senderName") as String
        self.navigationItem.title = "Sent From \(senderName)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timeout"), userInfo: nil, repeats: false)
        
    }

    //MARK: - helper methods
    
    func timeout() {
        self.navigationController?.popViewControllerAnimated(true)
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
