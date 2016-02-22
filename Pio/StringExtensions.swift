//
//  StringExtensions.swift
//  Yelp
//
//  Created by Andre Oriani on 2/13/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation

extension String {
    func contains(aString: String) -> Bool {
        return self.lowercaseString.rangeOfString(aString.lowercaseString) != nil
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func truncate(length: Int) -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length))
        } else {
            return self
        }
    }
    
    func urlEncode() -> String {
        return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func replace(text: String, by replacement: String) -> String {
        return self.stringByReplacingOccurrencesOfString(text, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    var lenght: Int {
        return self.characters.count
    }
}