//
//  CardSwipeView.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//


import UIKit
import Koloda

class CardSwipeView: UIView {
    //var kindsToSwipe: [UIImage] = [#imageLiteral(resourceName: "team_player"),#imageLiteral(resourceName: "explorer"),#imageLiteral(resourceName: "idealist"),#imageLiteral(resourceName: "rebel")]
    var kindsToSwipe: [KindCardIdEnum:KindCard] {
        get {
            return GameKinds.minorKindsOriginal
        }
    }
    
    
    var currentlyShowingCardImage = UIImage()
    var currentlyShowingCardId:KindCardIdEnum?
    var currentlyShowingCardTitle: KindNameEnum?
    
    var currentlyShowingKindCard: KindCard!
    
    var kindsChosenImages : [UIImage] = []
    var chosenKindsArray:[KindCard] = [] {
        didSet {
            
        }
    }
    
    
    var didSelectUserChosenKindIndex = -1
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var isInSwipeKindsMode: Bool = true
    
    @IBOutlet var kolodaView: KolodaView!
    @IBOutlet var chosenKindsCollectionView: UICollectionView!
    
    @IBOutlet var mainView: UIView!
    
    var indexOfDisplayedKind: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("CardSwipeView", owner: self, options: nil)
        addSubview(mainView)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        chosenKindsCollectionView.dataSource = self
        chosenKindsCollectionView.delegate = self
        kolodaView.appearanceAnimationDuration = 0.3
        chosenKindsCollectionView?.register(UINib(nibName: "ChosenKindCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChosenKindCollectionViewCell")

        
        // triggers every time the deck is updated.
        KindDeckManagement.sharedInstance.getCurrentUserDeck { (success) in
            print("retrieval of deck is \(success)")
        }
        KindDeckManagement.sharedInstance.updateMainKindOnClient = { [unowned self] in
            self.chosenKindsCollectionView.reloadData()
            
        }
        
    
    }
    



}

extension CardSwipeView: KolodaViewDelegate {

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        indexOfDisplayedKind += 1
        //imageToShowIndex = min(imageToShowIndex, kindsToSwipe.count)
        indexOfDisplayedKind = min(indexOfDisplayedKind, kindsToSwipe.count)
        
        //uncomment to reset.
//        if imageToShowIndex == kindsToSwipe.count {
//            imageToShowIndex = 0
//        }
        
        koloda.resetCurrentCardIndex()

    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //SWIPE LEFT
        if direction == SwipeResultDirection.left {
            // inserts
            guard let kindCard = currentlyShowingKindCard else {fatalError("no currentlyShowingKindCard found")}
           
            //kindsChosenImages.insert(currentlyShowingCardImage, at: 0)
            KindDeckManagement.sharedInstance.userKindDeck.insert(kindCard.kindId.rawValue, at: 0)
            
            KindDeckManagement.sharedInstance.updateKindDeck { (err) in
                if let err = err {
                    print("updatekind in swipe left error: \(err)")
                    return
                }
                
                let indexPath = IndexPath(item: 0, section: 0)
                self.chosenKindsCollectionView.insertItems(at: [indexPath])
                self.chosenKindsCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                
                // I need this delay otherwise the insert above cancels the reload.
                delay(bySeconds: 0.3) {
                    self.deselectAllItemsInChosenKindCollection()
                    
                }
            }
        
        // SWIPE RIGHT
        } else if direction == SwipeResultDirection.right {
            deselectAllItemsInChosenKindCollection()
        }
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.9
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
 
}

extension CardSwipeView: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        // resets the selection of the user chosen collectionview.
        didSelectUserChosenKindIndex = -1
        
        isInSwipeKindsMode = true
        self.mainViewController?.jungChatLogger.resetJungChat()
        chosenKindsCollectionView.reloadData()
        introduceKind()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // ============= load card from xib
        let customView = Bundle.main.loadNibNamed("KindSwipeView", owner: nil, options: nil)?.first as? KindSwipeView
        
        self.mainViewController?.jungChatLogger.resetJungChat()
        
        let kinds:[KindCard] = Array(GameKinds.minorKindsOriginal.values)
      
        currentlyShowingKindCard = kinds[indexOfDisplayedKind]
        currentlyShowingCardImage = UIImage(named: currentlyShowingKindCard.iconImageName.rawValue)!
        
        customView?.imageView.image = currentlyShowingCardImage.withRenderingMode(.alwaysTemplate)
        customView?.imageView.tintColor = UIColor(r: 210, g: 183, b: 102)
        customView?.kindDescriptionLabel.text = currentlyShowingKindCard.kindName.rawValue

        //Describe incoming Kind.
        introduceKind()

        // tells the system a new card is being presented for swipe (modifies the behavior of the right/left buttons)
        isInSwipeKindsMode = true
        
        return customView!
    }
    

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

}

