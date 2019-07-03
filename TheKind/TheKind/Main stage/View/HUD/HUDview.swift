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
    
    @IBOutlet var circleNameStack: UIStackView!
    @IBOutlet var listViewStack: UIStackView!
    @IBOutlet var kindIconImageView: UIImageView! {
        didSet {
            // To take the color away.
            kindIconImageView.image = kindIconImageView.image?.withRenderingMode(.alwaysTemplate)
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
        //updateHUDWithUserSettingsObserver() - Old.
        
        KindDeckManagement.sharedInstance.updateMainKindOnClient = { [unowned self] in
            if let kindId = KindDeckManagement.sharedInstance.userMainKind {
                self.showKindOnHUD(kindId)
            }
        }
        

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //gradient.frame = bounds
    }
    
    fileprivate func updateHUDWithUserSettingsObserver() {
        KindUserSettingsManager.sharedInstance.updateHUDWithUserSettings = { [unowned self] in
            self.updateUserPhotoWithCurrentState()
            
            // update kind
        }
        
        
    }
    
    fileprivate func userSettingsSubscription() {
        KindUserSettingsManager.sharedInstance.userSettingsRxObserver
            .share().subscribe(onNext: { [weak self] kindUser in
                if kindUser != nil {
                    self?.updateUserPhotoWithCurrentState()
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
    

    func showKindOnHUD(_ id: Int) {
        guard let kind = GameKinds.createKindCard(id: id) else {fatalError("In showKindOnHUD")}
        kindIconImageView.image = UIImage(named: kind.iconImageName.rawValue)
        self.viewForKindCard.fadeIn(1)
//        UIView.animate(withDuration: 1) {
//            self.viewForKindCard.alpha = 1
//        }
    }
    
    func activate() {
        self.fadeIn(0.5)
        self.hudView.fadeIn(0.5)
//        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations:
//            {
//                self.alpha = 1
//                self.hudView.alpha = 1
//        }, completion: nil)
        
        if self.userPictureImageVIew.image != nil {
            revealUserPhoto()
       }
    }
    
    func revealUserPhoto() {
        self.viewForAvatar.fadeIn(0.5)
//        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
//
//            self.viewForAvatar.alpha = 1
//
//        }, completion: nil)
    }
    
    func fadeOutUserPhoto() {
        self.viewForAvatar.fadeOut(0.5)
//        UIView.animate(withDuration: 0.5, animations: {
//            self.viewForAvatar.alpha = 0
//        })
    }
    
    func deactivate() {
        // hide it.
        self.fadeOut(1)
//        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
//            self.alpha = 0
//        }, completion: nil)
    }
    
    @IBAction func mapListViewBtnClicked(_ sender: Any) {
        print("clicked")
        self.mainViewController?.listCircleView.activate()
    }
    
    
    func talk() {
        
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}





//        gradient = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
//        gradient.locations = [0, 0.55, 1]
//        gradient.startPoint = CGPoint(x:0.0,y:0.0)
//        gradient.endPoint = CGPoint(x:0.0,y:1.0)
//        layer.insertSublayer(gradient, at: 0)
