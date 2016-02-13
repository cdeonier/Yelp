//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business] = []
    var searchBar: UISearchBar?
    var filters: Filters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setUpTableView()
        setUpSearchBar()

        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
        
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
            self.tableView.reloadData()
        })

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    func setUpSearchBar() {
        searchBar = UISearchBar()
        searchBar?.placeholder = "Restaurants"
        searchBar?.sizeToFit()
        searchBar?.delegate = self
        
        navigationItem.titleView = searchBar
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSLog("Did search with text" + searchText)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: BusinessCell, forRowAtIndexPath: NSIndexPath) {
        let business = businesses[forRowAtIndexPath.row]
        
        cell.thumbnailImageView.setImageWithURL(business.imageURL!)
        cell.titleLabel.text = business.name
        cell.addressLabel.text = business.address
        cell.ratingsImageView.setImageWithURL(business.ratingImageURL!)
        cell.categoriesLabel.text = business.categories
        cell.distanceLabel.text = business.distance
        cell.reviewsLabel.text = "\(business.reviewCount!) Reviews"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filtersViewController(filters: Filters) {
        self.filters = filters
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as? UINavigationController
        let filtersController = navigationController?.topViewController as? FiltersViewController
        
        if let filtersController = filtersController {
            filtersController.delegate = self
            filtersController.filters = filters
        }
    }


}
