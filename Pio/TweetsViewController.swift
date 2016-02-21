//
//  TweetsViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/19/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        TwitterService.sharedInstance.loadTimeline(onSuccess: {_ in })
        TwitterService.sharedInstance.postUpdate("Samba do Capiroto", onSuccess: {_ in })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
