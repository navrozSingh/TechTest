//
//  AppUtils.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import UIKit

/* Show Progress Indicator */
func showProgressIndicator(view:UIView){
    view.isUserInteractionEnabled = false
    let progressIndicator = ProgressIndicator(text: "Please wait..")
    progressIndicator.tag = PROGRESS_INDICATOR_VIEW_TAG
    view.addSubview(progressIndicator)
}

/* Hide progress Indicator */
func hideProgressIndicator(view:UIView){
    view.isUserInteractionEnabled = true

    if let viewWithTag = view.viewWithTag(PROGRESS_INDICATOR_VIEW_TAG) {
        viewWithTag.removeFromSuperview()
    }
}
