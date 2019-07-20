//
//  CardSwipeView.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//


import UIKit
import Koloda
import RxSwift
import RxRelay

//enum collectionViewUpdateEnum {
//    case insert, delete, scrollToItem
//}
//
//struct collectionViewUpdateEmmit {
//    var indexPath: IndexPath
//    var instruction: collectionViewUpdateEnum
//}

class CardSwipeView: UIView {

//    private var collectionViewUpdaterPublisher: PublishSubject<collectionViewUpdateEmmit> = PublishSubject()
    var deckIsFull: Bool {
        return KindDeckManagement.sharedInstance.userKindDeck.deck.count >= 12
    }
    // I need to save the Morto too cause when refreshing, cards are popping back in.
    var availableDeck: [KindCard] {
        get {
            let allcardsIDs = GameKinds.minorKindsOriginalArray.compactMap({$0.kindId.rawValue})
            let allRemainingCardsAfterPicked = allcardsIDs.filter {!KindDeckManagement.sharedInstance.userKindDeck.deck.contains($0)}
            let remaningAfterDiscarded = allRemainingCardsAfterPicked.filter {!discardedDeck.contains($0)}
            // turns [Int] into [KindCard]
            let cardsToPresent = remaningAfterDiscarded.compactMap{ cardId in
                GameKinds.createKindCard(id: cardId)
            }
            return cardsToPresent
        }
    }
    
    var cardOnTop:KindCard?
    
    var displayedCard: KindCard?
    var disposeBag = DisposeBag()
    
    var discardedDeck: [Int] = []
    var selectedKindFromUserDeck = -1 //deselected
    
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var isDescribingProposedCard: Bool = true
    
    @IBOutlet var kolodaView: KolodaView!
    @IBOutlet var chosenKindsCollectionView: UICollectionView!
    
    @IBOutlet var mainView: UIView!
    
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
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // ============= load card from xib
        let customView = Bundle.main.loadNibNamed("KindSwipeView", owner: nil, options: nil)?.first as? KindCardView

        isDescribingProposedCard = true

        if let displayedCard = availableDeck.first {
            let displayedCardImage = UIImage(named: displayedCard.iconImageName.rawValue)!
            customView?.imageView.image = displayedCardImage.withRenderingMode(.alwaysTemplate)
            customView?.imageView.tintColor = GOLDCOLOR
            customView?.kindDescriptionLabel.text = displayedCard.kindName.rawValue
            customView?.kindId = displayedCard.kindId.rawValue
            
            kindCardIntroExplainer()
            
        } else {
            customView?.kindDescriptionLabel.text = "No more cards available"
            customView?.kindId = -1
        }
        
        
        cardOnTop = GameKinds.createKindCard(id: customView!.kindId)
        
        
        return customView!
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        // resets the selection of the user chosen collectionview.
        // Removes the focus from the chosen collectionview
        deselectAllItemsInChosenKindCollection()
        
        // Toggle between describing new cards or giving users options to remove from his deck
        isDescribingProposedCard = true
        
        kindCardIntroExplainer()
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
        
        koloda.resetCurrentCardIndex()

    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
   
        if let kindCard = cardOnTop {
            if direction == SwipeResultDirection.left {
                
            KindDeckManagement.sharedInstance.userKindDeck.deck.insert(kindCard.kindId.rawValue, at: 0)
                
                KindDeckManagement.sharedInstance.updateKindDeck { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    let indexPath = IndexPath(item: index, section: 0)
//                    self.collectionViewUpdaterPublisher.onNext(collectionViewUpdateEmmit(indexPath: indexPath, instruction: .insert))
//                    self.collectionViewUpdaterPublisher.onNext(collectionViewUpdateEmmit(indexPath: indexPath, instruction: .scrollToItem))
                    DispatchQueue.main.async {
                        //delay(bySeconds: 0.2, closure: {
                            self.chosenKindsCollectionView.performBatchUpdates({
                                self.chosenKindsCollectionView.insertItems(at: [indexPath])
                                self.chosenKindsCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                            }, completion: { (completed) in
                                self.deselectAllItemsInChosenKindCollection()
                            })

                        //})
                    }
                }
            
            // SWIPE RIGHT
            } else if direction == SwipeResultDirection.right {
                discardedDeck.append(kindCard.kindId.rawValue)
                DispatchQueue.main.async {
                    self.deselectAllItemsInChosenKindCollection()
                }
            }
        }
        
        print("couldn't register swap, no card on top")
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
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        if availableDeck.count == 0 {
            return false
        }
        if KindDeckManagement.sharedInstance.userKindDeck.deck.count == 12 {
            deckIsFullExplainer()
            return false
        }
        return true
    }
    
 
}

// ===== REFERS TO THE COLLECTION VIEW OF CHOSEN KINDS
// ====================================================

