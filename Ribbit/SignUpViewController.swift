//
//  SignUpViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/19/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit
import Foundation

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    
    @IBAction func signup(sender: AnyObject) {
        
        let username = self.usernameField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())//make sure there isn't any whitespace in the text fields
        let password = self.passwordField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let email = self.emailField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (countElements(username) == 0 || countElements(password) == 0 || countElements(email) == 0) {
            let networkIssueController = UIAlertController(title: "Oops", message: "Make sure you enter a username, password, and email address!", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
            networkIssueController.addAction(okButton)
            
            self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it

        } else if (email.rangeOfString("@") != nil && email.rangeOfString(".com") != nil) { //if the email seems valid, create user.  Otherwise throw a warning
        
            var newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            newUser.signUpInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                if (error == nil) { //if everything looks good, make the user
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    
                    let networkIssueController = UIAlertController(title: "Sorry!", message: "\(error.userInfo!)" , preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    networkIssueController.addAction(okButton)
                    
                    self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
                }
            })
            
        } else {
            let networkIssueController = UIAlertController(title: "Oops", message: "Make sure you enter a valid email address!", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
            networkIssueController.addAction(okButton)
            
            self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
        }
        
    }

}
