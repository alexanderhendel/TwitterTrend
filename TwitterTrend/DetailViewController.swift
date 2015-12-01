//
//  DetailViewController.swift
//  TwitterTrend
//
//  Created by Hiro on 17.11.15.
//  Copyright © 2015 alexhendel. All rights reserved.
//

import UIKit
import Social
import CoreData

class DetailViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // variables / shared objects
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var fetchResultsController: NSFetchedResultsController?
    var refreshIndicator: UIRefreshControl!
    var trends: [Trend]!
    var place: Place!
    
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

    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.refresh(nil)
    }
    
    // MARK: - My Functions
    /**
        Retrieve TwitterTrends from persistence store (CoreData).
    */
    func getTrendsFromPersistenceStore() {
        
        // CoreData load pins from persistent store
        fetchResultsController = NSFetchedResultsController(fetchRequest: Trend.getFetchRequest(place),
            managedObjectContext: CoreDataStack.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
            
            self.trends = fetchResultsController?.fetchedObjects as? [Trend]
            
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
        if (place != nil) {
            appDelegate.twitterClient!.getTrendsForPlace(place, completionHandler: { (error) -> Void in
                
                if (error == nil) {

                    self.getTrendsFromPersistenceStore()
                    self.tableView.reloadData()
                } else {
                    print("Error: \(error)")
                }
            })
            
            refreshIndicator.endRefreshing()
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let title = trends[indexPath.row].name
        
        // bring up a AlertController for sharing options
        let alert = UIAlertController(title: title, message: "Show tweets on Twitter or create a Tweet.", preferredStyle: .ActionSheet)
        
        // view trend related tweets in Twitter
        let firstAction = UIAlertAction(title: "Show on Twitter", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            debugPrint("User likes to view related tweets on Twitter.")
            
            let url = NSURL(string: self.trends[indexPath.row].url)
            
            if (url != nil) {
                UIApplication.sharedApplication().openURL(url!)
            }
        }
        
        // create Tweet with trending tag
        let secondAction = UIAlertAction(title: "Tweet", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            debugPrint("User likes to tweet this.")
            
            // check if user has setup twitter account
            if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
                
                // create compose view controller & prefill with selected trend
                let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                vc.setInitialText(title)
                
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
            
                Utils.alertWithoutAction(title: "Couldn't create Tweet.", message: "Couldn't create tweet. Please setup your Twitter account in your iPhone Settings.", style: .Alert)
            }
        }
        
        // cancel the sheet
        let thirdAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            
            debugPrint("User chose to cancel.")
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        
        presentViewController(alert, animated: true, completion:nil)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // place all in one section
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return the count of places found on Twitter
        if (self.trends != nil) {
            return self.trends!.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("trendCell") as! trendCell
        
        if (self.trends != nil) {

            cell.locationName.text = trends![indexPath.row].name
            cell.countryName.text = trends![indexPath.row].url
        }
        
        return cell
    }
}