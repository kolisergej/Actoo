//
//  RemindViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import CoreData

class ReminderViewController: UIViewController {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    @IBOutlet weak var reminderTableView: UITableView!
    @IBOutlet weak var initTextView: UITextView!
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var gotItBtn: UIButton!
    @IBOutlet weak var knowBtn: UIButton!
    var currentOriginIndex = Int()
    var tableViewBehavior = ReminderTableViewBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Reminder"
        
        reminderTableView.dataSource = tableViewBehavior
        reminderTableView.delegate = tableViewBehavior
        reminderTableView.separatorColor = UIColor.clearColor()
        
        forgotBtn.layer.borderWidth = 1
        knowBtn.layer.borderWidth = 1
        gotItBtn.layer.borderWidth = 1
        
        forgotBtn.layer.cornerRadius = 5
        knowBtn.layer.cornerRadius = 5
        gotItBtn.layer.cornerRadius = 5
        
        forgotBtn.layer.borderColor = view.tintColor.CGColor
        knowBtn.layer.borderColor = view.tintColor.CGColor
        gotItBtn.layer.borderColor = view.tintColor.CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        if !appDelegate.words.isEmpty {
            initTextView.hidden = true
            tableViewBehavior.extendMode = false
            reminderTableView.hidden = false
            showWord()
        } else {
            forgotBtn.hidden = true
            knowBtn.hidden = true
            initTextView.hidden = false
            reminderTableView.hidden = true
        }
        gotItBtn.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        tableViewBehavior.currentWord = nil
        gotItBtn.hidden = true
        forgotBtn.hidden = false
        knowBtn.hidden = false
        tableViewBehavior.extendMode = false
        reminderTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gotItBtnPressed(sender: AnyObject) {
        gotItBtn.hidden = true
        forgotBtn.hidden = false
        knowBtn.hidden = false
        if !appDelegate.words.isEmpty {
            tableViewBehavior.extendMode = false
            showWord()
        }
    }
    
    @IBAction func acceptBtnPressed(sender: AnyObject) {
        let words = appDelegate.words
        if !words.isEmpty {
            let rating = words[currentOriginIndex].valueForKey("rating") as! Int
            if rating > 0 {
                words[currentOriginIndex].setValue(rating - 1, forKey: "rating")
                appDelegate.saveContext()
            }
            showWord()
        }
    }
    
    @IBAction func rejectBtnPressed(sender: AnyObject) {
        let words = appDelegate.words
        if !words.isEmpty {
            let rating = words[currentOriginIndex].valueForKey("rating") as! Int
            words[currentOriginIndex].setValue(rating + 1, forKey: "rating")
            appDelegate.saveContext()
            forgotBtn.hidden = true
            knowBtn.hidden = true
            gotItBtn.hidden = false
            tableViewBehavior.extendMode = true
            reminderTableView.reloadData()
        }
    }
    
    func showWord() {
        let index = currentOriginIndex
        let words = appDelegate.words
        if words.count > 1 {
            while currentOriginIndex == index {
                currentOriginIndex = RandomInt(min: 0, max: words.count - 1)
            }
        }
        tableViewBehavior.currentWord = words[currentOriginIndex]
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