extension CardSwipeView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return KindDeckManagement.sharedInstance.userKindDeck.deck.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChosenKindCollectionViewCell", for: indexPath) as! ChosenKindCollectionViewCell
        
        let kindID = KindDeckManagement.sharedInstance.userKindDeck.deck[indexPath.row]
        guard let kind = GameKinds.createKindCard(id:kindID) else {fatalError("can't find kind enum to create kind")}
        guard let image = UIImage(named: kind.iconImageName.rawValue) else {fatalError("image not found to kind \(kind)")}
        
        changeImageColorForSelected(kindID, cell, image, indexPath)

        return cell
        
    }
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // tells the system the focus is not on the card being presented for swipe (modifies the behavior of the right/left buttons)
        isDescribingProposedCard = false
        // cleans chat.
    
        selectedKindFromUserDeck = indexPath.row
        // this forces change of color for item
        collectionView.reloadData()
        
        if let selectedKindCard = GameKinds.createKindCard(id: KindDeckManagement.sharedInstance.userKindDeck.deck[selectedKindFromUserDeck]) {
            manageKindFromKindDeckExplainer(kind: selectedKindCard)
        }
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        guard let overlayView = Bundle.main.loadNibNamed("CustomSwipeOverlay", owner: self, options: nil)![0] as? CustomSwipeOverlay else {return nil}
        return overlayView
    }
    

    func deselectAllItemsInChosenKindCollection() {
        selectedKindFromUserDeck = -1 // deselect everyone
        chosenKindsCollectionView.reloadData()
    }
    
    fileprivate func changeImageColorForSelected(_ kindID: Int, _ cell: ChosenKindCollectionViewCell, _ image: UIImage, _ indexPath: IndexPath) {
        
        // Checks if selected kind is mainkind
        if kindID != KindDeckManagement.sharedInstance.userMainKind {
            cell.kindImageView.image = image.withRenderingMode(.alwaysTemplate)
            //selected is gold
            if selectedKindFromUserDeck == indexPath.row {
                cell.kindImageView.tintColor = GOLDCOLOR
            } else {
                cell.kindImageView.tintColor = DARKGREYCOLOR
            }
            
        } else { // is mainkind
            // selected is original color
            if selectedKindFromUserDeck == indexPath.row {
                cell.kindImageView.image = image
            } else {
                cell.kindImageView.image = image.withRenderingMode(.alwaysTemplate)
                cell.kindImageView.tintColor = DARKGREYCOLOR
            }
        }
    }

    
}

extension CardSwipeView: KindActionTriggerViewProtocol {

    
    func talk() {
        
    }
    
    func activate() {
        Bundle.main.loadNibNamed("CardSwipeView", owner: self, options: nil)
        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        addSubview(mainView)
        
        mainView.alpha = 0
        self.isHidden = false
        mainView.fadeIn(0.5)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        chosenKindsCollectionView.dataSource = self
        chosenKindsCollectionView.delegate = self
        kolodaView.appearanceAnimationDuration = 0.3
        chosenKindsCollectionView?.register(UINib(nibName: "ChosenKindCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChosenKindCollectionViewCell")
        
        activateDeckObserver()
        //activateCollectionViewUpdater()
        
        self.fadeIn(0.5)
        //self.chosenKindsCollectionView.reloadData()
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        self.discardedDeck = []
    
    }
    
    func deactivate() {
        self.fadeOut(0.5) {
            self.mainView.removeFromSuperview()
        }
    }
    
    
    func rightOptionClicked() {
        if !isDescribingProposedCard {
            removeKind()
            // HERE: Add clear light  bottom collection ad refresh
        } else {
            kolodaView.swipe(.right)
        }
    }
    
    private func removeKind() {
        if selectedKindFromUserDeck > -1 {
            let indexPath = IndexPath(item: selectedKindFromUserDeck, section: 0)

            let kindIdToRemove = KindDeckManagement.sharedInstance.userKindDeck.deck[indexPath.row]
            let currentMainKind = KindDeckManagement.sharedInstance.userMainKind ?? 0
            
            //Protects against removing the main kind
            if kindIdToRemove != currentMainKind {
               
                KindDeckManagement.sharedInstance.userKindDeck.deck.remove(at: indexPath.row)
                //self.kolodaView.resetCurrentCardIndex()
                //tries to update the deck
                KindDeckManagement.sharedInstance.updateKindDeck { (err) in
                    if let err = err {
                        print("remove kind error: \(err)")
                        return
                    }

                    DispatchQueue.main.async {
                        self.chosenKindsCollectionView.performBatchUpdates({
                            self.chosenKindsCollectionView.deleteItems(at: [indexPath])
                        }, completion: { (completed) in
                            self.deselectAllItemsInChosenKindCollection()
                        })
                        // Just refresh deck if no other cards are available.
                        // Otherwise it will refresh (blink) and user will only see the same card
                        // that was already there before, and its not the deleted one.
                        //Little gain for a blink.

                        if self.availableDeck.count == 1 {
                            self.kolodaView.resetCurrentCardIndex()
                        }
                    }
                  
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
        if !isDescribingProposedCard {
            moreInfoOnKind()
        } else {
            if !deckIsFull {
                kolodaView.swipe(.left)
            } else {
                deckIsFullExplainer()
            }
        }
    }

    private func moreInfoOnKind() {
        moreInfoOnKindExplainer()
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    func activateDeckObserver() {
//        KindDeckManagement.sharedInstance.deckObserver.share()
//            //.skip(1)
//            .subscribe(onNext:{ [weak self] cards in
//
//            })
//            .disposed(by: disposeBag)
//
    }
    
//    func activateCollectionViewUpdater() {
//        collectionViewUpdaterPublisher.asObserver()
//            .subscribe(onNext: { [weak self] update in
//               // DispatchQueue.main.async {
//                    switch update.instruction {
//                    case .insert:
//                        self?.chosenKindsCollectionView.insertItems(at: [update.indexPath])
//                    case .delete:
//                        self?.chosenKindsCollectionView.deleteItems(at: [update.indexPath])
//                    case .scrollToItem:
//                        self?.chosenKindsCollectionView.scrollToItem(at: update.indexPath, at: .right, animated: true)
//                    }
//               // }
//            })
//            .disposed(by: disposeBag)
//    }
}



