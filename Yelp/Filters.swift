//
//  Filters.swift
//  Yelp
//
//  Created by Christian Deonier on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

enum SortOption : Int {
    case BestMatch = 0
    case Distance = 1
    case HighestRated = 2
    
    static let count = 3
    static let displayStrings = ["Best Match", "Distance", "Highest Rated"]
}

enum Filter : String {
    case Deals = "Deals"
    case Distance = "Distance"
    case Sort = "Sort"
    case Categories = "Categories"
    
    static let count = 4
    static let values = [Deals, Distance, Sort, Categories]
}

enum Distance : Int {
    case Auto = 0
    case One = 1
    case Five = 5
    case Twenty = 20
    
    static let count = 4
    static let displayStrings = ["Auto", "1 Mile", "5 Miles", "20 Miles"]
}

class Filters {
    
    var deals: Bool?
    var distance: Distance?
    var sort: SortOption?
    var categories: [String]?
    
    init() {
        categories = []
    }
    
}