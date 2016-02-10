//
//  BusinessCellTableViewCell.swift
//  Yelp
//
//  Created by Christian Deonier on 2/7/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbnailImageView.layer.cornerRadius = 5
        thumbnailImageView.clipsToBounds = true
        
        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
