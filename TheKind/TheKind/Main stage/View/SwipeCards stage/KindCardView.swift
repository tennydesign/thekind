//
//  KindSwipeView.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import Foundation
import Koloda

class KindCardView: UIView {

    @IBOutlet var kindDescriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    var kindId: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    fileprivate func commonInit() {

    }
}
