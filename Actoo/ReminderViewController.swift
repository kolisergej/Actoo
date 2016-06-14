//
//  RemindViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    @IBOutlet weak var reminderTableView: UITableView!
    
    var currentOriginIndex = Int()
    var words = [Word]() {
        didSet {
            saveWords()
        }
    }
    
    func saveWords() {
        appDelegate.words = words
        appDelegate.saveWords()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Reminder mode"
        reminderTableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        words = appDelegate.words
        if !words.isEmpty {
            showWord()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath)
        return cell
    }
    
    @IBAction func acceptBtnPressed(sender: AnyObject) {
        if !words.isEmpty {
            if words[currentOriginIndex].rating > 0 {
                words[currentOriginIndex].rating -= 1
                saveWords()
            }
            showWord()
        }
    }
    
    @IBAction func rejectBtnPressed(sender: AnyObject) {
        if !words.isEmpty {
            words[currentOriginIndex].rating += 1
            saveWords()
            showWord()
        }
    }
    
    func showWord() {
        currentOriginIndex = RandomInt(min: 0, max: words.count - 1)
        let word = words[currentOriginIndex]
        let cell = tableView(reminderTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        var synonyms = ""
        if !word.syns.isEmpty {
            synonyms += "; ";
            for synonym in word.syns {
                synonyms += synonym + "; "
            }
        }
        
        cell.textLabel?.text = word.origWord + " - " + word.trWord + synonyms
        reminderTableView.reloadData()
    }
    
    func RandomInt(min min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
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
