//
//  TranslatedWord.swift
//  Actoo
//
//  Created by Сергей Колибаба on 06/06/16.
//  Copyright © 2016 Сергей Колибаба. All rights reserved.
//

import Foundation

class ActooWord: NSObject {
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
}