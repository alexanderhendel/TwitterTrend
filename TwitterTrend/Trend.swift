//
//  Trend.swift
//  TwitterTrend
//
//  Created by Hiro on 17.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import Foundation
import CoreData

class Trend: NSManagedObject {

    /**
    Default initializer.
    
    :param: context     The NSManagedObjectContext to store the trend data.
    */
    convenience init(context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Trend", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    Convenience initializer.
    
    :param: context     The NSManagedObjectContext to store the trend data.
    */
    convenience init(context: NSManagedObjectContext,
        name: String,
        url: String,
        query: String,
        place: Place) {
            
            // init
            self.init(context: context)

            self.name = name
            self.url = url
            self.query = query
            self.place = place
    }
    
    /**
    Persist the Trend object instance.
    
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
        Setup a CoreData FetchRequest for Trend objects.
    
        :returns: NSFetchRequest for Trends ready to go.
    */
    class func getFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Trend")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        return fetchRequest
    }

    /**
        Setup a CoreData FetchRequest for Trend objects.
    
        :params: place Place object for which the trends should be fetched
    
        :returns: NSFetchRequest for Trends ready to go.
    */
    class func getFetchRequest(place: Place) -> NSFetchRequest {
    
        let request = self.getFetchRequest()
        
        // modify fetchRequest to fetch only place specific trends
        let predicate = NSPredicate(format: "place.woeid == %@", place.woeid)
        
        request.predicate = predicate
        
        return request
    }
}
