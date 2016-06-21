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
    var words = [Word]() {
        didSet {
            appDelegate.words = words
        }
    }
    
    @IBOutlet weak var fromLngBtn: UIButton!
    @IBOutlet weak var toLngBtn: UIButton!
    @IBOutlet weak var textForTranslate: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    var currentTokenIndex = 0
    
    func getCurrentTokenIndex() -> String {
        currentTokenIndex += 1
        return token[currentTokenIndex % token.count]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let extractedToken = getCurrentTokenIndex()
        if let url = NSURL(string: supportedLanguagedUrl + extractedToken) {
            print(url.absoluteString)
            if let data = try? NSData(contentsOfURL: url, options: []) {
                let json = JSON(data: data).arrayValue
                for fromToLanguages in json {
                    let fromTo = fromToLanguages.stringValue.componentsSeparatedByString("-");
                    var toArray = languageDirections[fromTo[0]] ?? [];
                    if fromTo[0] != fromTo[1] {
                        toArray.append(fromTo[1])
                        languageDirections[fromTo[0]] = toArray
                    }
                }
            } else {
                showErrorController(title: "Connection error", message: "Check internet connection.\n Actoo will use cached data.", view: self)
            }
        } else {
            showErrorController(title: "Unexpected error", message: "Internal error. Contact to kolisergej@yandex.ru", view: self)
        }
        
        let defaultManager = NSUserDefaults.standardUserDefaults()
        let fromLng = defaultManager.valueForKey("fromLng") as? String ?? "en"
        let toLng = defaultManager.valueForKey("toLng") as? String ?? "ru"
        
        fromLngBtn.setImage(UIImage(named: fromLng), forState: .Normal)
        fromLngBtn.setAttributedTitle(NSAttributedString(string: fromLng), forState: .Normal)
        fromLngBtn.imageView?.layer.borderWidth = 1
        fromLngBtn.imageView?.layer.borderColor = UIColor.grayColor().CGColor
        
        toLngBtn.setImage(UIImage(named: toLng), forState: .Normal)
        toLngBtn.setAttributedTitle(NSAttributedString(string: toLng), forState: .Normal)
        toLngBtn.imageView?.layer.borderWidth = 1
        toLngBtn.imageView?.layer.borderColor = UIColor.grayColor().CGColor
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Translater"
        
        textForTranslate.delegate = tableViewBehavior
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
            } else if trimmedString.isEmpty {
                showError("Yandex translate service", message: "Put any word")
                return
            }
            
            for index in 0 ..< words.count {
                if words[index].origWord == trimmedString && words[index].fromLng == fromLngBtn.currentAttributedTitle?.string && words[index].toLng == toLngBtn.currentAttributedTitle?.string {
                    words[index].rating += 1
                    appDelegate.words = words
                    tableViewBehavior.currentWord = words[index]
                    resultTableView.reloadData()
                    return
                }
            }
            
            if let url = buildTranslateUrl() {
                print(url.absoluteString)
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
            return Word(origWord: origWord, fromLng: fromLngBtn.currentAttributedTitle!.string, trWord: tr, toLng: toLngBtn.currentAttributedTitle!.string, syns: synonims, examples: examples, rating: 1)
        }
        return nil
    }
    
    func buildTranslateUrl() -> NSURL? {
        let escapedText = textForTranslate.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let extractedToken = getCurrentTokenIndex()
        return NSURL(string: translateUrl + extractedToken + "&lang=" + fromLngBtn.currentAttributedTitle!.string + "-" + toLngBtn.currentAttributedTitle!.string + "&text=" + escapedText)
    }
    
    func showError(title: String, message: String) {
        tableViewBehavior.currentWord = nil
        resultTableView.reloadData()
        showErrorController(title: title, message: message, view: self)
    }
    
    @IBAction func switchLngBtnPressed(sender: AnyObject) {
        let tmpLngTitle = fromLngBtn.currentAttributedTitle
        let tmpImg = fromLngBtn.currentImage
        
        fromLngBtn.setAttributedTitle(toLngBtn.currentAttributedTitle, forState: .Normal)
        fromLngBtn.setImage(toLngBtn.currentImage, forState: .Normal)
        toLngBtn.setAttributedTitle(tmpLngTitle, forState: .Normal)
        toLngBtn.setImage(tmpImg, forState: .Normal)
        
        saveLanguages()
    }
    
    func saveLanguages() {
        let defaultManager = NSUserDefaults.standardUserDefaults()
        defaultManager.setValue(fromLngBtn.currentAttributedTitle!.string, forKey: "fromLng")
        defaultManager.setValue(toLngBtn.currentAttributedTitle!.string, forKey: "toLng")
    }
    
    @IBAction func fromLngBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("showLanguages", sender: "fromLng")
    }
    
    @IBAction func toLngBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("showLanguages", sender: "toLng")
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLanguages" {
            let senderButtonId = sender as! String
            let countryViewController = segue.destinationViewController as! CountryViewController
            countryViewController.delegate = self
            if senderButtonId == "fromLng" {
                countryViewController.isFromCalled = true
                for country in languageDirections {
                    countryViewController.countries.append(Country(countryName: country.0, flagImage: country.0))
                }
            } else if senderButtonId == "toLng" {
                countryViewController.isFromCalled = false
                for country in languageDirections[fromLngBtn.currentAttributedTitle!.string]! {
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

