//
//  JungChatBubbleCollectionViewCell.swift
//  TheKind
//
//  Created by Tenny on 28/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class JungChatBubbleCollectionViewCell: UICollectionViewCell {

    @IBOutlet var chatLineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func prepareForReuse() {
        self.alpha = 1
    }
}
