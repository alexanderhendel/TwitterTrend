//
//  TwitterClient.swift
//  TwitterTrend
//
//  Created by Hiro on 06.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//
import Foundation
import CoreData
import Fabric
import TwitterKit

/*
 * This is a wrapper for custom Twitter REST requests powered by the 
 * Fabric Framework
 */

class TwitterClient: NSObject {
    
    private var lastPlacesRefreshTime: NSDate!
    private var lastTrendRefreshTime = [lastTrendRefresh]()
    
    private struct lastTrendRefresh {
        var time: NSDate!
        var woeid: NSNumber!
    }

    override init() {
    
        super.init()
    }
    
    /**
     TODO: Get Trends close to a given location - implements Endpoint trends/closest.json
     */
    func getTrendsNearLocation() {
    
    }
    
    /**
     Get Trends for a specific place - implements Endpoint trends/place.json
    
     :param: woeid      Yahoo woeid (where on earth id) - retrieved from the Twitter API
     */
    func getTrendsForPlace(currentPlace: Place, completionHandler: ((NSError?) -> Void)) {
        
        var trendTimer: lastTrendRefresh!
        var waitTimeExceeded = false
        var isNewTimer = true
        
        for timer in lastTrendRefreshTime {
            
            debugPrint("Compare timer val1 \(timer.woeid.integerValue) with val2 \(currentPlace.woeid.integerValue)")
            
            if (timer.woeid.integerValue == currentPlace.woeid.integerValue) {
                trendTimer = timer
                waitTimeExceeded = self.checkInterval(TwitterConfig.trendWaitTime, time: trendTimer.time)
                isNewTimer = false
            }
        }
        
        if (waitTimeExceeded == false) {
            
            if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
                
                let client = TWTRAPIClient(userID: userID)
                let endpoint = TwitterConfig.baseURL + TwitterConfig.endpoints.trendsPlace
                let params = ["id": "\(currentPlace.woeid)"]
                var clientError : NSError?
                
                do {
                    let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
                    
                    if (clientError == nil) {
                        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                            if (connectionError == nil) {
                                let jsonReadOpt = NSJSONReadingOptions.AllowFragments
                                
                                do {
                                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: jsonReadOpt)
                                    
                                    if let item = json[0] {
                                        if let trendDict = item["trends"] as? [[String: AnyObject]] {
                                            
                                            // successfully retrieved new trends - clear current persistence store
                                            self.deleteTrendsForPlace(currentPlace)
                                            
                                            for trend in trendDict {
                                                
                                                // core data storage
                                                let t = Trend.init(context: CoreDataStack.sharedInstance().managedObjectContext,
                                                    name: trend["name"] as! String,
                                                    url: trend["url"] as! String,
                                                    query: trend["query"] as! String,
                                                    place: currentPlace)
                                                
                                                let error: NSError!
                                                error = t.save(CoreDataStack.sharedInstance().managedObjectContext)
                                                
                                                if (error != nil) {
                                                    return completionHandler(error)
                                                }
                                            }
                                            
                                            // save timestamp
                                            if (isNewTimer == true) {
                                                
                                                var newTimer = lastTrendRefresh()
                                                newTimer.time = NSDate(timeIntervalSinceNow: 0)
                                                newTimer.woeid = currentPlace.woeid
                                                
                                                self.lastTrendRefreshTime.append(newTimer)
                                            }
                                            
                                            return completionHandler(nil)
                                        } else {
                                            
                                            let err = NSError(domain: "error.parse", code: 100, userInfo: ["localizedDescription": "Error: No trends found."])
                                            return completionHandler(err)
                                        }
                                    }
                                    
                                } catch let error as NSError {
                                    
                                    print("Error: \(error)")
                                    return completionHandler(error)
                                }
                            }
                            else {
                                print("Error: \(connectionError)")
                                return completionHandler(connectionError)
                            }
                        }
                    } else {
                        print("Error: \(clientError)")
                        return completionHandler(clientError)
                    }
                }
            }
        } else {
            let err = NSError(domain: "error.request", code: 101, userInfo: ["localizedDescription": "Error: Refresh skipped - last refresh is less than 15 min ago."])
            
            return completionHandler(err)
            
        }
    }
    
    /**
     Get all places with Trends - implements Endpoint trends/available.json
     */
    func getPlacesWithTrends(completionHandler: ((NSError?) -> Void)) {
        
        if (self.checkInterval(TwitterConfig.trendWaitTime, time: lastPlacesRefreshTime)) {
            
            if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
                
                let client = TWTRAPIClient(userID: userID)
                let endpoint = TwitterConfig.baseURL + TwitterConfig.endpoints.trendsAvailable
                let params = [NSObject: AnyObject]()
                var clientError : NSError?
                
                do {
                    let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
                    
                    if (clientError == nil) {
                        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                            if (connectionError == nil) {
                                let jsonReadOpt = NSJSONReadingOptions.AllowFragments
                                
                                do {
                                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: jsonReadOpt)
                                    
                                    if let placeDict = json as? [[String: AnyObject]] {
                                    
                                        // successfully retrieved new trends - clear current persistence store
                                        self.deletePlaceTrendData()
                                        
                                        for place in placeDict {
                                            
                                            // core data storage
                                            let p = Place.init(context: CoreDataStack.sharedInstance().managedObjectContext,
                                                       country: place["country"] as? String,
                                                   countryCode: place["countryCode"] as? String,
                                                          name: place["name"] as? String,
                                                      parentid: place["parentid"] as? NSNumber,
                                                           url: place["url"] as? String,
                                                         woeid: (place["woeid"] as? NSNumber)!)
                                            
                                            let error: NSError!
                                            error = p.save(CoreDataStack.sharedInstance().managedObjectContext)
                                            
                                            if (error != nil) {
                                                return completionHandler(error)
                                            }
                                        }
                                        
                                        // save timestamp
                                        self.lastPlacesRefreshTime = NSDate(timeIntervalSinceNow: 0)
                                        
                                        return completionHandler(nil)
                                    } else {
                                    
                                        let err = NSError(domain: "error.parse", code: 100, userInfo: ["localizedDescription": "Error: No places found."])
                                        return completionHandler(err)
                                    }
                                    
                                } catch let error as NSError {
                                    
                                    print("Error: \(error)")
                                    return completionHandler(error)
                                }
                            }
                            else {
                                print("Error: \(connectionError)")
                                return completionHandler(connectionError)
                            }
                        }
                    } else {
                        print("Error: \(clientError)")
                        return completionHandler(clientError)
                    }
                }
            }
        } else {
            let err = NSError(domain: "error.request", code: 101, userInfo: ["localizedDescription": "Error: Refresh skipped - last refresh is less than 15 min ago."])
            
            return completionHandler(err)

        }
    }
    
    /**
        Delete all trend data from CoreData persistence store. Once the data is
        refreshed from Twitter the old stuff should be deleted.
    */
    private func deletePlaceTrendData() -> NSError! {
        
        var err: NSError!
        let context = CoreDataStack.sharedInstance().managedObjectContext
        let request = Place.getFetchRequest()
        
        request.includesPropertyValues = false
        request.includesSubentities = true
        
        do {
            let places = try context.executeFetchRequest(request) as! [Place]
            
            var deleted = 0
            if places.count > 0 {
                
                for place: AnyObject in places {
                    
                    context.deleteObject(place as! Place)
                    deleted++
                }
                
                debugPrint("\(deleted) 'Place' NSManagedObject deleted.")

                try context.save()
            }
        } catch let error as NSError {
            
            debugPrint("\(error)")
            err = error
        }
        
        return err
    }
    
    /**
        Delete all trend data from CoreData persistence store. Once the data is
        refreshed from Twitter the old stuff should be deleted.
    */
    private func deleteTrendsForPlace(place: Place) -> NSError! {
    
        var err: NSError!
        let context = CoreDataStack.sharedInstance().managedObjectContext
        let request = Trend.getFetchRequest(place)
        
        request.includesPropertyValues = false
        request.includesSubentities = true
        
        do {
            let trends = try context.executeFetchRequest(request) as! [Trend]
            
            var deleted = 0
            if trends.count > 0 {
                
                for trend: AnyObject in trends {
                    
                    context.deleteObject(trend as! Trend)
                    deleted++
                }
                
                debugPrint("\(deleted) 'Trend' NSManagedObject deleted.")
                
                try context.save()
            }
        } catch let error as NSError {
            
            debugPrint("\(error)")
            err = error
        }
        
        return err
    }
    
    private func checkInterval(waitTime: Int, time: NSDate!) -> Bool {
    
        // only try if timestamp is 15 min ago or more (according to the Twitter API
        // documentation data for trends will only be refreshed once every 15 min)
        let timeInterval: NSTimeInterval!
        var doRrefresh = true
        
        if (time != nil) {
            timeInterval = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(time)
            
            if (timeInterval <= NSTimeInterval(waitTime)) {
                doRrefresh = false
            }
        }
        
        return doRrefresh
    }
    
}