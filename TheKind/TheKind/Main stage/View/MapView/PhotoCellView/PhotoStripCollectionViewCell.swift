//
//  PhotoStripCollectionViewCell.swift
//  TheKind
//
//  Created by Tenny on 4/3/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

class PhotoStripCollectionViewCell: UICollectionViewCell {

    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var photoFrame: UIView! {
        didSet {
            photoFrame.layer.cornerRadius = photoFrame.bounds.width / 2
            photoFrame.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
