//
//  ChooseKindCardView.swift
//  TheKind
//
//  Created by Tenny on 12/14/18.
//  Copyright © 2018 tenny. All rights reserved.
//


import UIKit


class BrowseKindCardView: KindActionTriggerView {
    
    // INIT VALUES
    static var iconCellSize: CGSize = CGSize(width: 30, height: 30)
    static var iconspacing:CGFloat = 90
        //This helps with the diff between the large one and the small ones
    static var activeDistance: CGFloat = 160
    static var zoomFactor: CGFloat = 3.5
    //==============
    
    @IBOutlet var kindNameLabel: UILabel! {
        didSet {
            kindNameLabel.alpha = 0
        }
    }
    

    var talkbox: JungTalkBox?
    var selectedIndex: Int = 0
    

    var currentCellToTint: kindCollectioViewCell?
    var availableKindsForDriver: [KindCard] = []
    

    
    @IBOutlet var chooseKindCard: UIView!

    var mainViewController: MainViewController?
    
    @IBOutlet weak var kindCollectionView: UICollectionView! {
        didSet {
            kindCollectionView.delegate = self
            kindCollectionView.dataSource = self
            let flowLayout = ZoomAndSnapFlowLayout()
            kindCollectionView.collectionViewLayout = flowLayout
            kindCollectionView.register(UINib.init(nibName: "kindCollectioViewCell", bundle: nil), forCellWithReuseIdentifier: "kindCollectioViewCell")
            //print(kindCollectionView.center)
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
        Bundle.main.loadNibNamed("BrowseKindCardView", owner: self, options: nil)
        addSubview(chooseKindCard)
        
        //print("status bar: \(UIApplication.shared.statusBarFrame.height)")
    }
    

    override func talk() {
        if !KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck {
            let txt = "Choose your kind. -Tap the icon to know more or go back to change your main driver."
            let actions: [KindActionType] = [.none, .none]
            let actionViews: [ActionViewName] = [.none,.none]
            var options: (Snippet,Snippet)?
            if let kindName = availableKindsForDriver.first?.kindName.rawValue {
                options = self.talkbox?.createUserOptions(opt1: "Back to main driver.", opt2: "I'm like \(kindName)", actionView: self)
            }
            
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
        }
    }
    
    override func activate() {
         if !KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck {
            self.logCurrentLandingView(tag: ActionViewName.BrowseKindView.rawValue)
        }
            
        guard let driver =  KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.driver.rawValue] as? String else {
            fatalError("Cant find Driver choice, go back anc choose a driver")
        }
        
        guard let kindsForDriver = GameKinds.kindsForDriver[driver] else {fatalError("Cant find Kinds for driver choice")}
     
        self.alpha=1
        mainViewController?.chooseKindCardViewHost.isHidden = false
        availableKindsForDriver = kindsForDriver
        reloadAndResetCollectionView()
        
        fillAndPresentLabelWith(selectedIndex)
        //Switch between user is browsing or choosing carousels.

        talk()

    }
    
    override func deactivate() {
        self.fadeOutView()
    }
    
