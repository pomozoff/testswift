//
//  SearchResultsViewController.swift
//  TestSwift
//
//  Created by Anton Pomozov on 17.06.14.
//  Copyright (c) 2014 Akademon Ltd. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    @IBOutlet var appsTableView : UITableView
    
    let api: APIController = APIController()
    let imageCache = NSMutableDictionary()
    var tableData: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.api.delegate = self
        self.api.searchItunesFor("Rovio")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as UITableViewCell
        
        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        // Get the formatted price string for display in the subtitle
        let formattedPrice: String = rowData["formattedPrice"] as String
        // Add a check to make sure this exists
        let cellText: String = rowData["trackName"] as String
        
        cell.text = cellText
        cell.detailTextLabel.text = formattedPrice

        let urlString: String = rowData["artworkUrl60"] as String
        var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
        
        if image? {
            cell.image = image
        } else {
            cell.image = UIImage(named: "placeholder")
            let url: NSURL = NSURL(string: urlString)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
                println("Image Download: Task completed")
                if error {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                } else {
                    image = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imageCache[urlString] = image
                        tableView.cellForRowAtIndexPath(indexPath).image = image
                    })
                }
            })
            task.resume()
        }
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Get the row data for the selected row
        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        let name: String = rowData["trackName"] as String
        let formattedPrice: String = rowData["formattedPrice"] as String
        
        let alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableData = resultsArr
            self.appsTableView.reloadData()
        })
    }
    
}
