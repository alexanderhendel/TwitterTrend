//
//  Places.swift
//  TwitterTrend
//
//  Created by Hiro on 06.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject {

    /**
    Default initializer.
    
    :param: context     The NSManagedObjectContext to store the place data.
    */
    convenience init(context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    Convenience initializer.
    
    :param: context     The NSManagedObjectContext to store the place data.
    */
    convenience init(context: NSManagedObjectContext,
                     country: String! = nil,
                 countryCode: String! = nil,
                        name: String! = nil,
                    parentid: NSNumber! = nil,
                         url: String! = nil,
                       woeid: NSNumber) {
            // init
            self.init(context: context)
            
            if (name != nil) {
                self.name = name
            } else {
                self.name = ""
            }
                        
            if (parentid != nil) {
                self.parentid = parentid
            } else {
                self.parentid = 0
            }
                        
            self.woeid = woeid
            
            if (url != nil) {
                self.url = url
            } else {
                self.url = ""
            }
                        
            if let cnt = country {
                self.country = cnt
            } else {
                self.country = ""
            }
                        
            if let cntCode = countryCode {
                self.countryCode = cntCode
            } else {
                self.countryCode = ""
            }
    }
    
    /**
    Persist the Place object instance.
    
    :param: context managedObjectContext
    */
    func save(context: NSManagedObjectContext) -> NSError? {
        
        var retErr: NSError!
        retErr = nil
        
        do {
            try context.save()
        } catch let e as NSError {
            retErr = e
            print("Failure to save context: \(e.localizedDescription)")
        }
        
        return retErr
    }
    
    /**
    Setup a CoreData FetchRequest for Pin objects.
    
    :returns: NSFetchRequest for Pins ready to go.
    */
    class func getFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        fetchRequest.relationshipKeyPathsForPrefetching = ["trends"]
        
        return fetchRequest
    }
}
