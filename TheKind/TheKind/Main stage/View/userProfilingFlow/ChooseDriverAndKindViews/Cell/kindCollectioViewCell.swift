//
//  CollectionViewCell.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 12/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class kindCollectioViewCell: UICollectionViewCell {

    @IBOutlet var icon_color: UIImageView!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var imageFrame: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
         icon.tintColor = UIColor(r: 95, g: 95, b: 97)
         icon_color.alpha = 0

    }

    override func prepareForReuse() {
        icon.tintColor = UIColor(r: 95, g: 95, b: 97)
        icon_color.alpha = 0
    }
}
