//
//  RemindViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    @IBOutlet weak var reminderTableView: UITableView!
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var gotItBtn: UIButton!
    @IBOutlet weak var knowBtn: UIButton!
    var currentOriginIndex = Int()
    var tableViewBehavior = ReminderTableViewBehavior()
    var words = [Word]() {
        didSet {
            appDelegate.words = words
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Reminder"
        
        gotItBtn.hidden = true
        reminderTableView.dataSource = tableViewBehavior
        reminderTableView.delegate = tableViewBehavior
        reminderTableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        words = appDelegate.words
        tableViewBehavior.extendMode = false
        if !words.isEmpty {
            showWord()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        tableViewBehavior.currentWord = nil
        gotItBtn.hidden = true
        forgotBtn.hidden = false
        knowBtn.hidden = false
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
        if !words.isEmpty {
            tableViewBehavior.extendMode = false
            showWord()
        }
    }
    
    @IBAction func acceptBtnPressed(sender: AnyObject) {
        if !words.isEmpty {
            if words[currentOriginIndex].rating > 0 {
                words[currentOriginIndex].rating -= 1
                appDelegate.words = words
            }
            showWord()
        }
    }
    
    @IBAction func rejectBtnPressed(sender: AnyObject) {
        if !words.isEmpty {
            words[currentOriginIndex].rating += 1
            appDelegate.words = words
            forgotBtn.hidden = true
            knowBtn.hidden = true
            gotItBtn.hidden = false
            tableViewBehavior.extendMode = true
            reminderTableView.reloadData()
        }
    }
    
    func showWord() {
        let index = currentOriginIndex
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
