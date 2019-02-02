//
//  ChooseKindCardView.swift
//  TheKind
//
//  Created by Tenny on 12/14/18.
//  Copyright © 2018 tenny. All rights reserved.
//


import UIKit



class ChooseKindCardView: UIView {
    
    static var iconCellSize: CGSize = CGSize(width: 30, height: 30)
    static var iconspacing:CGFloat = 90
    
    //This helps with the diff between the large one and the small ones
    static var activeDistance: CGFloat = 160
    static var zoomFactor: CGFloat = 3.5
    
    var colorCellAlpha:CGFloat = 10
    var currentCellToTint: kindCollectioViewCell?
    
    var onBoardingViewController: OnBoardingViewController?

    let flowLayout = ZoomAndSnapFlowLayout()
    @IBOutlet var kindInfoView: UIView!
    
    @IBOutlet var chooseKindCard: UIView!

    @IBOutlet weak var kindCollectionView: UICollectionView! {
        didSet {
            kindCollectionView.delegate = self
            kindCollectionView.dataSource = self
            kindCollectionView.collectionViewLayout = flowLayout
            kindCollectionView.register(UINib.init(nibName: "kindCollectioViewCell", bundle: nil), forCellWithReuseIdentifier: "kindCollectioViewCell")
        }
    }
    
    @IBOutlet var chooseCardView: UIView!
    
    var kindIconList: [UIImage] = [#imageLiteral(resourceName: "kind_shape_shifter"), #imageLiteral(resourceName: "kind_mountain"), #imageLiteral(resourceName: "kind_shape_shifter"),#imageLiteral(resourceName: "hud_kind_icon"), #imageLiteral(resourceName: "kind_mountain"), #imageLiteral(resourceName: "kind_shape_shifter"),#imageLiteral(resourceName: "hud_kind_icon"), #imageLiteral(resourceName: "kind_mountain"), #imageLiteral(resourceName: "kind_shape_shifter")]
    
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
        addSubview(chooseKindCard)
        
        print("status bar: \(UIApplication.shared.statusBarFrame.height)")
    }
    
    override func awakeFromNib() {
       //
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        onBoardingViewController?.switchViewsInsideController(toViewName: .chooseDriver, originView: self, removeOriginFromSuperView: false)
        
    }

    

}


extension ChooseKindCardView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kindIconList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kindCollectioViewCell", for: indexPath) as! kindCollectioViewCell
        
        
        cell.icon.image = kindIconList[indexPath.row].withRenderingMode(.alwaysTemplate)
        cell.icon_color.image = kindIconList[indexPath.row]
        if indexPath.row == 0 {
            cell.icon_color.alpha = 1
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (completed) in
            self.onBoardingViewController?.goToMainStoryboard()
        }
        
    }
    
    
    
    
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            print("right")
            
        } else {
            print("left")
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       // let centerElementIndexPath = indexPathForCenterCell()

    }
    
    
    private func indexPathForCenterCell() -> IndexPath? {
        let center = convert(self.kindCollectionView.center, to: self.kindCollectionView)
        guard let indexPath = kindCollectionView!.indexPathForItem(at: center) else {return nil}
        print(indexPath.row)
        return indexPath
        
    }


}



class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
    
    let activeDistance: CGFloat = ChooseKindCardView.activeDistance
    let zoomFactor: CGFloat = ChooseKindCardView.zoomFactor
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        minimumLineSpacing = ChooseKindCardView.iconspacing
        itemSize = ChooseKindCardView.iconCellSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                
                // hack: To tint the cells. its actually an alpha
                if let cell = collectionView.cellForItem(at: attributes.indexPath) as? kindCollectioViewCell {
                    cell.icon_color.alpha = (1-normalizedDistance.magnitude*2)
                }
                
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }
        
        return rectAttributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        
        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}





//    fileprivate func kindDeckCardScreenTransition(_ currentCardFrame: CGRect, _ desiredCardFrame: CGRect, _ imageName: String) {
//
//        let kindImage = UIImageView(image: UIImage(named: imageName))
//        kindImage.contentMode = .scaleAspectFit
//        kindImage.frame = CGRect(x: currentCardFrame.origin.x, y: currentCardFrame.origin.y, width: currentCardFrame.width, height: currentCardFrame.height)
//        kindImage.translatesAutoresizingMaskIntoConstraints = true
//        kindImage.tag = 11
//        UIApplication.shared.keyWindow!.addSubview(kindImage)
//
//        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
//            self.alpha = 0
//        }) { (completed) in
//            UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
//                kindImage.frame = desiredCardFrame
//
//            }, completion: { (completed) in
//                self.onBoardingViewController?.goToMainStoryboard()
//            })
//        }
//    }



//        // get the position of the image related to the main app screen
//        let cardLocation = cell.imageFrame.convert(cell.imageFrame.frame.origin, to: nil)
//
//        let currentCardFrame: CGRect = CGRect(x: cardLocation.x, y: cardLocation.y, width: cell.imageFrame.bounds.width, height: cell.imageFrame.bounds.height)
//
//
//        //This is the CGRECT of the card in the HUD (HUDView.xib)
//        //let desiredCardFrame: CGRect = CGRect(x: 31, y: 60, width: 28, height: 53)
//
//        // transition. Hardcoded for now for imagename
//        //kindDeckCardScreenTransition(currentCardFrame, desiredCardFrame, "hud_kind_icon")



//Really cool stuff
// Get the position of the cell in the screen
//        let realCellCenter = kindCollectionView.convert(cell.center, to: kindCollectionView.superview)

