//
//  ChooseKindCardView.swift
//  TheKind
//
//  Created by Tenny on 12/14/18.
//  Copyright © 2018 tenny. All rights reserved.
//


import UIKit

// TODO: ADJUST SCREEN FOR X-FAMILY
class ChooseKindCardView: UIView {
    
    
    var onBoardingViewController: OnBoardingViewController?

    @IBOutlet var kindTextLabel: UILabel!
    
    @IBOutlet var kindInfoView: UIView!
    
    @IBOutlet var kindTitleLabel: UILabel!
    @IBOutlet var explainerView: UIView!
    @IBOutlet var leftarrow: UIImageView!
    @IBOutlet var swipeTo: UIImageView!

    @IBOutlet var ChooseKindCard: UIView!

    @IBOutlet var leftArrowConstraintX: NSLayoutConstraint!

    @IBOutlet weak var kindCollectionView: UICollectionView! {
        didSet {
            kindCollectionView.delegate = self
            kindCollectionView.dataSource = self
            kindCollectionView.register(UINib.init(nibName: "kindCollectioViewCell", bundle: nil), forCellWithReuseIdentifier: "kindCollectioViewCell")
        }
    }
    
    @IBOutlet var chooseCardView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ChooseKindCardView", owner: self, options: nil)
        addSubview(ChooseKindCard)
        
        // Just to make sure view is loaded before shooting the animation queue.
        delay(bySeconds: 1, closure: {
                self.animateExplainerArrow()
            })
    }
    
    override func awakeFromNib() {
       //
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        onBoardingViewController?.switchViewsInsideController(toViewName: .chooseDriver, originView: self, removeOriginFromSuperView: false)
        
    }
    // === General Supporting Functions
    fileprivate func animateExplainerArrow() {
        leftArrowConstraintX.constant = leftArrowConstraintX.constant + 10
        UIView.animate(withDuration: 0.9, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func kindDeckCardScreenTransition(_ currentCardFrame: CGRect, _ desiredCardFrame: CGRect, _ imageName: String) {
        //let kindImage = UIImageView(image: #imageLiteral(resourceName: "Entertainer_large"))
        let kindImage = UIImageView(image: UIImage(named: imageName))
        kindImage.contentMode = .scaleAspectFit
        kindImage.frame = CGRect(x: currentCardFrame.origin.x, y: currentCardFrame.origin.y, width: currentCardFrame.width, height: currentCardFrame.height)
        kindImage.translatesAutoresizingMaskIntoConstraints = true
        kindImage.tag = 11
        UIApplication.shared.keyWindow!.addSubview(kindImage)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (completed) in
            UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
                kindImage.frame = desiredCardFrame
                
            }, completion: { (completed) in
                self.onBoardingViewController?.segueToMainStoryboard(callerClassName: "")
            })
        }
    }
}


extension ChooseKindCardView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kindCollectioViewCell", for: indexPath) as! kindCollectioViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 390)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! kindCollectioViewCell
        
        // get the position of the image related to the main app screen
        let cardLocation = cell.imageFrame.convert(cell.imageFrame.frame.origin, to: nil)
        
        let currentCardFrame: CGRect = CGRect(x: cardLocation.x, y: cardLocation.y, width: cell.imageFrame.bounds.width, height: cell.imageFrame.bounds.height)
        

        //TODO: This 30 bothers me... its the Y for the transition. 20 + 10 (STATUS BAR)
        let desiredCardFrame: CGRect = CGRect(x: 162, y: 30, width: 51, height: 70)

        // transition. Hardcoded for now for imagename
        kindDeckCardScreenTransition(currentCardFrame, desiredCardFrame, "Entertainer_large")
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.explainerView.alpha = 0
        }) { (completed) in
            self.explainerView.layer.removeAllAnimations()
            self.explainerView.removeFromSuperview()
        }
    }
    

    
    

}



