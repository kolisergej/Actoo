//
//  Word.swift
//  Actoo
//
//  Created by Сергей Колибаба on 11/07/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import Foundation
import CoreData


class Word: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init() {
        // Создание нового объекта
        self.init(entity: CoreDataManager.instance.entityForName("Word"), insertIntoManagedObjectContext: CoreDataManager.instance.managedObjectContext)
    }

}
