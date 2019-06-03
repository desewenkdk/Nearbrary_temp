//
//  DetailInformationTableViewCell.swift
//  Nearbrary
//
//  Created by Release on 03/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class DetailInformationTableViewCell: UITableViewCell {

    @IBOutlet var sogangC: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sogangC.text="2"
        sogangC.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
