//
//  WordsListViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 02/07/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit

class WordsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    weak var reminderViewController: ReminderViewController!
    var initTextView: UITextView!
    
    @IBOutlet weak var dictionaryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dictionaryTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        initTextView = addInitTextView(view)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.title = "Dictionary"
        dictionaryTableView.delegate = self
        dictionaryTableView.dataSource = self
        
        reminderViewController = appDelegate.window?.rootViewController?.childViewControllers[1].childViewControllers[0] as! ReminderViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        if appDelegate.words.isEmpty {
            initTextView.hidden = false
            dictionaryTableView.hidden = true
        } else {
            initTextView.hidden = true
            dictionaryTableView.hidden = false
            dictionaryTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.words.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DictionaryCell", forIndexPath: indexPath)
        let currentWord = appDelegate.words[indexPath.row]
        
        let attachmentFromLng = NSTextAttachment()
        attachmentFromLng.image = imageBorderedWithColor(UIImage(named: currentWord.valueForKey("fromLng") as! String)!)
        
        let attachmentToLng = NSTextAttachment()
        attachmentToLng.image = imageBorderedWithColor(UIImage(named: currentWord.valueForKey("toLng") as! String)!)
        
        let attachmentArrow = NSTextAttachment()
        attachmentArrow.image = UIImage(named: "arrow")!
        
        let attributedString = NSMutableAttributedString()
        attributedString.appendAttributedString(NSAttributedString(attachment: attachmentFromLng))
        attributedString.appendAttributedString(NSAttributedString(attachment: attachmentArrow))
        attributedString.appendAttributedString(NSAttributedString(attachment: attachmentToLng))
        
        cell.textLabel?.text = (currentWord.valueForKey("origWord") as! String)
        cell.detailTextLabel?.attributedText = attributedString
        cell.selectionStyle = .None

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDelegate.deleteWord(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            reminderViewController.needToReset = true
            if appDelegate.words.isEmpty {
                initTextView.hidden = false
                dictionaryTableView.hidden = true
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
