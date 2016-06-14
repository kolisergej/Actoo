//
//  Country.swift
//  Actoo
//
//  Created by Сергей Колибаба on 14/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import Foundation

class Country : NSObject {
    var countryName: String
    var flagImage: String
    
    init(countryName: String, flagImage: String) {
        self.countryName = countryName
        self.flagImage = flagImage
    }
}