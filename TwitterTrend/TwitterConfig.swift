//
//  TwitterConfig.swift
//  TwitterTrend
//
//  Created by Hiro on 06.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import Foundation

struct TwitterConfig {
    
    static let baseURL = "https://api.twitter.com/1.1/"
    
    struct endpoints {
        static let trendsAvailable = "trends/available.json"
        static let trendsPlace = "trends/place.json"
        static let trendsClosest = "trends/closest.json"
    }
    
    static let trendWaitTime = 900
}