//
//  DetailInformationInfoContents.swift
//  Nearbrary
//
//  Created by 김동규 on 22/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class DetailInformationInfoContents: UITableViewCell {


    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var callno: UILabel!
    @IBOutlet weak var status: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
