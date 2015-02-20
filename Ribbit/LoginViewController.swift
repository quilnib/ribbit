//
//  LoginViewController.swift
//  Ribbit
//
//  Created by Tim Walsh on 2/19/15.
//  Copyright (c) 2015 ClassicTim. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationItem.hidesBackButton = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn(sender: AnyObject) {
        
        let username = self.usernameField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())//make sure there isn't any whitespace in the text fields
        let password = self.passwordField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (countElements(username) == 0 || countElements(password) == 0 ) {
            let networkIssueController = UIAlertController(title: "Oops", message: "Make sure you enter a username and password!", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
            networkIssueController.addAction(okButton)
            
            self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
        } else {// if everything looks good we'll log them in
            PFUser.logInWithUsernameInBackground(username, password: password) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    // The login failed. Check error to see why.
                    let networkIssueController = UIAlertController(title: "Sorry!", message: "\(error.userInfo!)" , preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    networkIssueController.addAction(okButton)
                    
                    self.presentViewController(networkIssueController, animated: true, completion: nil)// you have to display the alert after you create it
                }
            }
        }

    }

}
