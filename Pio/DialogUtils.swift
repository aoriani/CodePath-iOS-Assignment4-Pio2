//
//  DialogUtils.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import MBProgressHUD


func showProgressDialog(attachedTo topView:UIView, message: String = "") -> MBProgressHUD {
    let progress = MBProgressHUD.showHUDAddedTo(topView, animated: true)
    progress.color = UIColor.init(colorLiteralRed: 0.34, green: 0.67, blue: 0.934, alpha: 1)
    progress.labelText = message
    progress.show(true)
    
    return progress
}
