//
//  JungOptionLabel.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 12/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class KindJungOptionLabel:UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        layer.cornerRadius = 10
        layer.borderWidth = 0
        layer.borderColor = LIGHTGREYCOLOR.cgColor //UIColor.lightGray.cgColor
    }
    
    var userOptionId: Int?
    var action: KindActionTypeEnum?
    var actionView: ViewForActionEnum?
    
    var userResponseOptionSnippet: Snippet? {
        didSet {
            text = userResponseOptionSnippet?.message
        }
    }

}
