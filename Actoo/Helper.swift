//
//  Helper.swift
//  Actoo
//
//  Created by Сергей Колибаба on 13/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import Foundation

let token = "dict.1.1.20140822T101630Z.35cfb8076d8455ba.13f3d9e24a7348d2b1515dc05ec4fcf212afdc3e"
let supportedLanguagedUrl = "https://dictionary.yandex.net/api/v1/dicservice.json/getLangs"
let translateUrl = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup"

func showErrorController(title title: String, message: String, view: UIViewController) {
    let vc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    vc.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    view.presentViewController(vc, animated: true, completion: nil)
}

func setTabBarVisible(visible: Bool, viewController: UIViewController) {
    if (tabBarIsVisible(viewController) != visible) {
        let frame = viewController.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration: NSTimeInterval = 0.2
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                viewController.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
}

func tabBarIsVisible(viewController: UIViewController) -> Bool {
    return viewController.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(viewController.view.frame)
}