    override func rightOptionClicked() {
        print("right clicked")
        if !KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck {
            let kind = self.availableKindsForDriver[selectedIndex]
            let kindName = kind.kindName.rawValue
            let txt = "You chose\(kindName). -Now, let me show you the map.-Use it to find circles to join."
            let actions: [KindActionType] = [.activate, .deactivate, .activate]
            let actionViews: [ActionViewName] = [.HudView,.BrowseKindView, .MapView]
            
            // update user settings
            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.kind.rawValue] = kind.kindId.rawValue
            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
            
            // update deck.
            KindDeckManagement.sharedInstance.userMainKind = kind.kindId.rawValue
            KindDeckManagement.sharedInstance.saveMainKind() { (err) in
                if let err = err {
                    print("KindDeckManagement.sharedInstance.saveMainKind(): \(err)")
                    return
                }
                self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
            }
  
        }
    }
    
    override func leftOptionClicked() {
        if KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck {
            backToGameBoard()
        } else {
            backToChooseDriver()
        }
    }
    
    private func backToGameBoard() {
        self.fadeOutView()
        let actions: [KindActionType] = [.talk]
        let actionViews: [ActionViewName] = [ActionViewName.GameBoardSceneControlView]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
        KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck = false
    }
    
    private func backToChooseDriver() {
        self.fadeOutView()
        let actions: [KindActionType] = [.activate]
        let actionViews: [ActionViewName] = [.ChooseDriverView]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    
    // EXECUTED WHEN CAROUSEL IS SHOWING USER KINDS (TELL ME MORE ABOUT THIS KIND).
    func userIsBrowsingGameBoardKindsTalk() {
        let kindName = self.availableKindsForDriver[selectedIndex].kindName.rawValue
        let txt = "\(kindName) says: You can transform anything...-and turn any ordinary situations into extraordinary ones."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to the board", opt2: "Introduce us.", actionViews: (ActionViewName.BrowseKindView,ActionViewName.KindMatchControlView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
    }
    
    // EXECUTED WHEN USER IS CHOOSING MAIN USER KIND FROM CAROUSEL (ONBOARDING)
    func userIsSelectingMainKindTalk() {
        let kindName = self.availableKindsForDriver[selectedIndex].kindName.rawValue
        let txt = "\(kindName) says: You can transform anything...-and turn any ordinary situations into extraordinary ones."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to main driver.", opt2: "I'm like \(kindName)", actionView: self)
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
    }
    
    
    
    fileprivate func fillAndPresentLabelWith(_ itemIndex: Int) {
        let kindName = self.availableKindsForDriver[itemIndex].kindName.rawValue
        self.kindNameLabel.attributedText = formatLabelTextWithLineSpacing(text:kindName)
        UIView.animate(withDuration: 0.5) {
            self.kindNameLabel.alpha = 1
        }
        
    }
    

}


extension BrowseKindCardView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 
        return availableKindsForDriver.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kindCollectioViewCell", for: indexPath) as! kindCollectioViewCell
        
        
//        cell.icon.image = kinds[indexPath.row].image?.withRenderingMode(.alwaysTemplate)
//        cell.icon_color.image = kinds[indexPath.row].image
        
        guard let image = UIImage(named: availableKindsForDriver[indexPath.row].iconImageName.rawValue) else {fatalError("cant find image for kind")}
        cell.icon.image = image.withRenderingMode(.alwaysTemplate)
        cell.icon_color.image = image
        if indexPath.row == 0 {
            cell.icon_color.alpha = 1
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // clearJungChat()
        guard let itemIndex = indexPathForCenterCell()?.row else {return}
        self.selectedIndex = itemIndex
        if KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck {
            userIsBrowsingGameBoardKindsTalk()
        } else {
            userIsSelectingMainKindTalk()
        }
    }
    
    func clearJungChat() {
        kindNameLabel.alpha = 0
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // clearJungChat()
        self.kindNameLabel.alpha = 0
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            //print("right")
            
        } else {
            //print("left")
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard let itemIndex = indexPathForCenterCell()?.row else {return}
        if !self.kindCollectionView.isDragging {
            self.selectedIndex = itemIndex
            self.fillAndPresentLabelWith(selectedIndex)
        }
        
    }
    
    
    private func indexPathForCenterCell() -> IndexPath? {
        let center = convert(self.kindCollectionView.center, to: self.kindCollectionView)
        guard let indexPath = kindCollectionView!.indexPathForItem(at: center) else {return nil}
        //print(indexPath.row)
        return indexPath
        
    }
    
    private func reloadAndResetCollectionView() {
        selectedIndex=0
        kindCollectionView.reloadData()
        
        //This resets the collectionview position
        let flowLayout = ZoomAndSnapFlowLayout()
        kindCollectionView.collectionViewLayout = flowLayout
    }


}



class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
    
    let activeDistance: CGFloat = BrowseKindCardView.activeDistance
    let zoomFactor: CGFloat = BrowseKindCardView.zoomFactor
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        minimumLineSpacing = BrowseKindCardView.iconspacing
        itemSize = BrowseKindCardView.iconCellSize
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




//Really cool stuff
// Get the position of the cell in the screen
//        let realCellCenter = kindCollectionView.convert(cell.center, to: kindCollectionView.superview)

