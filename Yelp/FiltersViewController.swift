//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Christian Deonier on 2/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersDelegate {
    func filtersViewController(filters: Filters)
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var filters: Filters?
    var delegate: FiltersDelegate?
    
    var distanceExpanded: Bool = false
    var sortOptionExpanded: Bool = false
    var categoriesExpanded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpNavigationStuff()
    }
    
    func setUpNavigationStuff() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.titleTextAttributes = titleDict as! [String: UIColor]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSearchButton(sender: AnyObject) {
        delegate?.filtersViewController(filters!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Filter.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UILabel()
        sectionHeader.text = Filter.values[section].rawValue
        return sectionHeader
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Filter.values[section] {
        case .Deals:
            return 1
        case .Distance:
            return distanceExpanded ? Distance.count : 1
        case .Sort:
            return sortOptionExpanded ? SortOption.count : 1
        case .Categories:
            return categoriesExpanded ? categories.count : 4
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (isSeeAllCell(indexPath)) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath)
            createBorder(cell)
            return cell
        }
        
        let filter = Filter.values[indexPath.section]
        if (filter == .Deals || filter == .Categories) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            configureSwitchCell(cell, forRowAtIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! DropdownCell
            configureDropdownCell(cell, forRowAtIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            if (distanceExpanded) {
                let row = indexPath.row
                filters?.distance = Distance.values[row]
            }
            distanceExpanded = !distanceExpanded
            let indexSet = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(indexSet, withRowAnimation: .Automatic)
            break
        case 2:
            if (sortOptionExpanded) {
                let row = indexPath.row
                filters?.sort = SortOption.values[row]
            }
            sortOptionExpanded = !sortOptionExpanded
            let indexSet = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(indexSet, withRowAnimation: .Automatic)
            break
        case 3:
            if (isSeeAllCell(indexPath)) {
                categoriesExpanded = true
                tableView.reloadData()
            }
        default:
            return
        }
    }
    
    func isSeeAllCell(indexPath: NSIndexPath) -> Bool {
        return !categoriesExpanded && indexPath.section == 3 && indexPath.row == 3
    }
    
    func configureSwitchCell(switchCell: SwitchCell, forRowAtIndexPath: NSIndexPath) {
        createBorder(switchCell)
        switchCell.delegate = self
        
        let section = forRowAtIndexPath.section
        switch section {
        case 0:
            switchCell.optionNameLabel.text = "Offering a Deal"
            switchCell.optionSwitch.on = (filters?.deals!)!
            break;
        case 3:
            let category = categories[forRowAtIndexPath.row]
            switchCell.optionNameLabel.text = category["name"]
            
            if let filters = filters {
                switchCell.optionSwitch.on = (filters.categories?.contains(category["code"]!))!
            }
            break;
        default:
            NSLog("Error trying to configure SwitchCell")
        }
    }
    
    func switchCell(switchCell: SwitchCell, newValue: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)
        if let indexPath = indexPath {
            let section = indexPath.section
        
            if (section == 0) {
                filters?.deals = newValue
            } else {
                let row = indexPath.row
                let categorySelected = categories[row]
                let categoryCode = categorySelected["code"]!
                if (newValue) {
                    filters?.categories?.append(categoryCode)
                } else {
                    let index = filters?.categories?.indexOf(categoryCode)
                    if let index = index {
                        filters?.categories?.removeAtIndex(index)
                    }
                }
            }
        }
    }
    
    func configureDropdownCell(dropdownCell: DropdownCell, forRowAtIndexPath: NSIndexPath) {
        createBorder(dropdownCell)
        
        let section = forRowAtIndexPath.section
        let row = forRowAtIndexPath.row
        
        switch section {
        case 1:
            if (distanceExpanded) {
                dropdownCell.optionNameLabel.text = Distance.displayStrings[row]
            } else {
                dropdownCell.optionNameLabel.text = filters?.displayStringForDistance()
            }
            dropdownCell.optionSelectionImageView.image = imageForDropdown(distanceExpanded, indexPath: forRowAtIndexPath)
            break;
        case 2:
            if (sortOptionExpanded) {
                dropdownCell.optionNameLabel.text = SortOption.displayStrings[row]
            } else {
                dropdownCell.optionNameLabel.text = filters?.displayStringForSortOption()
            }
            dropdownCell.optionSelectionImageView.image = imageForDropdown(sortOptionExpanded, indexPath:forRowAtIndexPath)
            break;
        default:
            NSLog("Error trying to configure SwitchCell")
        }
    }
    
    func imageForDropdown(optionsExpanded: Bool, indexPath: NSIndexPath) -> UIImage {
        let row = indexPath.row
        let section = indexPath.section
        
        var selectedIndex: Int
        if (section == 1) {
            selectedIndex = Distance.values.indexOf((filters?.distance)!)!
        } else {
            selectedIndex = SortOption.values.indexOf((filters?.sort)!)!
        }
        
        if (optionsExpanded) {
            if (row == selectedIndex) {
                return UIImage(named: "Check")!
            } else {
                return UIImage(named: "Circle")!
            }
        } else {
            return UIImage(named: "Dropdown")!
        }
    }

    func createBorder(view: UIView) {
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    let categories = [["name" : "Afghan", "code": "afghani"],
        ["name" : "African", "code": "african"],
        ["name" : "American, New", "code": "newamerican"],
        ["name" : "American, Traditional", "code": "tradamerican"],
        ["name" : "Arabian", "code": "arabian"],
        ["name" : "Argentine", "code": "argentine"],
        ["name" : "Armenian", "code": "armenian"],
        ["name" : "Asian Fusion", "code": "asianfusion"],
        ["name" : "Asturian", "code": "asturian"],
        ["name" : "Australian", "code": "australian"],
        ["name" : "Austrian", "code": "austrian"],
        ["name" : "Baguettes", "code": "baguettes"],
        ["name" : "Bangladeshi", "code": "bangladeshi"],
        ["name" : "Barbeque", "code": "bbq"],
        ["name" : "Basque", "code": "basque"],
        ["name" : "Bavarian", "code": "bavarian"],
        ["name" : "Beer Garden", "code": "beergarden"],
        ["name" : "Beer Hall", "code": "beerhall"],
        ["name" : "Beisl", "code": "beisl"],
        ["name" : "Belgian", "code": "belgian"],
        ["name" : "Bistros", "code": "bistros"],
        ["name" : "Black Sea", "code": "blacksea"],
        ["name" : "Brasseries", "code": "brasseries"],
        ["name" : "Brazilian", "code": "brazilian"],
        ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
        ["name" : "British", "code": "british"],
        ["name" : "Buffets", "code": "buffets"],
        ["name" : "Bulgarian", "code": "bulgarian"],
        ["name" : "Burgers", "code": "burgers"],
        ["name" : "Burmese", "code": "burmese"],
        ["name" : "Cafes", "code": "cafes"],
        ["name" : "Cafeteria", "code": "cafeteria"],
        ["name" : "Cajun/Creole", "code": "cajun"],
        ["name" : "Cambodian", "code": "cambodian"],
        ["name" : "Canadian", "code": "New)"],
        ["name" : "Canteen", "code": "canteen"],
        ["name" : "Caribbean", "code": "caribbean"],
        ["name" : "Catalan", "code": "catalan"],
        ["name" : "Chech", "code": "chech"],
        ["name" : "Cheesesteaks", "code": "cheesesteaks"],
        ["name" : "Chicken Shop", "code": "chickenshop"],
        ["name" : "Chicken Wings", "code": "chicken_wings"],
        ["name" : "Chilean", "code": "chilean"],
        ["name" : "Chinese", "code": "chinese"],
        ["name" : "Comfort Food", "code": "comfortfood"],
        ["name" : "Corsican", "code": "corsican"],
        ["name" : "Creperies", "code": "creperies"],
        ["name" : "Cuban", "code": "cuban"],
        ["name" : "Curry Sausage", "code": "currysausage"],
        ["name" : "Cypriot", "code": "cypriot"],
        ["name" : "Czech", "code": "czech"],
        ["name" : "Czech/Slovakian", "code": "czechslovakian"],
        ["name" : "Danish", "code": "danish"],
        ["name" : "Delis", "code": "delis"],
        ["name" : "Diners", "code": "diners"],
        ["name" : "Dumplings", "code": "dumplings"],
        ["name" : "Eastern European", "code": "eastern_european"],
        ["name" : "Ethiopian", "code": "ethiopian"],
        ["name" : "Fast Food", "code": "hotdogs"],
        ["name" : "Filipino", "code": "filipino"],
        ["name" : "Fish & Chips", "code": "fishnchips"],
        ["name" : "Fondue", "code": "fondue"],
        ["name" : "Food Court", "code": "food_court"],
        ["name" : "Food Stands", "code": "foodstands"],
        ["name" : "French", "code": "french"],
        ["name" : "French Southwest", "code": "sud_ouest"],
        ["name" : "Galician", "code": "galician"],
        ["name" : "Gastropubs", "code": "gastropubs"],
        ["name" : "Georgian", "code": "georgian"],
        ["name" : "German", "code": "german"],
        ["name" : "Giblets", "code": "giblets"],
        ["name" : "Gluten-Free", "code": "gluten_free"],
        ["name" : "Greek", "code": "greek"],
        ["name" : "Halal", "code": "halal"],
        ["name" : "Hawaiian", "code": "hawaiian"],
        ["name" : "Heuriger", "code": "heuriger"],
        ["name" : "Himalayan/Nepalese", "code": "himalayan"],
        ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
        ["name" : "Hot Dogs", "code": "hotdog"],
        ["name" : "Hot Pot", "code": "hotpot"],
        ["name" : "Hungarian", "code": "hungarian"],
        ["name" : "Iberian", "code": "iberian"],
        ["name" : "Indian", "code": "indpak"],
        ["name" : "Indonesian", "code": "indonesian"],
        ["name" : "International", "code": "international"],
        ["name" : "Irish", "code": "irish"],
        ["name" : "Island Pub", "code": "island_pub"],
        ["name" : "Israeli", "code": "israeli"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
        ["name" : "Jewish", "code": "jewish"],
        ["name" : "Kebab", "code": "kebab"],
        ["name" : "Korean", "code": "korean"],
        ["name" : "Kosher", "code": "kosher"],
        ["name" : "Kurdish", "code": "kurdish"],
        ["name" : "Laos", "code": "laos"],
        ["name" : "Laotian", "code": "laotian"],
        ["name" : "Latin American", "code": "latin"],
        ["name" : "Live/Raw Food", "code": "raw_food"],
        ["name" : "Lyonnais", "code": "lyonnais"],
        ["name" : "Malaysian", "code": "malaysian"],
        ["name" : "Meatballs", "code": "meatballs"],
        ["name" : "Mediterranean", "code": "mediterranean"],
        ["name" : "Mexican", "code": "mexican"],
        ["name" : "Middle Eastern", "code": "mideastern"],
        ["name" : "Milk Bars", "code": "milkbars"],
        ["name" : "Modern Australian", "code": "modern_australian"],
        ["name" : "Modern European", "code": "modern_european"],
        ["name" : "Mongolian", "code": "mongolian"],
        ["name" : "Moroccan", "code": "moroccan"],
        ["name" : "New Zealand", "code": "newzealand"],
        ["name" : "Night Food", "code": "nightfood"],
        ["name" : "Norcinerie", "code": "norcinerie"],
        ["name" : "Open Sandwiches", "code": "opensandwiches"],
        ["name" : "Oriental", "code": "oriental"],
        ["name" : "Pakistani", "code": "pakistani"],
        ["name" : "Parent Cafes", "code": "eltern_cafes"],
        ["name" : "Parma", "code": "parma"],
        ["name" : "Persian/Iranian", "code": "persian"],
        ["name" : "Peruvian", "code": "peruvian"],
        ["name" : "Pita", "code": "pita"],
        ["name" : "Pizza", "code": "pizza"],
        ["name" : "Polish", "code": "polish"],
        ["name" : "Portuguese", "code": "portuguese"],
        ["name" : "Potatoes", "code": "potatoes"],
        ["name" : "Poutineries", "code": "poutineries"],
        ["name" : "Pub Food", "code": "pubfood"],
        ["name" : "Rice", "code": "riceshop"],
        ["name" : "Romanian", "code": "romanian"],
        ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
        ["name" : "Rumanian", "code": "rumanian"],
        ["name" : "Russian", "code": "russian"],
        ["name" : "Salad", "code": "salad"],
        ["name" : "Sandwiches", "code": "sandwiches"],
        ["name" : "Scandinavian", "code": "scandinavian"],
        ["name" : "Scottish", "code": "scottish"],
        ["name" : "Seafood", "code": "seafood"],
        ["name" : "Serbo Croatian", "code": "serbocroatian"],
        ["name" : "Signature Cuisine", "code": "signature_cuisine"],
        ["name" : "Singaporean", "code": "singaporean"],
        ["name" : "Slovakian", "code": "slovakian"],
        ["name" : "Soul Food", "code": "soulfood"],
        ["name" : "Soup", "code": "soup"],
        ["name" : "Southern", "code": "southern"],
        ["name" : "Spanish", "code": "spanish"],
        ["name" : "Steakhouses", "code": "steak"],
        ["name" : "Sushi Bars", "code": "sushi"],
        ["name" : "Swabian", "code": "swabian"],
        ["name" : "Swedish", "code": "swedish"],
        ["name" : "Swiss Food", "code": "swissfood"],
        ["name" : "Tabernas", "code": "tabernas"],
        ["name" : "Taiwanese", "code": "taiwanese"],
        ["name" : "Tapas Bars", "code": "tapas"],
        ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
        ["name" : "Tex-Mex", "code": "tex-mex"],
        ["name" : "Thai", "code": "thai"],
        ["name" : "Traditional Norwegian", "code": "norwegian"],
        ["name" : "Traditional Swedish", "code": "traditional_swedish"],
        ["name" : "Trattorie", "code": "trattorie"],
        ["name" : "Turkish", "code": "turkish"],
        ["name" : "Ukrainian", "code": "ukrainian"],
        ["name" : "Uzbek", "code": "uzbek"],
        ["name" : "Vegan", "code": "vegan"],
        ["name" : "Vegetarian", "code": "vegetarian"],
        ["name" : "Venison", "code": "venison"],
        ["name" : "Vietnamese", "code": "vietnamese"],
        ["name" : "Wok", "code": "wok"],
        ["name" : "Wraps", "code": "wraps"],
        ["name" : "Yugoslav", "code": "yugoslav"]]
}
