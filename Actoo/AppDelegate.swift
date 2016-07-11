//
//  AppDelegate.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var words = [Word]()
    var lng: Lng!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        loadWords()
        loadLng()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CoreDataManager.instance.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if !Reachability.isConnectedToNetwork() {
            let viewController = window!.rootViewController
            showErrorController(title: connectionError, message: checkInternetConnection + "\n Actoo will use saved data.", view: viewController!)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, applicationDidBecomeActive refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreDataManager.instance.saveContext()
    }

    func addWord(wordForSave: ActooWord) -> NSManagedObject {
        let word = Word()
        word.origWord = wordForSave.origWord
        word.examples = wordForSave.examples
        word.rating = Int32(wordForSave.rating)
        word.trWord = wordForSave.trWord
        word.fromLng = wordForSave.fromLng
        word.syns = wordForSave.syns
        word.toLng = wordForSave.toLng
        words.append(word)
        CoreDataManager.instance.saveContext()
        return word
    }
    
    func deleteWord(indexPath: NSIndexPath) {
        CoreDataManager.instance.managedObjectContext.deleteObject(words[indexPath.row])
        CoreDataManager.instance.saveContext()
        words.removeAtIndex(indexPath.row)
    }
    
    func loadWords() {
        let fetchRequest = NSFetchRequest(entityName:"Word")
        words = try! CoreDataManager.instance.managedObjectContext.executeFetchRequest(fetchRequest) as! [Word]
    }
    
    func loadLng() {
        let fetchRequest = NSFetchRequest(entityName:"Lng")
        let results = try! CoreDataManager.instance.managedObjectContext.executeFetchRequest(fetchRequest) as! [Lng]
        
        if !results.isEmpty {
            lng = results[0]
        } else {
            lng = Lng()
            lng.directions = defaultLngDirections
            lng.fromLng = "en"
            lng.toLng = "ru"
            CoreDataManager.instance.saveContext()
        }
    }
    
    func saveDirections(directions: [String]) {
        lng.directions = directions
        CoreDataManager.instance.saveContext()
    }
    
    func saveLanguages(fromLng: String, toLng: String) {
        lng.fromLng = fromLng
        lng.toLng = toLng
        CoreDataManager.instance.saveContext()
    }
    
    func changeWordRating(word: Word, increase: Bool) {
        let rating = Int(word.rating) + (increase ? 1 : -1)
        word.rating = Int32(rating)
        CoreDataManager.instance.saveContext()
    }
    
    func sessionWords(count: Int) -> [Word] {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let sort = NSSortDescriptor(key: "rating", ascending: false)
        fetchRequest.fetchLimit = count
        fetchRequest.sortDescriptors = [sort]
        let fetchedResults = try! CoreDataManager.instance.managedObjectContext.executeFetchRequest(fetchRequest) as! [Word]
        let rating = Int(fetchedResults.last!.rating)
        
        let firstPartFetchRequest = NSFetchRequest(entityName: "Word")
        firstPartFetchRequest.sortDescriptors = [sort]
        firstPartFetchRequest.predicate = NSPredicate(format: "%K > %i", "rating", rating)
        var firstPart = try! CoreDataManager.instance.managedObjectContext.executeFetchRequest(firstPartFetchRequest) as! [Word]
        
        let secondPartFetchRequest = NSFetchRequest(entityName: "Word")
        secondPartFetchRequest.predicate = NSPredicate(format: "%K == %i", "rating", rating)
        var secondPart = try! CoreDataManager.instance.managedObjectContext.executeFetchRequest(secondPartFetchRequest) as! [Word]

        let size = secondPart.count - 1
        if size > 1 {
            for i in (0...size).reverse() {
                let tmp = secondPart[i]
                let randomIndex = Int(arc4random_uniform(UInt32(i + 1)))
                secondPart[i] = secondPart[randomIndex]
                secondPart[randomIndex] = tmp
            }
        }
        
        for i in 0 ..< secondPart.count {
            if firstPart.count == count {
                break;
            }
            firstPart.append(secondPart[i])
        }
        return firstPart
    }
    
}

