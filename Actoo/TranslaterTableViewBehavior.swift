//
//  ActooTableDataSource.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import Foundation

class TranslaterTableViewBehavior: NSObject, UITableViewDelegate, UITableViewDataSource {
    var currentWord: Word?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWord != nil ? (1 + currentWord!.examples.count) : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TranslaterCell", forIndexPath: indexPath)
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            let title = currentWord!.trWord
            var synonyms = ""
            if !(currentWord!.syns.isEmpty) {
                synonyms += "; ";
                for synonym in currentWord!.syns {
                    synonyms += synonym + "; "
                }
            }
            cell.textLabel?.text = title + synonyms
        } else {
            let keys = Array(currentWord!.examples.keys)
            let key = keys[indexPath.row - 1]
            cell.textLabel?.text = key + " - " + currentWord!.examples[key]!
        }
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}