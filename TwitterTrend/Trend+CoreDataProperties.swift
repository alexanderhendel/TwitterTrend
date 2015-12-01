//
//  Trend+CoreDataProperties.swift
//  TwitterTrend
//
//  Created by Hiro on 17.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Trend {

    @NSManaged var name: String
    @NSManaged var query: String
    @NSManaged var url: String
    @NSManaged var place: Place?
}
