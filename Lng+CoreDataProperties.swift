//
//  Lng+CoreDataProperties.swift
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

extension Lng {

    @NSManaged var directions: NSObject?
    @NSManaged var fromLng: String?
    @NSManaged var toLng: String?

}
