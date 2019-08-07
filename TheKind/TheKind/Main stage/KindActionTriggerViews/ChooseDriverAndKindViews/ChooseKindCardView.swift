//
//  ChooseKindCardView.swift
//  TheKind
//
//  Created by Tenny on 12/14/18.
//  Copyright © 2018 tenny. All rights reserved.
//


import UIKit


struct Kind {
    var image: UIImage?
    var name: String?
    var id: Int?
}

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
    var selectedIndex: Int = 0 {
        didSet {
            if isShowingUserCarousel{
                browseKind()
            } else{
                selectedKind()
            }
        }
    }
    

    var currentCellToTint: kindCollectioViewCell?
    
    let flowLayout = ZoomAndSnapFlowLayout()

    
    @IBOutlet var chooseKindCard: UIView!

    var mainViewController: MainViewController?
    
    @IBOutlet weak var kindCollectionView: UICollectionView! {
        didSet {
            kindCollectionView.delegate = self
            kindCollectionView.dataSource = self
            kindCollectionView.collectionViewLayout = flowLayout
            kindCollectionView.register(UINib.init(nibName: "kindCollectioViewCell", bundle: nil), forCellWithReuseIdentifier: "kindCollectioViewCell")
            print(kindCollectionView.center)
        }
    }
    
    @IBOutlet var chooseCardView: UIView!
    
    var kinds: [Kind] = [Kind.init(image: #imageLiteral(resourceName: "angel"), name: "The Angel", id: 0),
                         Kind.init(image: #imageLiteral(resourceName: "founder"), name: "The Founder", id: 1),
                         Kind.init(image: #imageLiteral(resourceName: "rebel"), name: "The Rebel", id: 2),
                         Kind.init(image: #imageLiteral(resourceName: "team_player"), name: "The Team Player", id: 3),
                         Kind.init(image: #imageLiteral(resourceName: "grinder"), name: "The Grinder", id: 4),
                         Kind.init(image: #imageLiteral(resourceName: "mentor"), name: "The Mentor", id: 5),
                         Kind.init(image: #imageLiteral(resourceName: "leader"), name: "The Leader", id: 6),
                         Kind.init(image: #imageLiteral(resourceName: "trailblazer"), name: "The Trailblazer", id: 7),
                         Kind.init(image: #imageLiteral(resourceName: "explorer"), name: "The Explorer", id: 8),
                         Kind.init(image: #imageLiteral(resourceName: "visionary"), name: "The Visionary", id: 9),
                         Kind.init(image: #imageLiteral(resourceName: "Entertainer"), name: "The Entertainer", id: 10),
                         Kind.init(image: #imageLiteral(resourceName: "idealist"), name: "The Idealist", id: 4)]
    
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
        
        fillAndPresentLabelWith(0)
        print("status bar: \(UIApplication.shared.statusBarFrame.height)")
    }
    

    override func talk() {
        let txt = "Lastly...-Choose your kind."
        let actions: [KindActionType] = [.none, .activate]
        let actionViews: [ActionViewName] = [.none,.ChooseKindView]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
    }
    
    override func activate() {
        if isShowingUserCarousel {
            browseKind()
        } else {
            selectedKind()
        }
        self.fadeInView()
    }
    
    override func deactivate() {
        self.fadeOutView()
    }
    override func rightOptionClicked() {
        let txt = "So you are the Founder kind.-I realy like founders.-Creative disruptors."
        let actions: [KindActionType] = [.none, .deactivate,.talk]
        let actionViews: [ActionViewName] = [.none,.ChooseKindView,.MapView]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
    }
    
    override func leftOptionClicked() {
        if isShowingUserCarousel {
            self.fadeOutView()
            isShowingUserCarousel = false
        } else {
            self.fadeOutView()
            let txt = "Sure!"
            let actions: [KindActionType] = [.talk]
            let actionViews: [ActionViewName] = [.ChooseDriverView]
            
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
        }
    }
    
    // EXECUTED WHEN CAROUSEL IS SHOWING USER KINDS (TELL ME MORE ABOUT THIS KIND).
    func browseKind() {
        guard let kindName = kinds[selectedIndex].name else {return}
        let txt = "\(kindName) says: You can transform anything...-and turn any ordinary situations into extraordinary ones."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to circle", opt2: "Introduce us.", actionViews: (ActionViewName.ChooseKindView,ActionViewName.KindMatchControlView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    // EXECUTED WHEN USER IS CHOOSING KIND FROM CAROUSEL (ONBOARDING)
    func selectedKind() {
        guard let kindName = kinds[selectedIndex].name else {return}
        let txt = "\(kindName) says: You can transform anything...-and turn any ordinary situations into extraordinary ones."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to main driver.", opt2: "I'm like the \(kindName)", actionView: self)
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    fileprivate func fillAndPresentLabelWith(_ itemIndex: Int) {
        guard let kindName = self.kinds[itemIndex].name else {return}
        self.kindNameLabel.attributedText = formatLabelTextWithLineSpacing(text:kindName)
        UIView.animate(withDuration: 0.5) {
            self.kindNameLabel.alpha = 1
        }
        
    }
    

}


extension BrowseKindCardView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kinds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kindCollectioViewCell", for: indexPath) as! kindCollectioViewCell
        
        
        cell.icon.image = kinds[indexPath.row].image?.withRenderingMode(.alwaysTemplate)
        cell.icon_color.image = kinds[indexPath.row].image
        if indexPath.row == 0 {
            cell.icon_color.alpha = 1
        }
        
        return cell
    }
    
    
    func clearJungChat() {
        kindNameLabel.alpha = 0
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        clearJungChat()
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            print("right")
            
        } else {
            print("left")
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard let itemIndex = indexPathForCenterCell()?.row else {return}
        if !self.kindCollectionView.isDragging {
            self.fillAndPresentLabelWith(itemIndex)
            self.selectedIndex = itemIndex
        }
        
    }
    
    
    private func indexPathForCenterCell() -> IndexPath? {
        let center = convert(self.kindCollectionView.center, to: self.kindCollectionView)
        guard let indexPath = kindCollectionView!.indexPathForItem(at: center) else {return nil}
        print(indexPath.row)
        return indexPath
        
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

