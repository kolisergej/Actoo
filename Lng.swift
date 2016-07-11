//
//  Lng.swift
//  Actoo
//
//  Created by Сергей Колибаба on 11/07/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import Foundation
import CoreData


class Lng: NSManagedObject {

    convenience init() {
        // Создание нового объекта
        self.init(entity: CoreDataManager.instance.entityForName("Lng"), insertIntoManagedObjectContext: CoreDataManager.instance.managedObjectContext)
    }

}
