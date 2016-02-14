//
//  SwitchCell.swift
//  Yelp
//
//  Created by Christian Deonier on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, newValue: Bool)
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var optionSwitch: UISwitch!
    
    var delegate: SwitchCellDelegate?
    
    @IBAction func didToggleSwitch(sender: AnyObject) {
        delegate?.switchCell(self, newValue: optionSwitch.on)
    }
}
