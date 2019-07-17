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
    
    
    var selectedKindFromUserDeck = -1
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var isDescribingCardSwiping: Bool = true
    
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

    
    }
    



}

extension CardSwipeView: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        // resets the selection of the user chosen collectionview.
        selectedKindFromUserDeck = -1
        
        // Toggle between describing new cards or giving users options to remove from his deck
        isDescribingCardSwiping = true
        
        //HERE: These resets are causing crashes. Why ?
       // self.mainViewController?.jungChatLogger.resetJungChat()
        
        chosenKindsCollectionView.reloadData()
        
        kindCardIntroExplainer()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // ============= load card from xib
        let customView = Bundle.main.loadNibNamed("KindSwipeView", owner: nil, options: nil)?.first as? KindCardView
        
       // self.mainViewController?.jungChatLogger.resetJungChat()
        
        let kinds:[KindCard] = GameKinds.minorKindsOriginalArray //Array(GameKinds.minorKindsOriginal.values)
        
        currentlyShowingKindCard = kinds[indexOfDisplayedKind]
        
        currentlyShowingCardImage = UIImage(named: currentlyShowingKindCard.iconImageName.rawValue) ?? UIImage(named: "original")!
        
        customView?.imageView.image = currentlyShowingCardImage.withRenderingMode(.alwaysTemplate)
        customView?.imageView.tintColor = GOLDCOLOR
        customView?.kindDescriptionLabel.text = currentlyShowingKindCard.kindName.rawValue
        
        //Describe incoming Kind.
        kindCardIntroExplainer()
        
        // tells the system a new card is being presented for swipe (modifies the behavior of the right/left buttons)
        isDescribingCardSwiping = true
        
        return customView!
    }
    
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
}

extension CardSwipeView: KolodaViewDelegate {

    //This is being triggered for everycard/
    //We are working with a deck of 1. And injecting a new deck everytime
    //This is just so users can't see the next card while interacting with the current.
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("kolodaDidRunOutOfCards")
        indexOfDisplayedKind += 1
        //imageToShowIndex = min(imageToShowIndex, kindsToSwipe.count)
        indexOfDisplayedKind = min(indexOfDisplayedKind, kindsToSwipe.count - 1)
        print("kindsToSwipe", kindsToSwipe.count)
        print("indexOfDisplayedKind", indexOfDisplayedKind)
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
            delay(bySeconds: 0.3) {
                self.deselectAllItemsInChosenKindCollection()
            }
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

        // change of color for item.
        if selectedKindFromUserDeck == indexPath.row {
            cell.kindImageView.tintColor = GOLDCOLOR
        } else {
            cell.kindImageView.tintColor = DARKGREYCOLOR
        }
    
        return cell
        
    }
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // tells the system the focus is not on the card being presented for swipe (modifies the behavior of the right/left buttons)
        isDescribingCardSwiping = false
        // cleans chat.
        self.mainViewController?.jungChatLogger.resetJungChat()
    
        selectedKindFromUserDeck = indexPath.row
        // this forces change of color for item
        collectionView.reloadData()
        
        jungOffersToRemoveKindFromCollectionView()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        guard let overlayView = Bundle.main.loadNibNamed("CustomSwipeOverlay", owner: self, options: nil)![0] as? CustomSwipeOverlay else {return nil}
        return overlayView
    }
    
    func jungOffersToRemoveKindFromCollectionView() {
        manageKindFromKindDeckExplainer()
    }

    func deselectAllItemsInChosenKindCollection() {
        selectedKindFromUserDeck = -1 // deselect everyone
        chosenKindsCollectionView.reloadData()
    }
    
}

extension CardSwipeView: KindActionTriggerViewProtocol {

    
    func talk() {
        
    }
    
    func activate() {
        Bundle.main.loadNibNamed("CardSwipeView", owner: self, options: nil)
        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        addSubview(mainView)
        
        self.isHidden = false
        kolodaView.dataSource = self
        kolodaView.delegate = self
        chosenKindsCollectionView.dataSource = self
        chosenKindsCollectionView.delegate = self
        kolodaView.appearanceAnimationDuration = 0.3
        chosenKindsCollectionView?.register(UINib(nibName: "ChosenKindCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChosenKindCollectionViewCell")
        
        
        // triggers every time the deck is updated.
        KindDeckManagement.sharedInstance.getCurrentUserDeck { (success) in
            //print("retrieval of deck is \(success)")
            print("retrieved")
            self.alpha = 1
            self.chosenKindsCollectionView.reloadData()
        }
        
 
    }
    
    func deactivate() {
        mainView.removeFromSuperview()
    }
    
    
    func rightOptionClicked() {
        if !isDescribingCardSwiping {
            removeKind()
        } else {
            kolodaView.swipe(.right)
        }
    }
    
    private func removeKind() {
        if selectedKindFromUserDeck > -1 {
            let indexPath = IndexPath(item: selectedKindFromUserDeck, section: 0)

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
                  
                    self.removedKindFromDeckExplainer()
                    
                }
            } else {
                failedToRemoveKindFromDeckExplainer()
            }

        } else {
            fatalError("kindsChosenSelectedIndex is pointing to -1, this will break the app")
        }
    }
    
    func leftOptionClicked() {
        if !isDescribingCardSwiping {
            moreInfoOnKind()
        } else {
            kolodaView.swipe(.left)
        }
    }

    private func moreInfoOnKind() {
        moreInfoOnKindExplainer()
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
}



