//
//  BottomViewMap.swift
//  TheKind
//
//  Created by Tenny on 1/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit

class CircleDetailView: UIView {
    @IBOutlet var chanceLabel: UILabel!
    @IBOutlet var mainView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CircleDetailView", owner: self, options: nil)
        addSubview(mainView)
        
        formatChanceText()
    }
    
    func formatChanceText() {
        let chance = NSMutableAttributedString.init(string: "Very ")
        let rest = NSMutableAttributedString.init(string: "likely to find a match.")
        // set the custom font and color for the 0,1 range in string
        chance.setAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13),
                              NSAttributedString.Key.foregroundColor: UIColor(r: 90, g: 200, b: 250)],
                             range: NSMakeRange(0, 4))
        rest.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11),
                              NSAttributedString.Key.foregroundColor: UIColor.white],
                             range: NSMakeRange(0,rest.length))
        // if you want, you can add more attributes for different ranges calling .setAttributes many times
        chance.append(rest)
        // set the attributed string to the UILabel object
        chanceLabel.attributedText = chance
    }
}
