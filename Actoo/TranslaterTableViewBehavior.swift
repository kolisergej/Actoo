//
//  ActooTableDataSource.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import CoreData
import Foundation

private let reuseIdentifier = "TranslaterCell"

class TranslaterTableViewBehavior: NSObject, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var currentWord: NSManagedObject?
    weak var translateController: TranslaterViewController!
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        translateController.translate()
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWord != nil ? (1 + (currentWord!.valueForKey("examples") as! [String: String]).count) : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            let title = currentWord!.valueForKey("trWord") as! String
            var synonyms = ""
            let syns = currentWord!.valueForKey("syns") as! [String]
            if !syns.isEmpty {
                synonyms += "; ";
                for synonym in syns {
                    synonyms += synonym + "; "
                }
            }
            cell.textLabel?.text = title + synonyms //+ "\(currentWord!.valueForKey("rating") as! Int)"
        } else {
            let keys = Array((currentWord!.valueForKey("examples") as! [String: String]).keys)
            let key = keys[indexPath.row - 1]
            cell.textLabel?.text = key + " - " + (currentWord!.valueForKey("examples") as! [String: String])[key]!
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