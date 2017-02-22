//
//  LevelTableViewCell.swift
//  iXor
//
//  Created by OSX on 21.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet var  levelLabel           : UILabel!
    @IBOutlet var  descriptionLabel     : UILabel!
    @IBOutlet var  finishedImageView    : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
