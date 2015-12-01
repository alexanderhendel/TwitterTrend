//
//  ViewController.swift
//  TwitterTrend
//
//  Created by Hiro on 05.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
   
    // MARK: - variables / shared objects
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                
                let alertActionOk = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    
                    // transition to mapView
                    self.performSegueWithIdentifier("showMapSegue", sender: self)
                })
                
                alert.addAction(alertActionOk)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        logInButton.center.y = subheaderLabel.center.y + (logInButton.frame.height * 2)
        self.view.addSubview(logInButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

