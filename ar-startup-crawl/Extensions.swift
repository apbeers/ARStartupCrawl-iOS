//
//  Extensions.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 11/14/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}


