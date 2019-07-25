//
//  HUDview.swift
//  TheKind
//
//  Created by Tenny on 13/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

//PassthroughView
//class HUDview: KindActionTriggerView {
class HUDview: PassthroughView,KindActionTriggerViewProtocol {

    
    @IBOutlet var hudGradient: UIImageView!
    @IBOutlet weak var hudControls: UIView!
    var mainViewController: MainViewController?
    @IBOutlet var viewForKindCard: UIView!
    @IBOutlet var hudView: UIView!
    @IBOutlet var hudCenterDisplay: UIView!
    
    @IBOutlet weak var hudRightDisplay: UIView!
    @IBOutlet weak var hudLeftDisplay: UIView!
    @IBOutlet var circleNameStack: UIStackView!
    @IBOutlet var listViewStack: UIStackView!
    @IBOutlet var kindIconImageView: UIImageView! {
        didSet {
            // To take the color away.
            //kindIconImageView.image = kindIconImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet var viewForAvatar: UIView!
    @IBOutlet var userPictureImageVIew: UIImageView!
    @IBOutlet var photoFrame: UIView! {
        didSet {
            photoFrame.layer.cornerRadius = photoFrame.bounds.width / 2
            photoFrame.layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private var gradient: CAGradientLayer!
    private let bag = DisposeBag()
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("HUDview", owner: self, options: nil)
        addSubview(hudView)
        userSettingsSubscription()
        
        kindIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleKindImageTapGesture)))

    }
    
    func navigateBack() {
        
    }
    
    @objc func handleKindImageTapGesture() {
        print("handleKindImageTapGesture")
        self.mainViewController?.chooseDriverView.activate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //gradient.frame = bounds
    }
    
    fileprivate func userSettingsSubscription() {
        //KindUserSettingsManager.sharedInstance.userSettingsRxBehaviorRelayPublisher
        KindUserSettingsManager.sharedInstance.userSettingsRxObserver
            .share().subscribe(onNext: { [weak self] kindUser in
                if let user = kindUser {
                    self?.updateUserPhotoWithCurrentState()
                    self?.showKindOnHUD(kindUser: user)
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func updateUserPhotoWithCurrentState() {
        // update photo:
        if let urlString = KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.photoURL.rawValue] as? String {
            // only load new image if it changed.
            if KindUserSettingsManager.sharedInstance.currentUserImageURL != urlString {
                if let url = URL(string: urlString) {
                    let data = try? Data(contentsOf: url)
                    guard let newImage = UIImage(data: data!) else {return}
                    
                    // Avoid flashing on onboarding where the preview is already in place when upload happens.
                    if let viewingImage = self.userPictureImageVIew.image {
                        if !(newImage.isEqualToImage(image: viewingImage)) {
                            self.userPictureImageVIew.image = newImage
                        }
                    } else {
                        // preview is not carrying any image.
                        self.userPictureImageVIew.image = newImage
                    }
                }
                KindUserSettingsManager.sharedInstance.currentUserImageURL = urlString
            }
            self.revealUserPhoto()
        } else {
            self.fadeOutUserPhoto()
        }
    }
    
    
    
    func rightOptionClicked() {
        
    }
    
    func leftOptionClicked() {
        
    }
    

    func showKindOnHUD(kindUser: KindUser) {
        guard let id = kindUser.kind else { return }
        guard let kind = GameKinds.createKindCard(id: id) else {fatalError("In showKindOnHUD")}
        kindIconImageView.image = UIImage(named: kind.iconImageName.rawValue)
        self.viewForKindCard.fadeIn(1)
    }
    
    func activate() {
        self.fadeIn(0.5)
        self.hudView.fadeIn(0.5)
    }
    
    func revealUserPhoto() {
        self.viewForAvatar.fadeIn(0.5)
    }
    
    func fadeOutUserPhoto() {
        self.viewForAvatar.fadeOut(0.5)
    }
    
    func deactivate() {
        // hide it.
        self.fadeOut(1)
    }
    
    @IBAction func mapListViewBtnClicked(_ sender: Any) {
        print("clicked")
        self.mainViewController?.listCircleView.activate()
    }
    
    
    @IBAction func loadKindManager(_ sender: UIButton) {
        self.mainViewController?.cardSwipeViewHost.activate()
    }
    
    func talk() {
        if self.userPictureImageVIew.image != nil {
            revealUserPhoto()
        }
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}
