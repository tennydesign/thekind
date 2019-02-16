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

class KindSwipeView: UIView {

    @IBOutlet var imageView: UIImageView!
    
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
