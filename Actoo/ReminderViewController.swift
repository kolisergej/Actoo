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
    var tableViewBehavior = ReminderTableViewBehavior()
    var sessionWords = [NSManagedObject]()
    var currentOriginIndex = 0
    var needToReset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Reminder"
        configureStartGeneralUI()
        
        let areThereWords = !appDelegate.words.isEmpty
        
        forgotBtn.hidden = !areThereWords
        knowBtn.hidden = !areThereWords
        initTextView.hidden = areThereWords
        reminderTableView.hidden = !areThereWords
        
        if areThereWords {
            resetSessionWords()
            showWord()
        }
        
        tableViewBehavior.extendMode = false
    }
    
    override func viewWillAppear(animated: Bool) {
        if !appDelegate.words.isEmpty {
            initTextView.hidden = true
            reminderTableView.hidden = false
            if tableViewBehavior.currentWord == nil || needToReset {
                needToReset = false
                forgotBtn.hidden = false
                knowBtn.hidden = false
                gotItBtn.hidden = true
                resetSessionWords()
                showWord()
            }
        } else {
            forgotBtn.hidden = true
            knowBtn.hidden = true
            initTextView.hidden = false
            reminderTableView.hidden = true
        }
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
            incrementCurrentIndex()
            showWord()
        }
    }
    
    @IBAction func acceptBtnPressed(sender: AnyObject) {
        if !sessionWords.isEmpty {
            let rating = sessionWords[currentOriginIndex].valueForKey("rating") as! Int
            if rating > 0 {
                sessionWords[currentOriginIndex].setValue(rating - 1, forKey: "rating")
                appDelegate.saveContext()
            }
            
            incrementCurrentIndex()
            showWord()
        }
    }
    
    @IBAction func rejectBtnPressed(sender: AnyObject) {
        if !sessionWords.isEmpty {
            let rating = sessionWords[currentOriginIndex].valueForKey("rating") as! Int
            sessionWords[currentOriginIndex].setValue(rating + 1, forKey: "rating")
            appDelegate.saveContext()
            forgotBtn.hidden = true
            knowBtn.hidden = true
            gotItBtn.hidden = false
            tableViewBehavior.extendMode = true
            reminderTableView.reloadData()
        }
    }
    
    func resetSessionWords() {
        currentOriginIndex = 0
        var sessionWordsSize = 0
        if appDelegate.words.count < 15 {
            sessionWordsSize = 5
        } else if appDelegate.words.count < 30 {
            sessionWordsSize = 15
        } else {
            sessionWordsSize = 30
        }
        sessionWords = appDelegate.sessionWords(sessionWordsSize)
    }
    
    func incrementCurrentIndex() {
        if sessionWords.count > 1 {
            if currentOriginIndex < sessionWords.count - 1 {
                currentOriginIndex += 1
            } else {
                resetSessionWords()
            }
        } else {
            resetSessionWords()
        }
    }
    
    func showWord() {
        tableViewBehavior.currentWord = sessionWords[currentOriginIndex]
        reminderTableView.reloadData()
    }
    
    func RandomInt(min min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
    func configureStartGeneralUI() {
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
        
        gotItBtn.hidden = true
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
