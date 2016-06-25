//
//  AppDelegate.swift
//  Actoo
//
//  Created by Сергей Колибаба on 22/05/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import UIKit
import CoreData
import GameplayKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var words = [NSManagedObject]()
    var lng: NSManagedObject!

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
        self.saveContext()
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
        self.saveContext()
    }

    func addWord(wordForSave: Word) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName("Word", inManagedObjectContext: managedObjectContext)
        let word = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        word.setValue(wordForSave.origWord, forKey: "origWord")
        word.setValue(wordForSave.examples, forKey: "examples")
        word.setValue(wordForSave.rating, forKey: "rating")
        word.setValue(wordForSave.trWord, forKey: "trWord")
        word.setValue(wordForSave.fromLng, forKey: "fromLng")
        word.setValue(wordForSave.syns, forKey: "syns")
        word.setValue(wordForSave.toLng, forKey: "toLng")
        words.append(word)
        return word
    }
    
    func loadWords() {
        let fetchRequest = NSFetchRequest(entityName:"Word")
        let fetchedResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        
        if let results = fetchedResults {
            words = results
        } else {
            print("Could not fetch words")
        }
    }
    
    func loadLng() {
        let fetchRequest = NSFetchRequest(entityName:"Lng")
        let fetchedResult = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        
        if let results = fetchedResult {
            if !results.isEmpty {
                lng = results[0]
            } else {
                let entity = NSEntityDescription.entityForName("Lng", inManagedObjectContext: managedObjectContext)
                lng = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
                lng.setValue(defaultLngDirections, forKey: "directions")
                lng.setValue("en", forKey: "fromLng")
                lng.setValue("ru", forKey: "toLng")
                saveContext()
            }
        } else {
            print("Could not fetch lng")
        }
    }
    
    func sessionWords(count: Int) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let sort = NSSortDescriptor(key: "rating", ascending: false)
        fetchRequest.fetchLimit = count
        fetchRequest.sortDescriptors = [sort]
        let fetchedResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        let rating = fetchedResults.last!.valueForKey("rating") as! Int
        
        let firstPartFetchRequest = NSFetchRequest(entityName: "Word")
        let predicate = NSPredicate(format: "%K > %i", "rating", rating)
        firstPartFetchRequest.sortDescriptors = [sort]
        firstPartFetchRequest.predicate = predicate
        var firstPart = try! managedObjectContext.executeFetchRequest(firstPartFetchRequest) as! [NSManagedObject]
        
        let secondPartFetchRequest = NSFetchRequest(entityName: "Word")
        let predicate2 = NSPredicate(format: "%K == %i", "rating", rating)
        secondPartFetchRequest.predicate = predicate2
        var secondPart = try! managedObjectContext.executeFetchRequest(secondPartFetchRequest) as! [NSManagedObject]
        secondPart = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(secondPart) as! [NSManagedObject]
        for i in 0 ..< secondPart.count {
            if firstPart.count == count {
                break;
            }
            firstPart.append(secondPart[i])
        }
        return firstPart
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.example.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ActooModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ActooCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

