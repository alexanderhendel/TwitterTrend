//
//  Places+CoreDataProperties.swift
//  TwitterTrend
//
//  Created by Hiro on 06.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Place {

    @NSManaged var country: String?
    @NSManaged var countryCode: String?
    @NSManaged var name: String
    @NSManaged var parentid: NSNumber
    @NSManaged var url: String
    @NSManaged var woeid: NSNumber
    
    @NSManaged var trends: NSSet

}
