//
//  ViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//


import UIKit

class TranslaterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    var languageDirections = [String: [String]]()
    var switchLngBtn: UIBarButtonItem!
    var fromLngBtn: UIBarButtonItem! {
        didSet {
            let defaultManager = NSUserDefaults.standardUserDefaults()
            defaultManager.setValue(fromLngBtn.title!, forKey: "fromLng")
        }
    }
    var toLngBtn: UIBarButtonItem! {
        didSet {
            let defaultManager = NSUserDefaults.standardUserDefaults()
            defaultManager.setValue(toLngBtn.title!, forKey: "toLng")
        }
    }
    var words = [Word]() {
        didSet {
            saveWords()
        }
    }
    
    @IBOutlet weak var textForTranslate: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    
    func switchLng() {
        let tmpLngBtn = fromLngBtn
        fromLngBtn = toLngBtn
        toLngBtn = tmpLngBtn
        navigationItem.rightBarButtonItems = [toLngBtn, switchLngBtn, fromLngBtn]
    }
    
    func saveWords() {
        appDelegate.words = words
        appDelegate.saveWords()
    }
    
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
        fromLngBtn = UIBarButtonItem(title: fromLng, style: .Plain, target: self, action: nil)
        toLngBtn = UIBarButtonItem(title: toLng, style: .Plain, target: self, action: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Translater mode"
        navigationItem.rightBarButtonItems = [toLngBtn, switchLngBtn, fromLngBtn]
        
        resultTableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        words = appDelegate.words
        for word in words {
            print(word.origWord, word.rating)
            for example in word.examples {
                print(example.0, example.1)
            }
        }
    }
    
    @IBAction func translate(sender: AnyObject) {
        if let input = textForTranslate.text {
            let trimmedString = input.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if trimmedString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).count > 1 {
                showError("Yandex translate service", message: "Put in one word")
                return
            }
            
            for index in 0 ..< words.count {
                if words[index].origWord == trimmedString && words[index].fromLng == fromLngBtn.title && words[index].toLng == toLngBtn.title {
                    words[index].rating += 1
                    saveWords()
                    updateTableView(words[index])
                    return
                }
            }
            
            if let url = buildTranslateUrl() {
                updateTableView(nil) // set title ""
                print(url.absoluteString)
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
                        waitVc.dismissViewControllerAnimated(true) {[unowned self] in
                            self.words.append(word)
                            self.updateTableView(word)
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
    
    func updateTableView(word: Word?) {
        let cell = tableView(resultTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        let title = word?.trWord ?? ""
        var synonyms = ""
        if let syns = word?.syns {
            if !syns.isEmpty {
                synonyms += "; ";
                for synonym in syns {
                    synonyms += synonym + "; "
                }
            }
        }
        
        cell.textLabel?.text = title + synonyms
        resultTableView.reloadData()

//        for syn in word?.syns {
//            print(syn)
//        }
//        for ex in word?.examples {
//            print(ex.0, "-", ex.1)
//        }
//
//        setResultTableCellTitle(value.translatedWord + synonims + examples)
//        print(value.translatedWord + synonims + examples)
    }
    
    func showError(title: String, message: String) {
        updateTableView(nil) // ""
        showErrorController(title: title, message: message, view: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TranslaterCell", forIndexPath: indexPath)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

