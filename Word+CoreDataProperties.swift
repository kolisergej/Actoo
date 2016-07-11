//
//  Word+CoreDataProperties.swift
//  Actoo
//
//  Created by Сергей Колибаба on 11/07/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Word {

    @NSManaged var examples: NSObject?
    @NSManaged var fromLng: String?
    @NSManaged var origWord: String?
    @NSManaged var rating: Int32
    @NSManaged var syns: NSObject?
    @NSManaged var toLng: String?
    @NSManaged var trWord: String?

}
