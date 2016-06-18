//
//  ReminderTableViewBehavior.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//
import UIKit
import Foundation

class ReminderTableViewBehavior: NSObject, UITableViewDelegate, UITableViewDataSource {
    var currentWord: Word?
    var extendMode = false
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWord != nil ? (extendMode ? 2 + currentWord!.examples.count : 1) : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath)
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            cell.textLabel?.text = currentWord!.origWord + " (\(currentWord!.fromLng))"
            cell.textLabel?.textAlignment = .Center
        }
        else if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            let title = currentWord!.trWord
            var synonyms = ""
            if !(currentWord!.syns.isEmpty) {
                synonyms += "; ";
                for synonym in currentWord!.syns {
                    synonyms += synonym + "; "
                }
            }
            cell.textLabel?.text = title + synonyms + " (\(currentWord!.toLng))"
        } else {
            let keys = Array(currentWord!.examples.keys)
            let key = keys[indexPath.row - 2]
            cell.textLabel?.text = key + " - " + currentWord!.examples[key]!
        }
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .None
        return cell
    }
}