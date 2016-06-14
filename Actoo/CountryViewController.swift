//
//  FlagsViewController.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CountryCell"

class CountryViewController: UICollectionViewController {

    var countries = [Country]()
    weak var delegate: TranslaterViewController!
    var isFromCalled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        collectionView!.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        setTabBarVisible(false, viewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CountryCell
    
        let country = countries[indexPath.item]
        cell.countryName.text = country.countryName
        
        let path = NSBundle.mainBundle().resourcePath!
        let image = UIImage(contentsOfFile: path + "/" + country.flagImage)!
        cell.flagImage.image = image
        
        cell.flagImage.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.flagImage.layer.borderWidth = 2
        cell.flagImage.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
    
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let country = countries[indexPath.item]
        let toBtn = (delegate.toLngBtn.customView as! UIButton)
        let fromBtn = (delegate.fromLngBtn.customView as! UIButton)
        let path = NSBundle.mainBundle().resourcePath!
        if isFromCalled {
            delegate.fromLngBtn.title = country.countryName
            fromBtn.setBackgroundImage(UIImage(contentsOfFile: path + "/" + country.flagImage)!, forState: .Normal)
            if !(delegate.languageDirections[country.countryName]!.contains(delegate.toLngBtn.title!)) {
                let countryName = delegate.languageDirections[country.countryName]!.first!
                delegate.toLngBtn.title = countryName
                for cnt in countries {
                    if cnt.countryName == countryName {
                        toBtn.setBackgroundImage(UIImage(contentsOfFile: path + "/" + cnt.flagImage)!, forState: .Normal)
                        break;
                    }
                }
            }
        } else {
            delegate.toLngBtn.title = country.countryName
            toBtn.setBackgroundImage(UIImage(contentsOfFile: path + "/" + country.flagImage)!, forState: .Normal)
        }
        navigationController?.popViewControllerAnimated(true)
    }

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
