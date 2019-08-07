//
//  PhotoStripCollectionViewCell.swift
//  TheKind
//
//  Created by Tenny on 4/3/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

protocol UserInCirclePhotoStripCellProtocol {
    func deleteUserFromCircleBtn(userId:String)
    func makeUserAdminForCircleBtn(userId:String)
}

class PhotoStripCollectionViewCell: UICollectionViewCell {

    @IBOutlet var photoArc: UIImageView!
    var delegate: UserInCirclePhotoStripCellProtocol?
    var user: KindUser?
    @IBOutlet var adminControls: PassthroughView!
    @IBOutlet var userNameLabel: UILabel!
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
        photoArc.image = photoArc.image?.withRenderingMode(.alwaysTemplate)
    }

    override func prepareForReuse() {
        adminControls.alpha = 0
    }
    @IBAction func removeUserBtnClicked(_ sender: UIButton) {
        guard let user = user, let uid = user.uid else {return}
        delegate?.deleteUserFromCircleBtn(userId: uid)
    }
    
    @IBAction func makeUserAdminForCircleBtnClicked(_ sender: Any) {
        guard let user = user, let uid = user.uid else {return}
        delegate?.makeUserAdminForCircleBtn(userId: uid)
    }
}
