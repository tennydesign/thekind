//
//  ChosenKindCollectionViewCell.swift
//  TheKind
//
//  Created by Tenny on 2/15/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

class ChosenKindCollectionViewCell: UICollectionViewCell {

    @IBOutlet var kindImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        kindImageView.tintColor = DARKGREYCOLOR
    }

}
