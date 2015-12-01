//
//  MapViewController.swift
//  TwitterTrend
//
//  Created by Hiro on 05.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import UIKit
import CoreData

class TrendingViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // variables / shared objects
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var fetchResultsController: NSFetchedResultsController?
    var refreshIndicator: UIRefreshControl!
    var currentPlace: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup refresh indicator
        refreshIndicator = UIRefreshControl()
        refreshIndicator.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshIndicator.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshIndicator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
    
        self.refresh(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // if user selected a table row pass the current woeid to the destination view
        switch segue.identifier! {
            case "showLocationDetailSegue":
                let destination = segue.destinationViewController as! DetailViewController
                destination.place = currentPlace
            default:
                print("Unknown segue: \(segue.identifier)")
        }
    }
    
    // MARK: - My Functions
    
    /**
        Retrieve TwitterTrends from persistence store (CoreData).
     */
    func getTrendsFromPersistenceStore() {
        
        // CoreData load pins from persistent store
        fetchResultsController = NSFetchedResultsController(fetchRequest: Place.getFetchRequest(),
            managedObjectContext: CoreDataStack.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
            
            appDelegate.trendingPlaces = fetchResultsController?.fetchedObjects as? [Place]
            
            // fill tableView with loaded places
            tableView.reloadData()
            
        } catch let error as NSError {
            
            let alert = Utils.alertWithoutAction(title: "CoreData",
                message: "Couldnt load places from CoreData. \(error.localizedDescription)",
                style: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: true, completion: { } )
        }
    }
    
    /**
        Refresh the data for TwitterTrend information using the Twitter REST API.
    
        :param: sender     object reference this function gets called by
     */
    func refresh(sender: AnyObject!)
    {
        // Code to refresh table view
        appDelegate.twitterClient!.getPlacesWithTrends({ (error) -> Void in
            
            if (error == nil) {
                
                self.getTrendsFromPersistenceStore()
                self.tableView.reloadData()
                
            } else {
                print("Error: \(error)")
            }
        })
        
        refreshIndicator.endRefreshing()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        // get the woeid of the place which was selected in the table
        let place = appDelegate.trendingPlaces![indexPath.row]
        self.currentPlace = place
        
        // return the indexPath of the selection
        return indexPath
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // place all in one section
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return the count of places found on Twitter
        if (appDelegate.trendingPlaces != nil) {
            return appDelegate.trendingPlaces!.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("trendCell") as! trendCell
        
        if (appDelegate.trendingPlaces != nil) {

            let place = appDelegate.trendingPlaces![indexPath.row]
            
            cell.locationName.text = place.name
            
            if let country = place.country {
                cell.countryName.text = country
                
                if let code = place.countryCode {
                    cell.countryName.text?.appendContentsOf(", \(code)")
                }
            }
        }
        
        
        return cell
    }
}