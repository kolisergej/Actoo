//
//  TranslatedWord.swift
//  Actoo
//
//  Created by Сергей Колибаба on 06/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import Foundation

class Word: NSObject, NSCoding {
    let origWord: String
    let fromLng: String
    let trWord: String
    let toLng: String
    let syns: [String]
    let examples: [String: String]
    var rating: Int
    
    init(origWord: String, fromLng: String, trWord: String, toLng: String, syns: [String], examples: [String: String], rating: Int) {
        self.origWord = origWord
        self.fromLng = fromLng
        self.trWord = trWord
        self.toLng = toLng
        self.syns = syns
        self.examples = examples
        self.rating = rating
    }
    
    required init(coder aDecoder: NSCoder) {
        self.origWord = aDecoder.decodeObjectForKey("origWord") as! String
        self.fromLng = aDecoder.decodeObjectForKey("fromLng") as! String
        self.trWord = aDecoder.decodeObjectForKey("trWord") as! String
        self.toLng = aDecoder.decodeObjectForKey("toLng") as! String
        self.syns = aDecoder.decodeObjectForKey("syns") as! [String]
        self.examples = aDecoder.decodeObjectForKey("examples") as! [String: String]
        self.rating = aDecoder.decodeObjectForKey("rating") as! Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.origWord, forKey: "origWord")
        aCoder.encodeObject(self.fromLng, forKey: "fromLng")
        aCoder.encodeObject(self.trWord, forKey: "trWord")
        aCoder.encodeObject(self.toLng, forKey: "toLng")
        aCoder.encodeObject(self.syns, forKey: "syns")
        aCoder.encodeObject(self.examples, forKey: "examples")
        aCoder.encodeObject(self.rating, forKey: "rating")
    }
}