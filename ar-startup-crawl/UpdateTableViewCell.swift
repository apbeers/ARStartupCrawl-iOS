//
//  UpdateTableViewCell.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 11/14/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit

class UpdateTableViewCell: UITableViewCell {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var DatetimeLabel: UILabel!
    
    @IBOutlet weak var RoundedCornerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        RoundedCornerView.layer.cornerRadius = 18
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
