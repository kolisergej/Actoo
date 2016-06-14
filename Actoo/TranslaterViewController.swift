//
//  ViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//


import UIKit

class TranslaterViewController: UIViewController {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    var languageDirections = [String: [String]]()
    var tableViewBehavior = TranslaterTableViewBehavior()
    var switchLngBtn: UIBarButtonItem!
    var fromLngBtn: UIBarButtonItem!
    var toLngBtn: UIBarButtonItem!
    var words = [Word]() {
        didSet {
            saveWords()
        }
    }
    
    @IBOutlet weak var textForTranslate: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = NSURL(string: supportedLanguagedUrl + "?key=" + token) {
            if let data = try? NSData(contentsOfURL: url, options: []) {
                let json = JSON(data: data).arrayValue
                for fromToLanguages in json {
                    let fromTo = fromToLanguages.stringValue.componentsSeparatedByString("-");
                    var toArray = languageDirections[fromTo[0]] ?? [];
                    toArray.append(fromTo[1])
                    languageDirections[fromTo[0]] = toArray
                }
            } else {
                showErrorController(title: "Connection error", message: "Check internet connection.\n Actoo will use cached data.", view: self)
            }
        } else {
            showErrorController(title: "Unexpected error", message: "Internal error. Contact to kolisergej@yandex.ru", view: self)
        }

        switchLngBtn = UIBarButtonItem(image: UIImage(named: "switch")!, style: .Plain, target: self, action: #selector(switchLng))
        
        let defaultManager = NSUserDefaults.standardUserDefaults()
        let fromLng = defaultManager.valueForKey("fromLng") as? String ?? "en"
        let toLng = defaultManager.valueForKey("toLng") as? String ?? "ru"
        
        let path = NSBundle.mainBundle().resourcePath!
        let fromBtn = UIButton(type: .Custom)
        let fromImage = UIImage(contentsOfFile: path + "/" + fromLng)!
        fromBtn.frame = CGRectMake(0, 0, fromImage.size.width, fromImage.size.height);
        fromBtn.setBackgroundImage(fromImage, forState: .Normal)
        fromBtn.addTarget(self, action: #selector(fromLngSegue), forControlEvents: .TouchUpInside)
        fromLngBtn = UIBarButtonItem(customView: fromBtn)
        fromLngBtn.title = fromLng
        
        let toBtn = UIButton(type: .Custom)
        let toImage = UIImage(contentsOfFile: path + "/" + toLng)!
        toBtn.frame = CGRectMake(0, 0, toImage.size.width, toImage.size.height);
        toBtn.setBackgroundImage(toImage, forState: .Normal)
        toBtn.addTarget(self, action: #selector(toLngSegue), forControlEvents: .TouchUpInside)
        toLngBtn = UIBarButtonItem(customView: toBtn)
        toLngBtn.title = toLng
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Translater"
        navigationItem.rightBarButtonItems = [toLngBtn, switchLngBtn, fromLngBtn]
        
        resultTableView.dataSource = tableViewBehavior
        resultTableView.delegate = tableViewBehavior
        resultTableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        words = appDelegate.words
        setTabBarVisible(true, viewController: self)
    }
    
    @IBAction func translate(sender: AnyObject) {
        if let input = textForTranslate.text {
            let trimmedString = input.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if trimmedString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).count > 1 {
                showError("Yandex translate service", message: "Put in one word")
                return
            }
            
            for index in 0 ..< words.count {
                if words[index].origWord == trimmedString && words[index].fromLng == fromLngBtn.title! && words[index].toLng == toLngBtn.title! {
                    words[index].rating += 1
                    saveWords()
                    tableViewBehavior.currentWord = words[index]
                    resultTableView.reloadData()
                    return
                }
            }
            
            if let url = buildTranslateUrl() {
                tableViewBehavior.currentWord = nil
                resultTableView.reloadData()
//                print(url.absoluteString)
                let waitVc = UIAlertController(title: "Yandex transate service", message: nil, preferredStyle: .Alert)
                waitVc.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                let indicator = UIActivityIndicatorView(frame: waitVc.view.bounds)
                indicator.activityIndicatorViewStyle = .Gray
                indicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                waitVc.view.addSubview(indicator)
                indicator.startAnimating()
                presentViewController(waitVc, animated: true, completion: nil)
                
                if let data = try? NSData(contentsOfURL: url, options: []) {
                    let json = JSON(data: data)
                    if let word = handleTranslateNetworkAnswer(json) {
                        waitVc.dismissViewControllerAnimated(true) {[unowned self, word] in
                            self.tableViewBehavior.currentWord = word
                            self.words.append(word)
                            self.resultTableView.reloadData()
                        }
                    } else {
                        waitVc.dismissViewControllerAnimated(true) { [unowned self] in
                            self.showError("Yandex transate service", message: "Unknown word")
                        }
                    }
                } else {
                    waitVc.dismissViewControllerAnimated(true) { [unowned self] in
                        self.showError("Connection error", message: "Check Internet connection")
                    }
                }
            } else {
                showError("Invalid request", message: "Check your words")
            }
        }
    }

    func handleTranslateNetworkAnswer(json: JSON) -> Word? {
        let translateAnswer = json["def"].arrayValue
        if !translateAnswer.isEmpty {
            let origWord = translateAnswer[0]["text"].stringValue
            let tr = translateAnswer[0]["tr"][0]["text"].stringValue
            var synonims = [String]()
            let synonimsAnswer = translateAnswer[0]["tr"][0]["syn"].arrayValue
            for synonim in synonimsAnswer {
                synonims.append(synonim["text"].stringValue)
            }
            var examples = [String: String]()
            let examplesAnswer = translateAnswer[0]["tr"][0]["ex"].arrayValue
            for example in examplesAnswer {
                examples[example["text"].stringValue] = example["tr"][0]["text"].stringValue
            }
            return Word(origWord: origWord, fromLng: fromLngBtn.title!, trWord: tr, toLng: toLngBtn.title!, syns: synonims, examples: examples, rating: 1)
        }
        return nil
    }
    
    func buildTranslateUrl() -> NSURL? {
        let escapedText = textForTranslate.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: translateUrl + "?key=" + token + "&lang=" + fromLngBtn.title! + "-" + toLngBtn.title! + "&text=" + escapedText)
    }
    
