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

    weak var delegate: TranslaterViewController!
    var countries = [Country]()
    var isFromCalled = true
    var currentCellIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.backgroundColor = UIColor.whiteColor()
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
        let country = countries[indexPath.item]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CountryCell
        cell.countryName.text = country.countryName
        cell.flagImage.image = UIImage(named: country.flagImage)
        cell.flagImage.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.flagImage.layer.borderWidth = 2
        cell.flagImage.layer.cornerRadius = 3
        cell.layer.borderWidth = 0
        if (isFromCalled && country.flagImage == delegate.fromLngBtn.currentAttributedTitle?.string) ||
            (!isFromCalled && country.flagImage == delegate.toLngBtn.currentAttributedTitle?.string) {
            distinguishCell(cell)
            currentCellIndex = indexPath
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let country = countries[indexPath.item]
        
        if isFromCalled {
            delegate.fromLngBtn.setAttributedTitle(NSAttributedString(string: country.countryName), forState: .Normal)
            delegate.fromLngBtn.setImage(UIImage(named: country.flagImage), forState: .Normal)
            if !(delegate.languageDirections[country.countryName]!.contains(delegate.toLngBtn.currentAttributedTitle!.string)) {
                let countryName = delegate.languageDirections[country.countryName]!.first!
                delegate.toLngBtn.setAttributedTitle(NSAttributedString(string: countryName), forState: .Normal)
                for cnt in countries {
                    if cnt.countryName == countryName {
                        delegate.toLngBtn.setImage(UIImage(named: cnt.flagImage), forState: .Normal)
                        break;
                    }
                }
            }
        } else {
            delegate.toLngBtn.setAttributedTitle(NSAttributedString(string: country.countryName), forState: .Normal)
            delegate.toLngBtn.setImage(UIImage(named: country.flagImage), forState: .Normal)
        }
        
        UIView.animateWithDuration(0.5, animations: {[unowned self] () -> Void in
            if let _ = self.currentCellIndex {
                let currentCell = collectionView.cellForItemAtIndexPath(self.currentCellIndex!) as? CountryCell
                currentCell?.layer.borderWidth = 0
            }
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CountryCell
            self.distinguishCell(cell)
            self.delegate.saveLanguages()
        }) {[unowned self]
            (value: Bool) -> Void in
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.12 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func distinguishCell(cell: CountryCell) {
        cell.layer.cornerRadius = 7
        cell.layer.borderWidth = 5
        cell.layer.borderColor = view.tintColor.CGColor
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
