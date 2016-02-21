//
//  ViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/16/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class NoCredentialsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTwitterLoginButtonPressed(sender: AnyObject) {
        let showErrorDialog: (String) -> Void = {
            errorMessage in
                let alertDialog = UIAlertView(title: "Error",
                    message: "Something went wrong. Please try again later",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alertDialog.show()
        }
        
        UserManager.singleton.startLoginFlow(onSuccess: {
                user in
                    let tweetsVC = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsNavViewController")
                    self.presentViewController(tweetsVC!, animated: true, completion: nil)
            },
            onFailure: showErrorDialog)
    }
    
    
    
}
