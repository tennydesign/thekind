//
//  CircleListTableViewCell.swift
//  TheKind
//
//  Created by Tenny on 5/17/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

class CircleListTableViewCell: UITableViewCell {

    @IBOutlet var circlePlotNameLabel: UILabel!
    @IBOutlet var mapSnapShotImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var set: CircleAnnotationSet? {
        didSet {
            if let set = set {
                mapSnapShotImageView.loadImageUsingCacheWithUrlString(urlString: set.locationSnapShot)
                circlePlotNameLabel.text = set.circlePlotName
            }
        }
    }
    
    @IBOutlet var CircleImagePhotoFrame: UIView! {
        didSet {
            CircleImagePhotoFrame.layer.cornerRadius = CircleImagePhotoFrame.bounds.width / 2
            CircleImagePhotoFrame.layer.masksToBounds = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
