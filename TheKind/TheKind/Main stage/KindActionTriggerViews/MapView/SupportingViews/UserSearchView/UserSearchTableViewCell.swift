//
//  testeTableViewCell.swift
//  TheKind
//
//  Created by Tenny on 4/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

protocol UserSearchViewCellDelegate:AnyObject {
    func addRemoveUserClicked(_ sender: UserSearchTableViewCell)
}

class UserSearchTableViewCell: UITableViewCell {
    @IBOutlet var photoFrame: UIView! {
        didSet {
            photoFrame.layer.cornerRadius = photoFrame.bounds.width / 2
            photoFrame.layer.masksToBounds = true
        }
    }
    @IBOutlet var kindTypeLabel: UILabel!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var addRemoveButton: UIButton!
    @IBOutlet var kindImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    weak var delegate: UserSearchViewCellDelegate?
    
    var user: KindUser? {
        didSet {
            nameLabel.text = user?.name
            if let photoUrl = user?.photoURL {
                userPhotoImageView.loadImageUsingCacheWithUrlString(urlString: photoUrl)
            }
            if let kind = user?.kind {
                if let kind = GameKinds.createKindCard(id: kind) {
                    kindImageView.image = UIImage(named: kind.iconImageName.rawValue)
                    kindTypeLabel.text = kind.kindName.rawValue
                }
            }
        }
    }
    
    
    override func prepareForReuse() {
        addRemoveButton.setImage(UIImage(named: "adduser"), for: .normal)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addRemoveButtonClicked(sender: AnyObject) {
        delegate?.addRemoveUserClicked(self)
    }
    
    
    
}
