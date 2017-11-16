//
//  StartupTableViewCell.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/27/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit

class StartupTableViewCell: UITableViewCell {

    @IBOutlet weak var LogoImageView: UIImageView!
    
    @IBOutlet weak var ShortDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
