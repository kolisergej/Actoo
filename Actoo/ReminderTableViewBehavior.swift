//
//  ReminderTableViewBehavior.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class ReminderTableViewBehavior: NSObject, UITableViewDelegate, UITableViewDataSource {
    var currentWord: NSManagedObject?
    var extendMode = false
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWord != nil ? (extendMode ? 2 + (currentWord!.valueForKey("examples") as! [String: String]).count : 1) : 0
    }
    
    func imageBorderedWithColor(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        image.drawAtPoint(CGPointZero)
        UIColor.grayColor().setStroke()
        let path = UIBezierPath(rect: CGRectMake(0, 0, image.size.width, image.size.height))
        path.lineWidth = 1
        path.stroke()
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return result;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath)
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            let attachmentFromLng = NSTextAttachment()
            attachmentFromLng.image = imageBorderedWithColor(UIImage(named: currentWord!.valueForKey("fromLng") as! String)!)

            let attachmentToLng = NSTextAttachment()
            attachmentToLng.image = imageBorderedWithColor(UIImage(named: currentWord!.valueForKey("toLng") as! String)!)
            
            let attachmentArrow = NSTextAttachment()
            attachmentArrow.image = UIImage(named: "arrow")!
            
            let attributedString = NSMutableAttributedString(string: (currentWord!.valueForKey("origWord") as! String) + "\n\n")
            attributedString.appendAttributedString(NSAttributedString(attachment: attachmentFromLng))
            attributedString.appendAttributedString(NSAttributedString(attachment: attachmentArrow))
            attributedString.appendAttributedString(NSAttributedString(attachment: attachmentToLng))
            
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.textAlignment = .Center
        }
        else if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            let title = currentWord!.valueForKey("trWord") as! String
            var synonyms = ""
            let syns = currentWord!.valueForKey("syns") as! [String]
            if !syns.isEmpty {
                synonyms += "; ";
                for synonym in syns {
                    synonyms += synonym + "; "
                }
            }
            cell.textLabel?.attributedText = NSAttributedString(string: title + synonyms)
        } else {
            let keys = Array((currentWord!.valueForKey("examples") as! [String: String]).keys)
            let key = keys[indexPath.row - 2]
            cell.textLabel?.attributedText = NSAttributedString(string: key + " - " + (currentWord!.valueForKey("examples") as! [String: String])[key]!)
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}