    func showError(title: String, message: String) {
        tableViewBehavior.currentWord = nil
        resultTableView.reloadData()
        showErrorController(title: title, message: message, view: self)
    }
    
    func switchLng() {
        let fromBtn = fromLngBtn.customView as! UIButton
        let toBtn = toLngBtn.customView as! UIButton
        
        let tmpLngTitle = fromLngBtn.title!
        let tmpImg = fromBtn.backgroundImageForState(.Normal)
        
        fromLngBtn.title = toLngBtn.title!
        fromBtn.setBackgroundImage(toBtn.backgroundImageForState(.Normal), forState: .Normal)
        toLngBtn.title = tmpLngTitle
        toBtn.setBackgroundImage(tmpImg, forState: .Normal)
        
        let defaultManager = NSUserDefaults.standardUserDefaults()
        defaultManager.setValue(fromLngBtn.title!, forKey: "fromLng")
        defaultManager.setValue(toLngBtn.title!, forKey: "toLng")
    }
    
    func saveWords() {
        appDelegate.words = words
        appDelegate.saveWords()
    }
    
    func fromLngSegue() {
        performSegueWithIdentifier("showLanguages", sender: "fromLng")
    }
    
    func toLngSegue() {
        performSegueWithIdentifier("showLanguages", sender: "toLng")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLanguages" {
            let senderButtonId = sender as! String
            let countryViewController = segue.destinationViewController as! CountryViewController
            countryViewController.delegate = self
            countryViewController.navigationItem.leftItemsSupplementBackButton = true
            if senderButtonId == "fromLng" {
                countryViewController.isFromCalled = true
                for country in languageDirections {
                    countryViewController.countries.append(Country(countryName: country.0, flagImage: country.0))
                }
            } else if senderButtonId == "toLng" {
                countryViewController.isFromCalled = false
                for country in languageDirections[fromLngBtn.title!]! {
                    countryViewController.countries.append(Country(countryName: country, flagImage: country))
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