// ===== REFERS TO THE COLLECTION VIEW OF CHOSEN KINDS
// ====================================================

extension CardSwipeView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return KindDeckManagement.sharedInstance.userKindDeck.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChosenKindCollectionViewCell", for: indexPath) as! ChosenKindCollectionViewCell
        
        let kindID = KindDeckManagement.sharedInstance.userKindDeck[indexPath.row]
        guard let kind = GameKinds.createKindCard(id:kindID) else {fatalError("can't find kind enum to create kind")}
        
        guard let image = UIImage(named: kind.iconImageName.rawValue) else {fatalError("image not found to kind \(kind)")}
        
        cell.kindImageView.image = image.withRenderingMode(.alwaysTemplate)
        print(didSelectUserChosenKindIndex)
        if didSelectUserChosenKindIndex == indexPath.row {
            cell.kindImageView.tintColor = UIColor(r: 210, g: 183, b: 102)
        } else {
            cell.kindImageView.tintColor = UIColor(r: 171, g: 171, b: 171)
        }
    
        print("DECK CARDS: \(KindDeckManagement.sharedInstance.userKindDeck)")
        return cell
        
    }
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        // tells the system the focus is not on the card being presented for swipe (modifies the behavior of the right/left buttons)
        isInSwipeKindsMode = false
        // cleans chat.
        self.mainViewController?.jungChatLogger.resetJungChat()
    
        didSelectUserChosenKindIndex = indexPath.row
        collectionView.reloadData()
        
        jungOffersToRemoveKindFromCollectionView()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        guard let overlayView = Bundle.main.loadNibNamed("CustomSwipeOverlay", owner: self, options: nil)![0] as? CustomSwipeOverlay else {return nil}
        return overlayView
    }
    
    func jungOffersToRemoveKindFromCollectionView() {
        //JUNG OFFERS TO REMOVE KIND.
        let txt = "(BOTTOM) The Poet kind says:-There should be no filter between reality and emotions."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Tell me more.", opt2: "Release kind.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }

    func deselectAllItemsInChosenKindCollection() {
        didSelectUserChosenKindIndex = -1 // deselect everyone
        chosenKindsCollectionView.reloadData()
    }
    
}


// ===== REFERS TO THE ACTION TRIGGERS
// ====================================================

extension CardSwipeView: KindActionTriggerViewProtocol {
    
    func introduceKind() {
        let txt = "(TOP) \(String(describing: currentlyShowingKindCard?.kindName.rawValue)) kind says:-There should be no filter between reality and emotions.-Life is a beautiful emotional rollercoaster."
        let actions: [KindActionType] = [.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Keep it.", opt2: "Don't keep it.", actionView: self)
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }
    
    func talk() {
        
    }
    
    func activate() {
        self.alpha = 1
        chosenKindsCollectionView.reloadData()
    }
    
    func deactivate() {
        
    }
    
    
    func rightOptionClicked() {
        if !isInSwipeKindsMode {
            removeKind()
        } else {
            kolodaView.swipe(.right)
        }
    }
    
    private func removeKind() {
        if didSelectUserChosenKindIndex > -1 {
            let indexPath = IndexPath(item: didSelectUserChosenKindIndex, section: 0)

            let kindIdToRemove = KindDeckManagement.sharedInstance.userKindDeck[indexPath.row]
            let currentMainKind = KindDeckManagement.sharedInstance.userMainKind ?? 0
            
            //Protects against removing the main kind
            if kindIdToRemove != currentMainKind {
                KindDeckManagement.sharedInstance.userKindDeck.remove(at: indexPath.row)
                //tries to update the deck
                KindDeckManagement.sharedInstance.updateKindDeck { (err) in
                    if let err = err {
                        print("remove kind error: \(err)")
                        return
                    }
                    
                    self.chosenKindsCollectionView.deleteItems(at: [indexPath])
                  
                    let txt = "Done."
                    let actions: [KindActionType] = [.none]
                    let actionViews: [ActionViewName] = [.none]
                    self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
                }
            } else {
                print("YOU CANT REMOVE THE MAIN KIND FROM HERE!!!!!!!!!!!")
                let txt = "You can only remove the main kind from the settings menu."
                let actions: [KindActionType] = [.none]
                let actionViews: [ActionViewName] = [.none]
                self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
            }

        } else {
            fatalError("kindsChosenSelectedIndex is pointing to -1, this will break the app")
        }
    }
    
    func leftOptionClicked() {
        if !isInSwipeKindsMode {
            moreInfoOnKind()
        } else {
            kolodaView.swipe(.left)
        }
    }

    private func moreInfoOnKind() {
        let txt = "Life is like a rollercoaster.-The ups are high and the downs are low.-The rollercoaster of life is what makes it genuine, sensible, intense and worth living."
        let actions: [KindActionType] = [.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Release kind.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}



