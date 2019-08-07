//
//  AddNewUserTableViewCell.swift
//  TheKind
//
//  Created by Tenny on 4/24/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

class AddNewUserTableViewCell: UITableViewCell {

    @IBOutlet var inviteUserButton: KindButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        inviteUserButton.disableButton()
        // Initialization code
    }

    override func prepareForReuse() {
        inviteUserButton.disableButton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
